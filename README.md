# QentiFi - DeFi Hybrid Platform on ANDE Network 🐕

> Named after the Peruvian Hairless Dog ("Qenti" in Quechua), a symbol of Andean tradition, nobility, and cultural roots.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue)](https://www.typescriptlang.org/)
[![Foundry](https://img.shields.io/badge/Foundry-Latest-red)](https://getfoundry.sh/)

QentiFi is a **modular, scalable, and premium** DeFi platform built on ANDE Network, designed to unite meme token creation, DeFi trading, cultural gamification, and Web3 community engagement.

## 🌟 Key Features

- **🎨 Meme Token Creator** - Fair launch via bonding curves (Pump.fun pattern)
- **💱 Swap/AMM** - Uniswap v4 hooks system with concentrated liquidity
- **💰 Liquidity Mining** - GMX v2 isolated pools + GLV vaults
- **🎮 Gamification** - NFT badges, leaderboards, cultural quests
- **🔐 Account Abstraction** - ERC-4337 (gasless, social recovery)
- **🌐 Cross-Chain Ready** - LayerZero integration (Phase 3)

## 🏗️ Architecture

```
qentifi-monorepo/
├── apps/
│   ├── web/                 # Next.js 14 frontend
│   └── docs/                # Documentation site
├── packages/
│   ├── contracts/           # Foundry smart contracts
│   ├── subgraph/           # The Graph indexer
│   ├── ui/                 # shadcn/ui components
│   ├── config/             # Shared configs
│   └── types/              # TypeScript types
├── services/
│   ├── api-gateway/        # NestJS REST + GraphQL
│   ├── indexer/            # Event indexer
│   └── rewards/            # Gamification service
└── turbo.json
```

## 🚀 Tech Stack

### Smart Contracts
- **Framework:** Foundry + Hardhat
- **Language:** Solidity 0.8.24+
- **Libraries:** OpenZeppelin, Uniswap v4 hooks
- **Testing:** Foundry (fuzz + invariant)
- **Security:** Certora formal verification

### Frontend
- **Framework:** Next.js 14 (App Router)
- **Web3:** Viem + Wagmi 2.0 + RainbowKit
- **UI:** Tailwind CSS + shadcn/ui
- **State:** Zustand + TanStack Query
- **Wallet:** ERC-4337 Account Abstraction

### Backend
- **Framework:** NestJS microservices
- **Indexing:** The Graph Protocol
- **Database:** PostgreSQL + Redis
- **API:** REST + GraphQL (Apollo)

### Infrastructure
- **Monorepo:** Turborepo + pnpm
- **Hosting:** Vercel (frontend) + Railway (backend)
- **Monitoring:** Sentry + Tenderly + OZ Defender

## 📦 Installation

### Prerequisites

- Node.js >= 18.0.0
- pnpm >= 8.0.0
- Foundry ([installation guide](https://book.getfoundry.sh/getting-started/installation))

### Setup

```bash
# Clone repository
git clone https://github.com/nunalabs/QentiFi.git
cd QentiFi

# Install dependencies
pnpm install

# Setup environment variables
cp .env.example .env.local

# Start development
pnpm dev
```

## 🛠️ Development

### Smart Contracts

```bash
# Run tests
pnpm contracts:test

# Deploy to testnet
pnpm contracts:deploy --network ande-testnet

# Generate coverage
forge coverage

# Run fuzz tests
forge test --fuzz-runs 10000
```

### Frontend

```bash
# Start dev server
cd apps/web
pnpm dev

# Build for production
pnpm build

# Run tests
pnpm test
```

### Backend Services

```bash
# Start all services
cd services
pnpm dev

# Start specific service
cd services/api-gateway
pnpm dev
```

## 🧪 Testing

```bash
# Run all tests
pnpm test

# Smart contract tests
pnpm contracts:test

# Frontend tests
pnpm --filter @qentifi/web test

# E2E tests
pnpm test:e2e
```

## 📊 Project Status

### Phase 1: MVP (Months 1-4) - 🚧 In Progress
- [x] Research & architecture design
- [x] Monorepo setup
- [ ] Smart contracts core
- [ ] Frontend implementation
- [ ] Testnet deployment

### Phase 2: DeFi Expansion (Months 5-8) - 📋 Planned
- [ ] Staking vaults
- [ ] Liquidity mining
- [ ] The Graph subgraph
- [ ] NFT badges & gamification
- [ ] Mainnet launch

### Phase 3: Advanced Features (Months 9-12) - 📋 Planned
- [ ] Account Abstraction (ERC-4337)
- [ ] Lending/Borrowing
- [ ] DAO governance
- [ ] Cross-chain (LayerZero)

## 🔒 Security

- **Audits:** Trail of Bits + OpenZeppelin
- **Formal Verification:** Certora Prover
- **Bug Bounty:** $50k+ on Immunefi
- **Monitoring:** OpenZeppelin Defender + Forta Network

## 📚 Documentation

- [Research Findings](./QENTIFI_RESEARCH_FINDINGS.md)
- [Architecture Diagrams](./ARCHITECTURE_DIAGRAMS.md)
- [Tech Decision Matrix](./TECH_DECISION_MATRIX.md)
- [Smart Contracts Docs](./packages/contracts/README.md)
- [Frontend Docs](./apps/web/README.md)

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

## 🌐 Links

- Website: [qentifi.io](https://qentifi.io) (coming soon)
- Twitter: [@QentiFi](https://twitter.com/QentiFi)
- Discord: [discord.gg/qentifi](https://discord.gg/qentifi)
- ANDE Network: [ande.network](https://ande.network)

## 💡 Inspiration

QentiFi draws inspiration from:
- **Uniswap v4** - Modular hooks architecture
- **Pump.fun** - Fair launch bonding curves
- **Aave v3** - Modular DeFi patterns
- **Curve Finance** - Liquidity optimization
- **GMX v2** - Isolated pools and vaults

---

**Built with ❤️ by the QentiFi team | Powered by ANDE Network**