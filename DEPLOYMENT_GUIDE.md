# QentiFi Deployment Guide

Complete guide to deploy QentiFi platform to ANDE Network.

## Prerequisites

- Node.js >= 18.0.0
- pnpm >= 8.0.0
- Foundry installed
- ANDE tokens for gas fees
- Private key with funds

---

## Part 1: Smart Contract Deployment

### Step 1: Setup Environment

```bash
# Navigate to contracts
cd packages/contracts

# Copy environment template
cp ../../.env.example .env

# Edit .env with your values:
# ANDE_TESTNET_RPC=https://rpc.testnet.ande.network
# PRIVATE_KEY=your-private-key-here
# ANDESCAN_API_KEY=your-api-key
```

### Step 2: Install Dependencies

```bash
# Install OpenZeppelin contracts
forge install OpenZeppelin/openzeppelin-contracts

# Install forge-std
forge install foundry-rs/forge-std

# Verify installation
forge build
```

### Step 3: Run Tests

```bash
# Run all tests
forge test -vvv

# Check coverage
forge coverage

# Gas report
forge test --gas-report

# Should see:
# ✓ All tests passing
# ✓ Coverage > 95%
```

### Step 4: Deploy to Testnet

```bash
# Deploy contracts
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url ande_testnet \
    --broadcast \
    --verify \
    -vvvv

# Save the output:
# MemeTokenFactory deployed at: 0x...
```

### Step 5: Verify Deployment

```bash
# The deployment info is saved to:
# deployments/31337.json (replace with actual chain ID)

# Verify on ANDEScan
# Visit: https://testnet.andescan.io/address/YOUR_FACTORY_ADDRESS
```

### Step 6: Create Test Token (Optional)

```bash
# Set factory address
export FACTORY_ADDRESS=0xYourFactoryAddress

# Create test token
forge script script/Deploy.s.sol:CreateTestTokenScript \
    --rpc-url ande_testnet \
    --broadcast \
    -vvvv
```

---

## Part 2: Frontend Deployment

### Step 1: Configure Frontend

```bash
# Navigate to frontend
cd ../../apps/web

# Create .env.local
cat > .env.local << EOF
NEXT_PUBLIC_ANDE_RPC_URL=https://rpc.testnet.ande.network
NEXT_PUBLIC_ANDESCAN_URL=https://testnet.andescan.io
NEXT_PUBLIC_FACTORY_ADDRESS=0xYourFactoryAddressFromStep4
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your-walletconnect-id
EOF
```

### Step 2: Get WalletConnect Project ID

```bash
# Visit: https://cloud.walletconnect.com/
# 1. Create account
# 2. Create new project
# 3. Copy Project ID
# 4. Add to .env.local
```

### Step 3: Install Dependencies

```bash
# From root directory
cd ../..
pnpm install
```

### Step 4: Test Locally

```bash
# Start dev server
pnpm dev

# Visit http://localhost:3000
# Connect wallet
# Try creating a token
```

### Step 5: Deploy to Vercel

#### Option A: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
cd apps/web
vercel

# Deploy to production
vercel --prod
```

#### Option B: GitHub Integration

```bash
# 1. Push code to GitHub
git push origin main

# 2. Visit vercel.com
# 3. Import GitHub repository
# 4. Configure:
#    - Framework: Next.js
#    - Root Directory: apps/web
#    - Build Command: pnpm build
#    - Install Command: pnpm install

# 5. Add Environment Variables:
NEXT_PUBLIC_ANDE_RPC_URL=https://rpc.testnet.ande.network
NEXT_PUBLIC_ANDESCAN_URL=https://testnet.andescan.io
NEXT_PUBLIC_FACTORY_ADDRESS=0xYourFactoryAddress
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your-project-id

# 6. Deploy
```

---

## Part 3: Post-Deployment Verification

### Checklist

- [ ] Smart contracts deployed and verified on ANDEScan
- [ ] Factory address saved and configured in frontend
- [ ] Frontend deployed to Vercel
- [ ] Wallet connection works
- [ ] Token creation works (test with 0.01 ANDE)
- [ ] Token appears in Explore page
- [ ] Trading interface functional
- [ ] All links and explorers work

### Test Flow

```bash
# 1. Visit your deployed site
# 2. Connect wallet (MetaMask + ANDE Network)
# 3. Go to /create
# 4. Create test token:
#    - Name: "Test Token"
#    - Symbol: "TEST"
#    - Upload image
#    - Pay 0.01 ANDE
# 5. Verify token appears in /explore
# 6. Click token to see details
# 7. Try buying some tokens
# 8. Try selling tokens
```

---

## Part 4: Mainnet Deployment

### When Ready for Mainnet

**Security Requirements:**
- [ ] Trail of Bits audit completed
- [ ] OpenZeppelin audit completed
- [ ] Certora formal verification
- [ ] Bug bounty program live ($50k+)
- [ ] 2 weeks on testnet without issues
- [ ] Multisig wallet setup (Gnosis Safe 4/7)

### Mainnet Deploy

```bash
# 1. Update .env for mainnet
ANDE_MAINNET_RPC=https://rpc.ande.network
PRIVATE_KEY=your-mainnet-deployer-key

