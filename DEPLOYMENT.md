# QentiFi Deployment Guide

This guide covers deploying the complete QentiFi platform to ANDE Network testnet and mainnet.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Smart Contract Deployment](#smart-contract-deployment)
4. [Subgraph Deployment](#subgraph-deployment)
5. [Frontend Deployment](#frontend-deployment)
6. [Post-Deployment Verification](#post-deployment-verification)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

- **Node.js**: v18+ and pnpm
- **Foundry**: Latest version
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **jq**: JSON processor
  ```bash
  sudo apt install jq  # Ubuntu/Debian
  brew install jq      # macOS
  ```
- **Git**: For version control

### Required Accounts

1. **ANDE Network Wallet**: With testnet ANDE tokens
   - Get testnet tokens from faucet: https://faucet.ande.network

2. **WalletConnect Project**:
   - Create at: https://cloud.walletconnect.com/

3. **Pinata Account**: For IPFS
   - Sign up at: https://pinata.cloud/

4. **The Graph**: For subgraph indexing
   - Create account at: https://thegraph.com/

## Environment Setup

### 1. Clone and Install

```bash
# Clone repository
git clone https://github.com/your-org/qentifi.git
cd qentifi

# Install dependencies
pnpm install
```

### 2. Configure Smart Contracts

```bash
cd packages/contracts

# Copy environment template
cp .env.example .env

# Edit .env with your values
nano .env
```

Required variables:
```bash
PRIVATE_KEY=your_private_key_without_0x_prefix
ANDE_RPC_URL=https://rpc-testnet.ande.network

# Optional: Token distribution addresses
COMMUNITY_REWARDS=0x...
DAO_TREASURY=0x...
LIQUIDITY_MINING=0x...
TEAM_AND_ADVISORS=0x...
PUBLIC_SALE=0x...
```

### 3. Configure Frontend

```bash
cd ../../apps/web

# Copy environment template
cp .env.example .env.local

# Edit .env.local
nano .env.local
```

Required variables:
```bash
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
NEXT_PUBLIC_ANDE_CHAIN_ID=42069
NEXT_PUBLIC_ANDE_RPC_URL=https://rpc-testnet.ande.network

# IPFS Configuration
PINATA_JWT=your_pinata_jwt_token
NEXT_PUBLIC_PINATA_GATEWAY=https://gateway.pinata.cloud/ipfs/
```

### 4. Configure Subgraph

```bash
cd ../../packages/subgraph

# Install Graph CLI globally
npm install -g @graphprotocol/graph-cli

# Authenticate with The Graph
graph auth --product hosted-service YOUR_DEPLOY_KEY
```

## Smart Contract Deployment

### 1. Build and Test

```bash
cd packages/contracts

# Build contracts
forge build

# Run tests (should have >95% coverage)
forge test -vvv

# Check coverage
forge coverage
```

### 2. Deploy to Testnet

```bash
# Run automated deployment script
./script/DeployTestnet.sh
```

This script will:
- ✅ Validate environment configuration
- ✅ Build contracts
- ✅ Run all tests
- ✅ Deploy all contracts in correct order
- ✅ Configure contract relationships
- ✅ Save deployment addresses to `deployments/ande-testnet.json`

### 3. Verify Contracts (Optional)

If ANDE has a block explorer with verification support:

```bash
# Set explorer API key in .env
ANDE_EXPLORER_API_KEY=your_api_key

# Run verification script
./script/VerifyContracts.sh
```

### 4. Manual Deployment (Alternative)

If the automated script fails:

```bash
# Deploy contracts one by one
forge script script/DeployAll.s.sol:DeployAll \
  --rpc-url $ANDE_RPC_URL \
  --broadcast \
  --verify \
  -vvvv
```

### Deployed Contracts

After deployment, you'll have:

1. **QentiToken**: Governance token (1B supply)
2. **QentiNFTBadges**: Soulbound achievement NFTs
3. **GamificationHook**: Automatic badge distribution
4. **MemeTokenFactory**: Token creation factory
5. **QentiFiPoolManager**: Uniswap v4 style singleton AMM
6. **StakingVault**: Staking rewards system

## Subgraph Deployment

### 1. Update Configuration

```bash
cd packages/subgraph

# Get factory address from deployment
FACTORY_ADDRESS=$(jq -r '.factory' ../contracts/deployments/ande-testnet.json)

# Update subgraph.yaml
sed -i "s/0x0000000000000000000000000000000000000000/$FACTORY_ADDRESS/g" subgraph.yaml
```

### 2. Generate Code

```bash
# Generate TypeScript types from schema and ABIs
pnpm run codegen
```

### 3. Build Subgraph

```bash
pnpm run build
```

### 4. Deploy Subgraph

For hosted service:
```bash
pnpm run deploy
```

For decentralized network:
```bash
graph deploy --node https://api.thegraph.com/deploy/ \
  --ipfs https://api.thegraph.com/ipfs/ \
  qentifi/qentifi-ande
```

### 5. Verify Subgraph

Once deployed, your subgraph will be available at:
```
https://thegraph.com/hosted-service/subgraph/your-username/qentifi-ande
```

Test with a query:
```graphql
{
  tokens(first: 5, orderBy: marketCap, orderDirection: desc) {
    id
    name
    symbol
    currentPrice
    marketCap
    holders {
      id
    }
  }
}
```

## Frontend Deployment

### 1. Update Contract Addresses

After smart contract deployment, update frontend environment:

```bash
cd apps/web

# Get addresses from deployment
FACTORY=$(jq -r '.factory' ../../packages/contracts/deployments/ande-testnet.json)
POOL_MANAGER=$(jq -r '.poolManager' ../../packages/contracts/deployments/ande-testnet.json)
QENTI_TOKEN=$(jq -r '.qentiToken' ../../packages/contracts/deployments/ande-testnet.json)
STAKING_VAULT=$(jq -r '.stakingVault' ../../packages/contracts/deployments/ande-testnet.json)
NFT_BADGES=$(jq -r '.nftBadges' ../../packages/contracts/deployments/ande-testnet.json)

# Update .env.local
cat >> .env.local << EOF
NEXT_PUBLIC_FACTORY_ADDRESS=$FACTORY
NEXT_PUBLIC_POOL_MANAGER_ADDRESS=$POOL_MANAGER
NEXT_PUBLIC_QENTI_TOKEN_ADDRESS=$QENTI_TOKEN
NEXT_PUBLIC_STAKING_VAULT_ADDRESS=$STAKING_VAULT
NEXT_PUBLIC_NFT_BADGES_ADDRESS=$NFT_BADGES
EOF
```

### 2. Update Subgraph URL

```bash
# Get subgraph URL and add to .env.local
echo "NEXT_PUBLIC_SUBGRAPH_URL=https://api.thegraph.com/subgraphs/name/your-username/qentifi-ande" >> .env.local
```

### 3. Build and Test Locally

```bash
# Build the app
pnpm run build

# Test locally
pnpm run dev

# Open http://localhost:3000
```

### 4. Deploy to Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Follow prompts to link project and deploy
```

Add environment variables in Vercel dashboard:
- Go to Project Settings → Environment Variables
- Add all variables from `.env.local`

### 5. Alternative Deployment Options

**Netlify:**
```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod
```

**Docker:**
```bash
# Build image
docker build -t qentifi-web .

# Run container
docker run -p 3000:3000 qentifi-web
```

## Post-Deployment Verification

### 1. Contract Verification Checklist

- [ ] All contracts deployed successfully
- [ ] Factory can create tokens
- [ ] Bonding curve trades work
- [ ] Pool manager swaps execute
- [ ] Staking deposits/withdrawals work
- [ ] NFT badges mint automatically
- [ ] Token graduation triggers correctly

Test script:
```bash
cd packages/contracts

# Run integration tests
forge test --match-contract Integration -vvv
```

### 2. Frontend Verification Checklist

- [ ] Wallet connects successfully
- [ ] Network switcher shows ANDE testnet
- [ ] Create token page uploads to IPFS
- [ ] Token creation completes on-chain
- [ ] Explore page shows created tokens
- [ ] Token detail page loads chart
- [ ] Buy/sell trades execute
- [ ] User receives NFT badges

### 3. Subgraph Verification Checklist

- [ ] Subgraph syncs to current block
- [ ] Token entities appear in queries
- [ ] Swap events indexed correctly
- [ ] User stats calculate properly
- [ ] Daily stats aggregate

Query to verify:
```graphql
{
  _meta {
    block {
      number
    }
    hasIndexingErrors
  }
  globalStats(id: "global") {
    totalTokens
    totalUsers
    totalSwaps
    totalVolume
  }
}
```

### 4. End-to-End Test

Complete user flow:
1. Connect wallet
2. Create a meme token
3. Verify NFT badge received
4. Trade on bonding curve
5. Add liquidity to pool
6. Stake LP tokens
7. Claim rewards
8. Check leaderboard

## Troubleshooting

### Contract Deployment Issues

**Error: Insufficient funds**
```
Solution: Get testnet ANDE from faucet
https://faucet.ande.network
```

**Error: Nonce too low**
```bash
# Reset account nonce
cast nonce YOUR_ADDRESS --rpc-url $ANDE_RPC_URL
```

**Error: Contract size exceeds limit**
```
Solution: Enable optimizer in foundry.toml
optimizer = true
optimizer_runs = 200
```

### Subgraph Issues

**Error: Failed to deploy**
```bash
# Rebuild from scratch
pnpm run clean
pnpm run codegen
pnpm run build
pnpm run deploy
```

**Subgraph not syncing**
```
- Check start block in subgraph.yaml
- Verify contract address is correct
- Check ABI matches deployed contract
- View logs in Graph Explorer
```

### Frontend Issues

**Wallet not connecting**
```
- Verify WalletConnect project ID
- Check chain ID matches ANDE testnet
- Clear browser cache
- Try different wallet (MetaMask, Rainbow, etc.)
```

**Transactions failing**
```
- Check contract addresses in .env.local
- Verify sufficient ANDE balance
- Increase gas limit
- Check contract is not paused
```

**Charts not loading**
```
- Verify subgraph is synced
- Check CORS settings
- Verify API endpoint URL
- Check browser console for errors
```

## Mainnet Deployment

When ready for mainnet:

### 1. Security Audit

**CRITICAL**: Get professional audits before mainnet:
- Trail of Bits
- OpenZeppelin
- Certora
- Consensys Diligence

### 2. Update Configuration

```bash
# Use mainnet RPC
ANDE_RPC_URL=https://rpc.ande.network

# Update chain ID
NEXT_PUBLIC_ANDE_CHAIN_ID=42070
```

### 3. Deploy with Multisig

For production, use Gnosis Safe or similar:
1. Deploy contracts from multisig
2. Transfer ownership to multisig
3. Set up timelock for critical functions

### 4. Gradual Rollout

1. Deploy to mainnet
2. Create 1-2 test tokens
3. Monitor for 24-48 hours
4. Announce to community
5. Launch officially

## Monitoring and Maintenance

### Contract Events

Monitor using The Graph or direct RPC:
```bash
# Watch for TokenCreated events
cast logs --from-block latest \
  --address $FACTORY_ADDRESS \
  'TokenCreated(address,address,address,string,string,string)' \
  --rpc-url $ANDE_RPC_URL
```

### Health Checks

Set up monitoring for:
- Contract balance levels
- Staking vault rewards
- Pool liquidity
- Gas prices
- Subgraph sync status

### Upgrade Path

For upgradeable contracts (if needed):
1. Use OpenZeppelin UUPS pattern
2. Test upgrades on testnet
3. Announce to community
4. Execute via timelock
5. Verify new implementation

## Support

- **Documentation**: https://docs.qentifi.io
- **Discord**: https://discord.gg/qentifi
- **GitHub Issues**: https://github.com/your-org/qentifi/issues
- **Email**: support@qentifi.io

## License

MIT License - see LICENSE file for details
