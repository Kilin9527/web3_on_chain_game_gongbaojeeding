use anchor_lang::prelude::*;
use crate::state::User;
use crate::error::ErrorCode;

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut, signer)]
    pub signer: Signer<'info>,

    #[account(
        init, 
        payer = signer,
        space = 8 + User::INIT_SPACE, // Adjusted space for User struct
        seeds = [b"user", signer.key().as_ref()],
        bump
    )]
    pub user_pda: Account<'info, User>,
    pub system_program: Program<'info, System>,
}

pub fn initialize_handler(ctx: Context<Initialize>, name: String) -> Result<()> {
    require!(name.len() >= 2, ErrorCode::UserNameTooShort);
    require!(name.len() <= 20, ErrorCode::UserNameTooLong);
    
    let user = &mut ctx.accounts.user_pda;
    user.gold = 0;
    user.exp = 0;
    user.bump = ctx.bumps.user_pda;
    user.name = name;
    user.authority = ctx.accounts.signer.key();

    msg!("User {} created in program {}, user pda is {}", user.name, ctx.program_id, user.key());

    Ok(())
}
