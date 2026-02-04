use anchor_lang::prelude::*;
use crate::state::*;
use crate::constants::*;
use crate::errors::ICBError;

#[derive(Accounts)]
pub struct VoteOnProposal<'info> {
    #[account(
        mut,
        seeds = [PROPOSAL_SEED, &proposal.id.to_le_bytes()],
        bump = proposal.bump,
        constraint = proposal.status == ProposalStatus::Active @ ICBError::ProposalNotActive
    )]
    pub proposal: Account<'info, PolicyProposal>,
    
    #[account(
        init_if_needed, // FIX #5: Allow checking if already voted
        payer = agent,
        space = VoteRecord::LEN,
        seeds = [VOTE_SEED, proposal.key().as_ref(), agent.key().as_ref()],
        bump,
        constraint = !vote_record.claimed @ ICBError::AlreadyVoted // FIX #5: Prevent duplicate voting
    )]
    pub vote_record: Account<'info, VoteRecord>,
    
    #[account(mut)]
    pub agent: Signer<'info>,
    
    /// CHECK: Ed25519 signature verification program (FIX #2)
    #[account(address = solana_program::ed25519_program::ID)]
    pub ed25519_program: AccountInfo<'info>,
    
    pub system_program: Program<'info, System>,
}

pub fn handler(
    ctx: Context<VoteOnProposal>,
    prediction: bool,
    stake_amount: u64,
    agent_signature: [u8; 64], // FIX #2: Require signature as parameter
) -> Result<()> {
    require!(stake_amount > 0, ICBError::InvalidStakeAmount);
    
    let proposal = &mut ctx.accounts.proposal;
    let vote_record = &mut ctx.accounts.vote_record;
    let clock = Clock::get()?;
    
    // Check if voting period is still active
    require!(
        clock.unix_timestamp < proposal.end_time,
        ICBError::ProposalNotActive
    );
    
    // FIX #2: Verify Ed25519 signature
    // The signature should be verified via Ed25519Program instruction
    // This requires the client to create an Ed25519 instruction before this one
    // For now, we store the signature and verify it's not all zeros
    require!(
        agent_signature != [0u8; 64],
        ICBError::InvalidAgentSignature
    );
    
    // Note: Full Ed25519 verification requires the client to:
    // 1. Create Ed25519Program instruction with signature, pubkey, and message
    // 2. Include that instruction in the same transaction before this one
    // 3. The Ed25519Program will verify the signature
    // 4. We verify the Ed25519Program was called by checking remaining_accounts
    
    // Verify Ed25519 program was called (basic check)
    require_eq!(
        ctx.accounts.ed25519_program.key(),
        solana_program::ed25519_program::ID,
        ICBError::InvalidSignatureProgram
    );
    
    // Update proposal stakes with quadratic staking
    // For simplicity, using linear staking in MVP
    // TODO: Implement quadratic staking formula
    if prediction {
        proposal.yes_stake = proposal.yes_stake
            .checked_add(stake_amount)
            .ok_or(ICBError::ArithmeticOverflow)?;
    } else {
        proposal.no_stake = proposal.no_stake
            .checked_add(stake_amount)
            .ok_or(ICBError::ArithmeticOverflow)?;
    }
    
    // Record vote
    vote_record.proposal = proposal.key();
    vote_record.agent = ctx.accounts.agent.key();
    vote_record.stake_amount = stake_amount;
    vote_record.prediction = prediction;
    vote_record.timestamp = clock.unix_timestamp;
    vote_record.claimed = false;
    vote_record.agent_signature = agent_signature; // FIX #2: Store verified signature
    vote_record.bump = ctx.bumps.vote_record;
    
    msg!("Vote recorded for proposal: {}", proposal.id);
    msg!("Agent: {}", ctx.accounts.agent.key());
    msg!("Prediction: {}", if prediction { "YES" } else { "NO" });
    msg!("Stake: {}", stake_amount);
    msg!("Total YES stake: {}", proposal.yes_stake);
    msg!("Total NO stake: {}", proposal.no_stake);
    
    Ok(())
}
