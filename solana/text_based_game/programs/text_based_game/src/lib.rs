pub mod constants;
pub mod error;
pub mod instructions;
pub mod state;

use anchor_lang::prelude::*;

pub use constants::*;
pub use instructions::*;
pub use state::*;

declare_id!("8Ya1qpPiLngJfPzQT1qX5hLFrzdV9Copwrq32SmkrpbH");

#[program]
pub mod gongbaojeeding {
    use super::*;

    pub fn create(ctx: Context<Initialize>, name: String) -> Result<()> {
        initialize_handler(ctx, name)
    }

    pub fn update(ctx: Context<Update>, exp: Option<u32>, gold: Option<i32>) -> Result<()> {
        update_handler(ctx, exp, gold)
    }
}
