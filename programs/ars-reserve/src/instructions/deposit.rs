use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer};
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
pub struct Deposit<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED],
        bump = vault.bump
    )]
    pub vault: Account<'info, ReserveVault>,
    
    #[account(mut)]
    pub vault_token_account: Account<'info, TokenAccount>,
    
    #[account(mut)]
    pub depositor_token_account: Account<'info, TokenAccount>,
    
    pub depositor: Signer<'info>,
    
    pub token_program: Program<'info, Token>,
}

pub fn handler(ctx: Context<Deposit>, amount: u64) -> Result<()> {
    require!(amount > 0, ReserveError::InvalidAmount);
    
    let vault = &mut ctx.accounts.vault;
    
    // Acquire reentrancy lock
    acquire_lock(&mut vault.locked)?;
    
    // Transfer tokens from depositor to vault
    let cpi_accounts = Transfer {
        from: ctx.accounts.depositor_token_account.to_account_info(),
        to: ctx.accounts.vault_token_account.to_account_info(),
        authority: ctx.accounts.depositor.to_account_info(),
    };
    
    let cpi_program = ctx.accounts.token_program.to_account_info();
    let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
    
    let result = token::transfer(cpi_ctx, amount);
    
    // Release lock before returning
    release_lock(&mut vault.locked);
    
    result?;
    
    msg!("Deposited {} tokens to vault", amount);
    
    Ok(())
}
