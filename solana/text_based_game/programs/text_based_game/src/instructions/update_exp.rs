use anchor_lang::prelude::*;

use crate::error::ErrorCode;
use crate::state::User;

#[derive(Accounts)]
pub struct UpdateExp<'info> {
    #[account(mut, signer)]
    pub signer: Signer<'info>,

    #[account(
        mut,
        seeds = [b"user", signer.key().as_ref()],
        bump = pda.bump,
        constraint = pda.authority == signer.key() @ ErrorCode::UnauthorizedAccount,
    )]
    pub pda: Account<'info, User>,
    pub system_program: Program<'info, System>,
}

pub fn update_exp_handler(ctx: Context<UpdateExp>, exp: u32) -> Result<()> {
    msg!("Starting update user({})'s exp, value changed: {}", ctx.accounts.signer.key(), exp);
    let user = &mut ctx.accounts.pda;

    let temp_changed_exp: u32 = user
        .exp
        .checked_add(exp as u32)
        .ok_or(ErrorCode::ExpOverflow)?;
    user.exp = temp_changed_exp;

    msg!("Update exp successful.");
    Ok(())
}
