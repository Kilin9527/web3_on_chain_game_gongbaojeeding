use anchor_lang::prelude::*;
use crate::error::ErrorCode;
use crate::constants::*;

use anchor_lang::solana_program::sysvar::instructions::{load_instruction_at_checked};

use anchor_spl::token_2022::{Token2022};
use anchor_spl::token_interface::{Mint, TokenAccount, MintTo, mint_to};

/// Initialize the global configuration for the minting system.
/// Sets the trusted backend public key and the admin authority.
pub fn handler_initialize_mint_config(ctx: Context<InitializeMintConfig>, backend_pubkey: Pubkey) -> Result<()> {
    let config = &mut ctx.accounts.backend_config;
    config.backend_pubkey = backend_pubkey;
    config.admin = ctx.accounts.admin.key();
    config.mint_auth_bump = ctx.bumps.mint_authority_pda;
    Ok(())  
}

/// Claim gold tokens using a server-side Ed25519 signature.
/// This function verifies that the transaction was authorized by the backend
/// by checking the preceding Ed25519 signature verification instruction.
pub fn handler_claim_gold(ctx: Context<ClaimGold>, amount: u64, nonce: u64, _signature: [u8; 64] ) -> Result<()> {
    // --- 1. Security Check: Verify Ed25519 Instruction ---
    let ixs = &ctx.accounts.instructions_sysvar;  
    let ix0 = load_instruction_at_checked(0, ixs)?;
    verify_message_data(&ix0.data, &ctx.accounts.backend_config.backend_pubkey, &ctx.accounts.player.key(), amount, nonce)?;
    msg!("Signature verified successfully in test handler.");
    
    // --- 2. Execute Minting via CPI (Token-2022) ---
    // Use the PDA as the mint authority to sign the CPI.
    let seeds = &[
        MINT_GOLD_AUTH,
        &[ctx.accounts.backend_config.mint_auth_bump],
    ];
    let signer = &[&seeds[..]];
    
    let cpi_program = ctx.accounts.token_2022_program.to_account_info();
    let cpi_accounts = MintTo {
        mint: ctx.accounts.gold_mint.to_account_info(),
        to: ctx.accounts.player_gold_account.to_account_info(),
        authority: ctx.accounts.mint_authority_pda.to_account_info(),
    };
    let cpi_ctx = CpiContext::new_with_signer(cpi_program, cpi_accounts, signer);
    let amount_internal = amount
        .checked_mul(1_000_000_000)
        .ok_or(ErrorCode::AmountOverflow)?; 
    mint_to(cpi_ctx, amount_internal)?;
    // Store the state to prevent replay attacks (handled by PDA initialization).
    ctx.accounts.nonce_record.nonce = nonce;
    ctx.accounts.nonce_record.player = ctx.accounts.player.key();
    Ok(())   
}

// ==========================================
// 2. Contexts (Validation Layer)
// ==========================================
#[derive(Accounts)]
pub struct InitializeMintConfig<'info> {
    #[account(
        init, 
        payer = admin, 
        space = 8 + BackendConfig::INIT_SPACE, 
        seeds = [MINT_CONFIG], 
        bump
    )]
    pub backend_config: Account<'info, BackendConfig>,

    /// PDA representing the Mint Authority. It does not hold data.
    /// CHECK: PDA used only for signing CPI calls.
    #[account(seeds = [MINT_GOLD_AUTH], bump)]
    pub mint_authority_pda: UncheckedAccount<'info>,

    #[account(mut, address = GENESIS_ADMIN @ ErrorCode::InvalidMintAuthority)]
    pub admin: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(amount: u64, nonce: u64, _signature: [u8; 64])] 
