use anchor_lang::prelude::*;

#[constant]
pub const GENESIS_ADMIN: Pubkey = pubkey!("3iyS9TmCgCFCisUjjnKN1hQEVDhXFrk2b5X5cg9M92gi");

#[constant]
pub const USER: &'static [u8] = b"user";
#[constant]
pub const USER_EXP: &'static [u8] = b"user_exp";
#[constant]
pub const USER_GOLD: &'static [u8] = b"user_gold";
#[constant]
pub const CONFIG: &'static [u8] = b"Config";
#[constant]
pub const MINT_CONFIG: &'static [u8] = b"mint_config";
#[constant]
pub const MINT_GOLD_AUTH: &'static [u8] = b"mint_gold_auth";
#[constant]
pub const MINT_NONCE_RECORD: &'static [u8] = b"mint_nonce_record";