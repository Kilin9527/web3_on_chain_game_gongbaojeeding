use anchor_lang::prelude::*;

#[error_code]
pub enum ErrorCode {
    #[msg("User name is too short.")]
    UserNameTooShort,
    #[msg("User name is too long.")]
    UserNameTooLong,
    #[msg("Unauthorized account.")]
    UnauthorizedAccount,
    #[msg("Your gold is overflow.")]
    GoldOverflow,
    #[msg("Your experience is overflow.")]
    ExpOverflow,
}
