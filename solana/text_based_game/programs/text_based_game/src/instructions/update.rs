use anchor_lang::prelude::*;

use crate::state::User;
use crate::error::ErrorCode;

#[derive(Accounts)]
pub struct Update<'info> {
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

pub fn update_handler(ctx: Context<Update>, exp: Option<u32>, gold: Option<i32>) -> Result<()> {
    msg!("Starting user update for: {}", ctx.accounts.signer.key());
    let user = &mut ctx.accounts.pda;
    // Update gold if provided
    if let Some(g) = gold {
        msg!("Updating gold by: {}", g);
        let temp_gold: i32 = user.gold.checked_add(g as i32).ok_or(ErrorCode::GoldOverflow)?;
        if temp_gold < 0 {
            return Err(ErrorCode::GoldOverflow.into());
        }
        user.gold = temp_gold;
    }
    // Update exp if provided
    if let Some(e) = exp {
        msg!("Updating exp by: {}", e);
        user.exp = user.exp.checked_add(e as u32).ok_or(ErrorCode::ExpOverflow)?;
    }

    msg!("Update successful. New state - Gold: {}, Exp: {}", user.gold, user.exp);
    Ok(())
}
