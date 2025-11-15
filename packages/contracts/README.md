# @qentifi/contracts

Smart contracts for QentiFi platform built with Foundry and Solidity 0.8.24+.

## Architecture

### Core Contracts

- **MemeTokenFactory.sol** - Factory for creating meme tokens with bonding curves
- **BondingCurveAMM.sol** - Automated Market Maker using bonding curve mechanism
- **QentiFiPoolManager.sol** - Singleton pattern pool manager (Uniswap v4 inspired)
- **QentiFiHooks.sol** - Base hooks system for customization

### Token Contracts

- **QentiToken.sol** - ERC-20 governance token
- **MemeToken.sol** - Standard ERC-20 for created memes
- **QentiNFTBadges.sol** - ERC-721 for gamification achievements

### DeFi Modules

- **StakingVault.sol** - Single/multi-asset staking
- **LiquidityMining.sol** - LP rewards distribution
- **IsolatedPool.sol** - GMX v2 pattern isolated liquidity pools

## Installation

```bash
# Install Foundry (if not already installed)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts
forge install Uniswap/v4-core
forge install foundry-rs/forge-std
```

## Testing

```bash
# Run all tests
forge test -vvv

# Run with gas report
forge test --gas-report

# Run fuzz tests (10000 runs)
forge test --fuzz-runs 10000

# Generate coverage report
forge coverage

# Snapshot gas costs
forge snapshot
```

## Deployment

### Testnet

```bash
# Set environment variables
export ANDE_TESTNET_RPC="https://rpc.testnet.ande.network"
export PRIVATE_KEY="your-private-key"
export ANDESCAN_API_KEY="your-api-key"

# Deploy
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url ande_testnet \
    --broadcast \
    --verify
```

### Mainnet

```bash
# Set environment variables
export ANDE_MAINNET_RPC="https://rpc.ande.network"
export PRIVATE_KEY="your-private-key"

# Deploy (with extra safety)
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url ande_mainnet \
    --broadcast \
    --verify \
    --slow
```

## Security

### Pre-Deployment Checklist

- [ ] Run all tests with 100% pass rate
- [ ] Achieve >95% code coverage
- [ ] Run Slither static analysis
- [ ] Perform fuzz testing (10,000+ runs)
- [ ] Conduct manual code review
- [ ] Get external audit (Trail of Bits + OpenZeppelin)
- [ ] Run Certora formal verification
- [ ] Deploy to testnet and test thoroughly
- [ ] Set up bug bounty program
- [ ] Configure monitoring (OpenZeppelin Defender)

### Static Analysis

```bash
# Install Slither
pip3 install slither-analyzer

# Run analysis
slither . --solc-remaps '@openzeppelin/=lib/openzeppelin-contracts/ @uniswap/v4-core/=lib/v4-core/'
```

## Gas Optimization

Foundry will automatically generate gas reports. Key optimizations implemented:

- ✅ Singleton pattern (99% deployment cost reduction)
- ✅ Flash accounting system
- ✅ Storage packing (uint256 → uint128 where possible)
- ✅ Batch operations
- ✅ Efficient loops and data structures

## Contract Addresses

### ANDE Testnet

- QentiFiPoolManager: `TBD`
- MemeTokenFactory: `TBD`
- BondingCurveAMM: `TBD`
- QentiToken: `TBD`
- QentiNFTBadges: `TBD`

### ANDE Mainnet

- Coming soon after audit

## License

MIT
