use anchor_lang::prelude::*;

#[account]
#[derive(InitSpace)]
pub struct User {
    pub exp: u32,
    pub gold: i32,
    pub bump: u8,
    #[max_len(20)]
    pub name: String,
    pub authority: Pubkey,
}