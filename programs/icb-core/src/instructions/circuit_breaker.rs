use anchor_lang::prelude::*;
use crate::state::*;
use crate::constants::*;
use crate::errors::ICBError;

// FIX #7: Split into two instructions - request and activate

#[derive(Accounts)]
pub struct RequestCircuitBreaker<'info> {
    #[account(
        mut,
        seeds = [GLOBAL_STATE_SEED],
        bump = global_state.bump,
        constraint = global_state.authority == authority.key() @ ICBError::Unauthorized
    )]
    pub global_state: Account<'info, GlobalState>,
    
    pub authority: Signer<'info>,
}

pub fn request_circuit_breaker(ctx: Context<RequestCircuitBreaker>) -> Result<()> {
    let global_state = &mut ctx.accounts.global_state;
    let clock = Clock::get()?;
    
    global_state.circuit_breaker_requested_at = clock.unix_timestamp;
    
    msg!("Circuit breaker activation requested at: {}", clock.unix_timestamp);
    msg!("Can be activated after: {}", clock.unix_timestamp + CIRCUIT_BREAKER_DELAY);
    
    Ok(())
}

#[derive(Accounts)]
pub struct ActivateCircuitBreaker<'info> {
    #[account(
        mut,
        seeds = [GLOBAL_STATE_SEED],
        bump = global_state.bump,
        constraint = global_state.authority == authority.key() @ ICBError::Unauthorized
    )]
    pub global_state: Account<'info, GlobalState>,
    
    pub authority: Signer<'info>,
}

pub fn activate_circuit_breaker(ctx: Context<ActivateCircuitBreaker>) -> Result<()> {
    let global_state = &mut ctx.accounts.global_state;
    let clock = Clock::get()?;
    
    // FIX #7: Enforce timelock delay
    require!(
        clock.unix_timestamp >= global_state.circuit_breaker_requested_at + CIRCUIT_BREAKER_DELAY,
        ICBError::CircuitBreakerTimelockNotMet
    );
    
    global_state.circuit_breaker_active = true;
    
    msg!("Circuit breaker ACTIVATED");
    msg!("Requested at: {}", global_state.circuit_breaker_requested_at);
    msg!("Activated at: {}", clock.unix_timestamp);
    
    Ok(())
}

#[derive(Accounts)]
pub struct DeactivateCircuitBreaker<'info> {
    #[account(
        mut,
        seeds = [GLOBAL_STATE_SEED],
        bump = global_state.bump,
        constraint = global_state.authority == authority.key() @ ICBError::Unauthorized
    )]
    pub global_state: Account<'info, GlobalState>,
    
    pub authority: Signer<'info>,
}

pub fn deactivate_circuit_breaker(ctx: Context<DeactivateCircuitBreaker>) -> Result<()> {
    let global_state = &mut ctx.accounts.global_state;
    
    // Deactivation can be immediate (emergency recovery)
    global_state.circuit_breaker_active = false;
    global_state.circuit_breaker_requested_at = 0; // Reset request
    
    msg!("Circuit breaker DEACTIVATED");
    
    Ok(())
}

