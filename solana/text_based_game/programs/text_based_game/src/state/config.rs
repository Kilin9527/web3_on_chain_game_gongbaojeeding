use anchor_lang::prelude::*;

#[account]
pub struct Config {
    pub admin: Pubkey,
    pub pending_admin: Option<Pubkey>,
    // 4 bytes for the length prefix + 64 bytes for the CID V1(59) string
    pub config_cid: String
}

impl Config {
    // Maximum size: 8 (discriminator) 
    // 32 (Pubkey) + (1 (Option discriminant) + 32 (Pubkey)) + (4 + 64 (String))
    // 50 extra bytes for future fields
    pub const MAXIMUM_SIZE: usize = 8 + 32 + (1 + 32) + (4 + 64) + 50;

    pub const SEED_PREFIX: &'static [u8] = b"Config";
}