use anchor_lang::prelude::*;
use crate::state::config::*;
use crate::error::ErrorCode;
use crate::constants::*;    

// ==========================================
// 1. Handlers (Logic Layer)
// ==========================================
pub fn handler_initialize_config(ctx: Context<InitializeConfig>, cid: String) -> Result<()> {
    let config = &mut ctx.accounts.config;
    config.admin = ctx.accounts.admin.key();
    config.pending_admin = None;
    config.config_cid = cid;

    msg!("Config Initialized by Genesis Admin: {}", config.admin);
    Ok(())
}

pub fn handler_update_config(ctx: Context<UpdateConfig>, cid: String) -> Result<()> {
    let config = &mut ctx.accounts.config;
    msg!("Config CID Updated: {} -> {}", config.config_cid, cid);
    config.config_cid = cid;
    Ok(())
}

pub fn handler_propose_admin(ctx: Context<ProposeConfigAdmin>) -> Result<()> {
    let config = &mut ctx.accounts.config;
    let new_admin = ctx.accounts.new_admin.key();
    
    config.pending_admin = Some(new_admin);

    msg!("Admin Transfer Proposed. Pending Admin: {}", new_admin);
    msg!("Waiting for acceptance...");
    Ok(())
}

pub fn handler_accept_admin(ctx: Context<AcceptConfigAdmin>) -> Result<()> {
    let config = &mut ctx.accounts.config;
    
    let new_admin = ctx.accounts.new_admin.key();
    let old_admin = config.admin;

    config.admin = new_admin;
    config.pending_admin = None;

    msg!("Admin Transfer Accepted! {} -> {}", old_admin, new_admin);
    Ok(())
}

// ==========================================
// 2. Contexts (Validation Layer)
// ==========================================
#[derive(Accounts)]
pub struct InitializeConfig<'info> {
    #[account(
        init, 
        payer = admin, 
        seeds = [Config::SEED_PREFIX],
        bump,
        space = Config::MAXIMUM_SIZE
    )]
    pub config: Account<'info, Config>,
    
    #[account(mut, address = GENESIS_ADMIN @ ErrorCode::InitialConfigMappingFailed)]
    pub admin: Signer<'info>,
    
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateConfig<'info> { 
    #[account(
        mut,
        seeds = [Config::SEED_PREFIX],
        bump,
        has_one = admin
    )]
    pub config: Account<'info, Config>,
    
    pub admin: Signer<'info>,
}

#[derive(Accounts)]
pub struct ProposeConfigAdmin<'info> {
    #[account(
        mut,
        seeds = [Config::SEED_PREFIX],
        bump,
        has_one = admin @ ErrorCode::TransferConfigAdminFailed
    )]
    pub config: Account<'info, Config>,
    
    pub admin: Signer<'info>,

    /// CHECK: We are just storing this public key as the `pending_admin`.
    /// The account doesn't need to sign here, and it can be any valid Solana address 
    /// (System Account, PDA, Multisig, etc.). 
    /// Verification happens in the `accept_admin` step.
    #[account(
        constraint = new_admin.key() != admin.key() @ ErrorCode::InvalidAdminChange,
        constraint = new_admin.key() != Pubkey::default() @ ErrorCode::InvalidAdminChange
    )]
    pub new_admin: AccountInfo<'info>,
}

#[derive(Accounts)]
pub struct AcceptConfigAdmin<'info> {
    #[account(
        mut,
        seeds = [Config::SEED_PREFIX],
        bump,
        constraint = config.pending_admin == Some(new_admin.key()) @ ErrorCode::InvalidAdminChange
    )]
    pub config: Account<'info, Config>,
    
    #[account(mut)]
    pub new_admin: Signer<'info>,
}