# 2. Deploy with extra caution
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url ande_mainnet \
    --broadcast \
    --verify \
    --slow \
    -vvvv

# 3. Transfer ownership to multisig
cast send $FACTORY_ADDRESS \
    "transferOwnership(address)" \
    $MULTISIG_ADDRESS \
    --rpc-url ande_mainnet \
    --private-key $PRIVATE_KEY

# 4. Update frontend env vars
NEXT_PUBLIC_ANDE_RPC_URL=https://rpc.ande.network
NEXT_PUBLIC_FACTORY_ADDRESS=0xMainnetFactoryAddress

# 5. Deploy frontend to production
vercel --prod
```

---

## Monitoring & Maintenance

### OpenZeppelin Defender

```bash
# 1. Visit: https://defender.openzeppelin.com/
# 2. Create account
# 3. Add contracts:
#    - MemeTokenFactory
#    - Monitor events: TokenCreated, TokenGraduated
# 4. Setup alerts:
#    - Large withdrawals
#    - Ownership changes
#    - Unusual activity
```

### Tenderly

```bash
# 1. Visit: https://tenderly.co/
# 2. Create project "QentiFi"
# 3. Add contracts for monitoring
# 4. Setup alerts and simulations
```

### Analytics

```bash
# Track key metrics:
# - Tokens created per day
# - Trading volume
# - Unique users
# - TVL
# - Gas usage

# Use:
# - Dune Analytics (SQL queries)
# - The Graph (if subgraph deployed)
# - Mixpanel (frontend analytics)
```

---

## Troubleshooting

### Common Issues

#### Contract Deployment Fails

```bash
# Check:
# 1. Sufficient ANDE for gas
cast balance $YOUR_ADDRESS --rpc-url ande_testnet

# 2. RPC is responding
cast block-number --rpc-url ande_testnet

# 3. Private key is correct (test signature)
cast wallet sign "test" --private-key $PRIVATE_KEY
```

#### Frontend Build Fails

```bash
# Clear cache
rm -rf .next node_modules
pnpm install
pnpm build

# Check TypeScript errors
pnpm type-check

# Check environment variables
env | grep NEXT_PUBLIC
```

#### Wallet Won't Connect

```bash
# Verify:
# 1. ANDE Network is added to MetaMask
# 2. Chain ID matches (31337 for testnet)
# 3. RPC URL is accessible
# 4. WalletConnect Project ID is valid
```

#### Transactions Failing

```bash
# Check:
# 1. Sufficient gas
# 2. Contract addresses correct
# 3. ABI matches deployed contract
# 4. Approval for token spending (if selling)
```

---

## Cost Estimates

### Deployment Costs

- **Testnet:**
  - Factory deployment: ~$0 (testnet ANDE is free)
  - Test token creation: ~$0

- **Mainnet:**
  - Factory deployment: ~$5 (at current gas prices)
  - Each token creation: 0.01 ANDE + gas (~$0.10 total)

### Monthly Costs

- Vercel Pro: $20/month
- WalletConnect: Free (< 1M requests)
- Domain (.io): $35/year
- Monitoring (Tenderly): $50/month
- **Total: ~$70/month**

---

## Next Steps

After successful deployment:

1. **Community Building**
   - Launch Discord/Telegram
   - Twitter marketing campaign
   - Incentivize early token creators

2. **Feature Rollout**
   - Enable staking vaults
   - Launch NFT badges
   - Implement leaderboards

3. **Partnerships**
   - Integrate with ANDE ecosystem
   - List on DEX aggregators (1inch, Matcha)
   - Partner with other ANDE projects

4. **Governance**
   - Launch $QENTI token
   - Setup DAO (Snapshot + Tally)
   - Community proposals

---

**Deployment complete! 🎉**

Your QentiFi platform is now live on ANDE Network.

For support, visit: https://github.com/nunalabs/QentiFi/issues
