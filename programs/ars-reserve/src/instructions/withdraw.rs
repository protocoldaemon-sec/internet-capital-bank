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
pub struct Withdraw<'info> {
    #[account(
        mut,
        seeds = [VAULT_SEED],
        bump = vault.bump,
        constraint = vault.authority == authority.key() @ ReserveError::Unauthorized
    )]
    pub vault: Account<'info, ReserveVault>,
    
    #[account(mut)]
    pub vault_token_account: Account<'info, TokenAccount>,
    
    #[account(mut)]
    pub recipient_token_account: Account<'info, TokenAccount>,
    
    pub authority: Signer<'info>,
    
    pub token_program: Program<'info, Token>,
}

pub fn handler(ctx: Context<Withdraw>, amount: u64) -> Result<()> {
    require!(amount > 0, ReserveError::InvalidAmount);
    require!(
        ctx.accounts.vault_token_account.amount >= amount,
        ReserveError::InsufficientVaultBalance
    );
    
    let vault = &mut ctx.accounts.vault;
    
    // Acquire reentrancy lock
    acquire_lock(&mut vault.locked)?;
    
    // Transfer tokens from vault to recipient
    let seeds = &[VAULT_SEED, &[vault.bump]];
    let signer = &[&seeds[..]];
    
    let cpi_accounts = Transfer {
        from: ctx.accounts.vault_token_account.to_account_info(),
        to: ctx.accounts.recipient_token_account.to_account_info(),
        authority: vault.to_account_info(),
    };
    
    let cpi_program = ctx.accounts.token_program.to_account_info();
    let cpi_ctx = CpiContext::new_with_signer(cpi_program, cpi_accounts, signer);
    
    let result = token::transfer(cpi_ctx, amount);
    
    // Release lock before returning
    release_lock(&mut vault.locked);
    
    result?;
    
    msg!("Withdrawn {} tokens from vault", amount);
    
    Ok(())
}
