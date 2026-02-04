use anchor_lang::prelude::*;
use crate::state::*;
use crate::errors::ReserveError;
use crate::instructions::initialize_vault::VAULT_SEED;

/// Reentrancy guard helper
#[inline]
fn acquire_lock(locked: &mut bool) -> Result<()> {
    if *locked {
        return err!(ReserveError::ReentrancyDetected);
    }
    *locked = true;
    Ok(())
}

#[inline]
fn release_lock(locked: &mut bool) {
    *locked = false;
}

#[derive(Accounts)]
pub struct Rebalance<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED],
        bump = vault.bump,
        constraint = vault.authority == authority.key() @ ReserveError::Unauthorized
    )]
    pub vault: Account<'info, ReserveVault>,
    
    pub authority: Signer<'info>,
}

pub fn handler(ctx: Context<Rebalance>) -> Result<()> {
    let vault = &mut ctx.accounts.vault;
    
    // Acquire reentrancy lock
    acquire_lock(&mut vault.locked)?;
    
    let clock = Clock::get()?;
    
    vault.last_rebalance = clock.unix_timestamp;
    
    msg!("Vault rebalanced at: {}", clock.unix_timestamp);
    msg!("Current VHR: {} bps", vault.vhr);
    
    // TODO: Implement actual rebalancing logic
    // This would involve:
    // 1. Calculate current asset weights
    // 2. Compare with target weights
    // 3. Execute swaps via Jupiter
    // 4. Update vault composition
    
    // Release lock before returning
    release_lock(&mut vault.locked);
    
    Ok(())
}
