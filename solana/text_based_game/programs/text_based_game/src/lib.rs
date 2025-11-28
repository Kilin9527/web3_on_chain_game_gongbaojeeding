pub mod constants;
pub mod error;
pub mod instructions;
pub mod state;

use anchor_lang::prelude::*;

pub use constants::*;
pub use instructions::*;
pub use state::*;

declare_id!("BGQP5xC8dFX8KyDXSWdBBm5g8sVAYfg2ESPrChxyoBqt");

#[program]
pub mod text_based_game {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, name: String) -> Result<()> {
        initialize_handler(ctx, name)
    }

    pub fn update_gold(ctx: Context<UpdateGold>, gold: i32) -> Result<()> {
        update_gold_handler(ctx, gold)
    }

    pub fn update_exp(ctx: Context<UpdateExp>, exp: u32) -> Result<()> {
        update_exp_handler(ctx, exp)
    }
}