pub struct ClaimGold<'info> {
    #[account(mut)]
    pub player: Signer<'info>, 

    #[account(seeds = [MINT_CONFIG], bump)]
    pub backend_config: Account<'info, BackendConfig>, 

    #[account(
        mut,
        mint::token_program = token_2022_program,
    )]
    pub gold_mint: InterfaceAccount<'info, Mint>,

    #[account(
        init_if_needed,
        payer = player,  
        associated_token::mint = gold_mint,
        associated_token::authority = player,
        associated_token::token_program = token_2022_program,
    )]
    pub player_gold_account: InterfaceAccount<'info, TokenAccount>, 

    /// CHECK: Validated via seeds and used for CPI signing.
    #[account(seeds = [MINT_GOLD_AUTH], bump = backend_config.mint_auth_bump)]
    pub mint_authority_pda: UncheckedAccount<'info>,

    /// Replay Protection: Create a unique account per (player, nonce).
    /// If the nonce was already used, this initialization will fail.
    #[account(
        init,
        payer = player,
        space = 8 + NonceRecord::INIT_SPACE,
        seeds = [MINT_NONCE_RECORD, player.key().as_ref(), nonce.to_le_bytes().as_ref()],
        bump
    )]
    pub nonce_record: Account<'info, NonceRecord>,

    pub token_2022_program: Program<'info, Token2022>,
    pub system_program: Program<'info, System>,
    pub associated_token_program: Program<'info, anchor_spl::associated_token::AssociatedToken>,
    /// CHECK: This is the sysvar that holds the transaction's instruction data, allowing us to verify the Ed25519 signature.
    #[account(address = anchor_lang::solana_program::sysvar::instructions::ID)]
    pub instructions_sysvar: UncheckedAccount<'info>, 
}

#[account]
#[derive(InitSpace)]
pub struct BackendConfig {
    pub backend_pubkey: Pubkey, // Authorized server public key.
    pub admin: Pubkey,          // Admin authority.
    pub mint_auth_bump: u8,     // Stored bump to save compute during CPI.
}

#[account]
#[derive(InitSpace)]
pub struct NonceRecord {
    pub nonce: u64,
    pub player: Pubkey,
}

/*
    偏移量 (Byte)	长度	说明
    0	           1	   签名数量 (通常为 1)
    1	           1	   填充字节 (Padding)
    2	           2	   签名偏移量 (Signature Offset)
    4	           2	   签名指令索引 (通常为 u16::MAX)
    6	           2	   公钥偏移量 (Pubkey Offset)
    8	           2	   公钥指令索引
    10	           2	   消息数据偏移量 (Message Offset)
    12	           2	   消息数据大小 (Message Size)
    14	           2	   消息指令索引
*/
/// Verifies that the Ed25519 signature was made by the authorized backend.
/// The data layout of the Ed25519 instruction is complex; we parse offsets 
/// to find the signer's public key and the signed message.
pub fn verify_message_data(
    data: &[u8],           
    expected_backend: &Pubkey, 
    player: &Pubkey,       
    amount: u64,           
    nonce: u64             
) -> Result<()> {
    // 1. Basic length check (Header is 16 bytes).
    if data.len() < 16 {
        return err!(ErrorCode::InvalidSignatureInstruction);
    }

    // 2. Parse Offsets from the Ed25519 SigVerify instruction header.
    let pubkey_offset = u16::from_le_bytes(data[6..8].try_into().unwrap()) as usize;
    let msg_offset = u16::from_le_bytes(data[10..12].try_into().unwrap()) as usize;
    let msg_size = u16::from_le_bytes(data[12..14].try_into().unwrap()) as usize;

    // 3. Validate Backend Public Key: Ensure the signer is our trusted backend.
    let pubkey_in_sig = &data[pubkey_offset..pubkey_offset + 32];
    require!(pubkey_in_sig == expected_backend.as_ref(), ErrorCode::InvalidBackendKey);

    // 4. Validate Message Integrity: Match arguments with signed data.
    // Message Protocol: [Player(32) + Amount(8) + Nonce(8)] = 48 bytes.
    require!(msg_size == 48, ErrorCode::SignatureDataMismatch);
    let msg_data = &data[msg_offset..msg_offset + msg_size];

    // a. Verify Player address matches.
    require!(&msg_data[0..32] == player.as_ref(), ErrorCode::SignatureDataMismatch);

    // b. Verify Amount matches.
    let amount_in_msg = u64::from_le_bytes(msg_data[32..40].try_into().unwrap());
    require!(amount_in_msg == amount, ErrorCode::SignatureDataMismatch);

    // c. Verify Nonce matches.
    let nonce_in_msg = u64::from_le_bytes(msg_data[40..48].try_into().unwrap());
    require!(nonce_in_msg == nonce, ErrorCode::SignatureDataMismatch);

    Ok(())
}

