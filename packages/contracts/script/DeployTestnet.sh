#!/bin/bash

# QentiFi Deployment Script for ANDE Testnet
# Usage: ./script/DeployTestnet.sh

set -e

echo "🚀 QentiFi Deployment to ANDE Testnet"
echo "======================================"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$ANDE_RPC_URL" ]; then
    echo "❌ ANDE_RPC_URL not set in .env"
    exit 1
fi

echo ""
echo "📋 Pre-deployment Checklist:"
echo "  - Private key configured: ✓"
echo "  - RPC URL configured: ✓"
echo "  - Network: ANDE Testnet"
echo ""

# Create deployments directory if it doesn't exist
mkdir -p deployments

echo "🔨 Building contracts..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"
echo ""

echo "🧪 Running tests..."
forge test

if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Tests passed"
echo ""

echo "📤 Deploying contracts..."
forge script script/DeployAll.s.sol:DeployAll \
    --rpc-url $ANDE_RPC_URL \
    --broadcast \
    --slow \
    -vvvv

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed"
    exit 1
fi

echo ""
echo "✅ Deployment successful!"
echo ""
echo "📝 Deployment addresses saved to: deployments/ande-testnet.json"
echo ""
echo "Next steps:"
echo "  1. Update apps/web/.env with the deployed contract addresses"
echo "  2. Update packages/subgraph/subgraph.yaml with the factory address"
echo "  3. Deploy the subgraph: cd packages/subgraph && pnpm run deploy"
echo "  4. Start the frontend: cd apps/web && pnpm run dev"
echo ""
echo "🎉 Deployment complete!"
