use anchor_lang::prelude::*;

use crate::error::ErrorCode;
use crate::state::User;

#[derive(Accounts)]
pub struct UpdateGold<'info> {
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

pub fn update_gold_handler(ctx: Context<UpdateGold>, gold: i32) -> Result<()> {
    msg!("Starting update user({})'s gold, value changed: {}", ctx.accounts.signer.key(), gold);
    let user = &mut ctx.accounts.pda;

    let temp_changed_gold: i32 = user
        .gold
        .checked_add(gold as i32)
        .ok_or(ErrorCode::GoldOverflow)?;
    if temp_changed_gold < 0 {
        return Err(ErrorCode::GoldOverflow.into());
    }
    user.gold = temp_changed_gold;

    msg!("Update gold successful.");
    Ok(())
}
