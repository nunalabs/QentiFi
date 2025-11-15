#!/bin/bash

# Verify all deployed contracts on ANDE block explorer
# Usage: ./script/VerifyContracts.sh

set -e

echo "🔍 Verifying QentiFi Contracts on ANDE Testnet"
echo "=============================================="

# Load environment variables
source .env

# Load deployment addresses
if [ ! -f deployments/ande-testnet.json ]; then
    echo "❌ deployments/ande-testnet.json not found. Deploy contracts first."
    exit 1
fi

# Parse JSON (requires jq)
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed. Install with: sudo apt install jq"
    exit 1
fi

QENTI_TOKEN=$(jq -r '.qentiToken' deployments/ande-testnet.json)
NFT_BADGES=$(jq -r '.nftBadges' deployments/ande-testnet.json)
GAMIFICATION_HOOK=$(jq -r '.gamificationHook' deployments/ande-testnet.json)
FACTORY=$(jq -r '.factory' deployments/ande-testnet.json)
POOL_MANAGER=$(jq -r '.poolManager' deployments/ande-testnet.json)
STAKING_VAULT=$(jq -r '.stakingVault' deployments/ande-testnet.json)

echo "📋 Contract Addresses:"
echo "  QentiToken: $QENTI_TOKEN"
echo "  NFTBadges: $NFT_BADGES"
echo "  GamificationHook: $GAMIFICATION_HOOK"
echo "  Factory: $FACTORY"
echo "  PoolManager: $POOL_MANAGER"
echo "  StakingVault: $STAKING_VAULT"
echo ""

# Check if explorer API is available
if [ -z "$ANDE_EXPLORER_API_KEY" ]; then
    echo "⚠️  ANDE_EXPLORER_API_KEY not set. Skipping verification."
    echo "    If ANDE has a block explorer API, add the key to .env"
    exit 0
fi

echo "🔍 Verifying contracts..."

# Verify QentiToken
echo "Verifying QentiToken..."
forge verify-contract $QENTI_TOKEN \
    src/QentiToken.sol:QentiToken \
    --chain-id 42069 \
    --etherscan-api-key $ANDE_EXPLORER_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" \
        $COMMUNITY_REWARDS $DAO_TREASURY $LIQUIDITY_MINING $TEAM_AND_ADVISORS $PUBLIC_SALE)

# Verify NFTBadges
echo "Verifying QentiNFTBadges..."
forge verify-contract $NFT_BADGES \
    src/QentiNFTBadges.sol:QentiNFTBadges \
    --chain-id 42069 \
    --etherscan-api-key $ANDE_EXPLORER_API_KEY

# Verify GamificationHook
echo "Verifying GamificationHook..."
forge verify-contract $GAMIFICATION_HOOK \
    src/GamificationHook.sol:GamificationHook \
    --chain-id 42069 \
    --etherscan-api-key $ANDE_EXPLORER_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address)" $NFT_BADGES)

# Verify Factory
echo "Verifying MemeTokenFactory..."
forge verify-contract $FACTORY \
    src/MemeTokenFactory.sol:MemeTokenFactory \
    --chain-id 42069 \
    --etherscan-api-key $ANDE_EXPLORER_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address)" $(cast wallet address))

# Verify PoolManager
echo "Verifying QentiFiPoolManager..."
forge verify-contract $POOL_MANAGER \
    src/QentiFiPoolManager.sol:QentiFiPoolManager \
    --chain-id 42069 \
    --etherscan-api-key $ANDE_EXPLORER_API_KEY

# Verify StakingVault
echo "Verifying StakingVault..."
forge verify-contract $STAKING_VAULT \
    src/StakingVault.sol:StakingVault \
    --chain-id 42069 \
    --etherscan-api-key $ANDE_EXPLORER_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address)" $QENTI_TOKEN)

echo ""
echo "✅ Verification complete!"
