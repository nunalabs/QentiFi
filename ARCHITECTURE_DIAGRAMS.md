# QentiFi - Diagramas de Arquitectura Visual

## 1. Arquitectura General del Sistema

```mermaid
graph TB
    subgraph "User Layer"
        USER[👤 Usuario]
        WALLET[🔐 Smart Wallet<br/>ERC-4337]
    end

    subgraph "Frontend Layer - Next.js 14"
        WEB[🌐 Web App<br/>Next.js + Tailwind]
        MOBILE[📱 Mobile PWA<br/>Progressive Web App]
        WAGMI[⚡ Wagmi + Viem<br/>Web3 Integration]
        RAINBOW[🌈 RainbowKit<br/>Wallet Connection]
    end

    subgraph "Backend Layer - NestJS Microservices"
        GATEWAY[🚪 API Gateway<br/>REST + GraphQL]
        INDEXER[📊 Indexer Service<br/>Event Monitoring]
        REWARDS[🎁 Rewards Service<br/>Gamification]
        ANALYTICS[📈 Analytics Service<br/>Charts & Stats]
        ORACLE[🔮 Price Oracle<br/>Chainlink + TWAP]
    end

    subgraph "Data Layer"
        GRAPH[📊 The Graph<br/>Subgraph Indexing]
        POSTGRES[(🗄️ PostgreSQL<br/>Relational Data)]
        REDIS[(⚡ Redis<br/>Cache + Queue)]
    end

    subgraph "ANDE Network - EVM Layer"
        POOL_MGR[🏊 PoolManager<br/>Singleton Pattern]
        BONDING[📈 Bonding Curve<br/>Fair Launch AMM]
        FACTORY[🏭 Token Factory<br/>Meme Creation]
        HOOKS[🪝 Hooks System<br/>Custom Logic]
        STAKING[💰 Staking Vaults<br/>Rewards]
        NFT[🖼️ NFT Badges<br/>Achievements]
        GOV[🗳️ Governance<br/>DAO Voting]
    end

    subgraph "Data Availability"
        CELESTIA[☁️ Celestia DA<br/>Data Layer]
    end

    USER --> WALLET
    WALLET --> WEB
    WALLET --> MOBILE
    WEB --> WAGMI
    MOBILE --> WAGMI
    WAGMI --> RAINBOW
    RAINBOW --> GATEWAY

    GATEWAY --> INDEXER
    GATEWAY --> REWARDS
    GATEWAY --> ANALYTICS
    GATEWAY --> ORACLE

    INDEXER --> GRAPH
    REWARDS --> REDIS
    ANALYTICS --> POSTGRES

    GRAPH --> POOL_MGR
    GRAPH --> BONDING
    GRAPH --> FACTORY

    WAGMI --> POOL_MGR
    WAGMI --> BONDING
    WAGMI --> FACTORY
    WAGMI --> STAKING
    WAGMI --> NFT
    WAGMI --> GOV

    POOL_MGR --> HOOKS
    BONDING --> HOOKS

    POOL_MGR --> CELESTIA
    BONDING --> CELESTIA
    FACTORY --> CELESTIA
```

---

## 2. Flujo de Usuario: Creación de Meme Token

```mermaid
sequenceDiagram
    actor User
    participant Wallet as Smart Wallet<br/>(ERC-4337)
    participant Frontend as Next.js App
    participant Factory as TokenFactory
    participant Bonding as BondingCurve
    participant Hook as GamificationHook
    participant NFT as NFTBadges
    participant Graph as The Graph

    User->>Wallet: 1. Connect Wallet
    Wallet->>Frontend: Account Connected

    User->>Frontend: 2. Create Meme Token<br/>(name, symbol, image)
    Frontend->>Wallet: Request Signature
    Wallet->>Factory: createToken(params)

    Factory->>Bonding: Deploy Bonding Curve
    Bonding-->>Factory: Curve Address

    Factory->>Hook: beforeMint(creator, params)
    Hook->>NFT: Check if first token
    NFT-->>Hook: isFirstToken = true
    Hook->>NFT: mintBadge(FIRST_CREATOR)

    Factory-->>Frontend: Token Created ✅
    Frontend->>Graph: Index New Token

    Graph-->>Frontend: Token Data
    Frontend->>User: Show Token Page 🎉

    Note over User,Graph: Usuario recibe NFT badge<br/>automáticamente!
```

---

## 3. Flujo de Swap con Hooks Modulares

```mermaid
sequenceDiagram
    actor Trader
    participant UI as Swap UI
    participant PoolMgr as PoolManager<br/>(Singleton)
    participant BeforeHook as beforeSwap Hooks
    participant Pool as Liquidity Pool
    participant AfterHook as afterSwap Hooks
    participant Rewards as Rewards Service

    Trader->>UI: 1. Enter swap<br/>100 MEME → ? ANDE
    UI->>PoolMgr: getQuote(tokenIn, tokenOut, amount)
    PoolMgr-->>UI: 50 ANDE (with 0.3% fee)

    Trader->>UI: 2. Confirm Swap
    UI->>PoolMgr: swap(params)

    PoolMgr->>BeforeHook: beforeSwap(trader, params)

    Note over BeforeHook: Hook 1: Anti-MEV Check<br/>Hook 2: Dynamic Fee Adjust<br/>Hook 3: Whitelist Verify

    BeforeHook-->>PoolMgr: ✅ Hooks Passed

    PoolMgr->>Pool: Execute Swap
    Pool-->>PoolMgr: Swap Complete

    PoolMgr->>AfterHook: afterSwap(trader, result)

    Note over AfterHook: Hook 1: Track Volume<br/>Hook 2: Update Leaderboard<br/>Hook 3: Check Badge Unlock

    AfterHook->>Rewards: updateTraderStats(volume)
    Rewards-->>AfterHook: Badge Unlocked: VOLUME_KING

    AfterHook-->>PoolMgr: ✅ Post-process Done
    PoolMgr-->>UI: Swap Success + Badge Earned 🏆
```

---

## 4. Arquitectura de Smart Contracts (Modular)

```mermaid
graph LR
    subgraph "Core Contracts"
        PM[PoolManager<br/>Singleton]
        BC[BondingCurve<br/>AMM]
        TF[TokenFactory]
        IP[IsolatedPools]
        GLV[GLV Vaults]
    end

    subgraph "Hook Contracts"
        H1[TWAMM Hook]
        H2[Gamification Hook]
        H3[Anti-Rug Hook]
        H4[Cultural Quests Hook]
        H5[Dynamic Fee Hook]
    end

    subgraph "Token Contracts"
        MT[Meme Tokens<br/>ERC-20]
        NFT[NFT Badges<br/>ERC-721]
        QENTI[QENTI Token<br/>Governance]
    end

    subgraph "DeFi Modules"
        STAKE[Staking Vaults]
        LM[Liquidity Mining]
        LEND[Lending<br/>Future]
        PERP[Perpetuals<br/>Future]
    end

    subgraph "Governance"
        GOV[Governor Contract<br/>OpenZeppelin]
        TLOCK[Timelock<br/>2-day delay]
    end

    PM --> H1
    PM --> H2
    PM --> H3
    PM --> H4
    PM --> H5

    BC --> PM
    TF --> MT
    IP --> PM
    GLV --> IP

    H2 --> NFT

    STAKE --> QENTI
    LM --> QENTI

    GOV --> QENTI
    GOV --> TLOCK
    TLOCK --> PM
    TLOCK --> BC

    style PM fill:#ff6b6b
    style BC fill:#4ecdc4
    style TF fill:#ffe66d
    style H2 fill:#a8e6cf
    style NFT fill:#ff8b94
```

---

## 5. Sistema de Gamificación & Rewards

```mermaid
graph TD
    USER[👤 Usuario]

    subgraph "Acciones"
        A1[Crear Token]
        A2[Proveer Liquidez]
        A3[Swap Trading]
        A4[Completar Quest]
        A5[Referir Amigos]
    end

    subgraph "Event Tracking"
        HOOK[Gamification Hook]
        INDEXER[Indexer Service]
    end

    subgraph "Rewards Engine"
        RULES[Rules Engine<br/>Badge Unlock Logic]
        LEADER[Leaderboard<br/>Rankings]
        XP[XP System]
    end

    subgraph "Rewards Distribution"
        BADGE[NFT Badge Mint]
        TOKEN[QENTI Airdrop]
        DISCOUNT[Fee Discount]
        BOOST[LP Boost 2x]
    end

    USER --> A1
    USER --> A2
    USER --> A3
    USER --> A4
    USER --> A5

    A1 --> HOOK
    A2 --> HOOK
    A3 --> HOOK
    A4 --> INDEXER
    A5 --> INDEXER

    HOOK --> RULES
    INDEXER --> RULES

    RULES --> XP
    RULES --> LEADER

    XP --> BADGE
    LEADER --> TOKEN
    LEADER --> DISCOUNT
    LEADER --> BOOST

    BADGE --> USER
    TOKEN --> USER
    DISCOUNT --> USER
    BOOST --> USER

    style USER fill:#ffd93d
    style RULES fill:#6bcf7f
    style BADGE fill:#ff8fab
    style TOKEN fill:#4d96ff
```

---

## 6. Bonding Curve Fair Launch Mechanism

```mermaid
graph LR
    subgraph "Phase 1: Bonding Curve"
        CREATE[Token Created<br/>Supply: 0]
        BUY1[Early Buyers<br/>$0.0001/token]
        BUY2[More Buyers<br/>$0.001/token]
        BUY3[Price Rises<br/>$0.01/token]
        THRESHOLD[Threshold Reached<br/>$50k Volume]
    end

    subgraph "Phase 2: DEX Migration"
        MIGRATE[Auto Migration]
        LOCK[Lock Liquidity]
        DEX[Listed on DEX<br/>Price Discovery]
    end

    subgraph "Price Chart"
        CHART[📈 Price vs Supply<br/>Exponential Curve]
    end

    CREATE --> BUY1
    BUY1 --> BUY2
    BUY2 --> BUY3
    BUY3 --> THRESHOLD

    THRESHOLD --> MIGRATE
    MIGRATE --> LOCK
    LOCK --> DEX

    BUY1 -.-> CHART
    BUY2 -.-> CHART
    BUY3 -.-> CHART

    style CREATE fill:#fff4a3
    style THRESHOLD fill:#ff8906
    style DEX fill:#4caf50
    style CHART fill:#2196f3
```

---

## 7. Multi-Layer Security Architecture

```mermaid
graph TB
    subgraph "Development Phase"
        CODE[Smart Contract Code]
        LINT[Solhint Linter]
        STATIC[Slither Analysis]
        TEST[Foundry Tests<br/>Fuzz + Invariant]
    end

    subgraph "Pre-Deployment"
        AUDIT1[Trail of Bits<br/>Manual Audit]
        AUDIT2[OpenZeppelin<br/>Audit]
        FORMAL[Certora<br/>Formal Verification]
        BOUNTY[Bug Bounty<br/>$50k]
    end

    subgraph "Deployment"
        TESTNET[ANDE Testnet<br/>Public Beta]
        MULTISIG[Gnosis Safe<br/>4/7 Multisig]
        MAINNET[ANDE Mainnet]
    end

    subgraph "Runtime Monitoring"
        DEFENDER[OZ Defender<br/>Automated Alerts]
        FORTA[Forta Network<br/>Threat Detection]
        TENDERLY[Tenderly<br/>TX Simulation]
    end

    CODE --> LINT
    LINT --> STATIC
    STATIC --> TEST

    TEST --> AUDIT1
    TEST --> AUDIT2
    TEST --> FORMAL

    AUDIT1 --> BOUNTY
    AUDIT2 --> BOUNTY
    FORMAL --> BOUNTY

    BOUNTY --> TESTNET
    TESTNET --> MULTISIG
    MULTISIG --> MAINNET

    MAINNET --> DEFENDER
    MAINNET --> FORTA
    MAINNET --> TENDERLY

    style FORMAL fill:#00c853
    style MULTISIG fill:#ff6d00
    style MAINNET fill:#d50000
```

---

## 8. Monorepo Structure (Turborepo + pnpm)

```mermaid
graph TD
    ROOT[qentifi-monorepo]

    subgraph "apps/"
        WEB[web - Next.js]
        MOBILE[mobile - React Native]
        DOCS[docs - Nextra]
        LANDING[landing - Marketing]
    end

    subgraph "packages/"
        CONTRACTS[contracts - Foundry]
        SUBGRAPH[subgraph - The Graph]
        UI[ui - Component Library]
        HOOKS[hooks - React Hooks]
        CONFIG[config - Chains/ABIs]
        UTILS[utils - Shared Code]
    end

    subgraph "services/"
        GATEWAY[api-gateway - NestJS]
        INDEXER[indexer - NestJS]
        REWARDS[rewards - NestJS]
        ANALYTICS[analytics - NestJS]
    end

    ROOT --> WEB
    ROOT --> MOBILE
    ROOT --> DOCS
    ROOT --> LANDING

    ROOT --> CONTRACTS
    ROOT --> SUBGRAPH
    ROOT --> UI
    ROOT --> HOOKS
    ROOT --> CONFIG
    ROOT --> UTILS

    ROOT --> GATEWAY
    ROOT --> INDEXER
    ROOT --> REWARDS
    ROOT --> ANALYTICS

    WEB -.depends on.-> UI
    WEB -.depends on.-> HOOKS
    WEB -.depends on.-> CONFIG
    WEB -.depends on.-> UTILS

    MOBILE -.depends on.-> UI
    MOBILE -.depends on.-> HOOKS

    GATEWAY -.depends on.-> CONFIG
    INDEXER -.depends on.-> CONFIG

    style ROOT fill:#1976d2
    style WEB fill:#4caf50
    style CONTRACTS fill:#ff9800
```

---

## 9. Data Flow: The Graph Indexing

```mermaid
sequenceDiagram
    participant SC as Smart Contracts<br/>(ANDE Network)
    participant NODE as Graph Node
    participant IPFS as IPFS
    participant POSTGRES as PostgreSQL
    participant API as GraphQL API
    participant CLIENT as Frontend Client

    SC->>NODE: 1. Emit Events<br/>(TokenCreated, Swap, etc)
    NODE->>IPFS: 2. Fetch Subgraph Manifest
    IPFS-->>NODE: subgraph.yaml

    NODE->>SC: 3. Subscribe to Events
    SC-->>NODE: Event Data

    NODE->>NODE: 4. Run Mappings<br/>(TypeScript handlers)
    NODE->>POSTGRES: 5. Store Entities

    CLIENT->>API: 6. GraphQL Query

    Note over CLIENT,API: query {<br/>  tokens(orderBy: volume) {<br/>    name, symbol, marketCap<br/>  }<br/>}

    API->>POSTGRES: 7. Fetch Data
    POSTGRES-->>API: Query Result
    API-->>CLIENT: 8. JSON Response

    CLIENT->>CLIENT: 9. Render UI
```

---

## 10. Cross-Chain Architecture (Future - Phase 3)

```mermaid
graph TB
    subgraph "ANDE Network - Home Chain"
        ANDE_POOL[PoolManager]
        ANDE_TOKEN[MEME Tokens]
        ANDE_BRIDGE[LayerZero Endpoint]
    end

    subgraph "Arbitrum - L2"
        ARB_POOL[PoolManager]
        ARB_TOKEN[Wrapped MEME]
        ARB_BRIDGE[LayerZero Endpoint]
    end

    subgraph "Base - L2"
        BASE_POOL[PoolManager]
        BASE_TOKEN[Wrapped MEME]
        BASE_BRIDGE[LayerZero Endpoint]
    end

    subgraph "LayerZero Network"
        RELAYER[Relayer Network]
        ORACLE[Oracle Network]
        VALIDATOR[Ultra Light Node]
    end

    ANDE_BRIDGE <--> RELAYER
    ARB_BRIDGE <--> RELAYER
    BASE_BRIDGE <--> RELAYER

    RELAYER <--> ORACLE
    RELAYER <--> VALIDATOR

    ANDE_TOKEN --> ANDE_BRIDGE
    ARB_TOKEN --> ARB_BRIDGE
    BASE_TOKEN --> BASE_BRIDGE

    style ANDE_POOL fill:#4ecdc4
    style ARB_POOL fill:#ff6b6b
    style BASE_POOL fill:#95e1d3
    style RELAYER fill:#ffe66d
```

---

## 11. DAO Governance Flow

```mermaid
sequenceDiagram
    actor Holder as QENTI Holder
    participant SNAPSHOT as Snapshot<br/>(Off-Chain)
    participant TALLY as Tally<br/>(On-Chain)
    participant GOV as Governor Contract
    participant TIMELOCK as Timelock<br/>(2 days)
    participant TARGET as Target Contract

    Note over Holder,SNAPSHOT: Phase 1: Temperature Check
    Holder->>SNAPSHOT: 1. Create Proposal
    SNAPSHOT->>SNAPSHOT: 2. Community Vote<br/>(No Gas)

    Note over SNAPSHOT: Voting Period: 3 days<br/>Quorum: 10M QENTI

    SNAPSHOT-->>Holder: ✅ Passed (70% Yes)

    Note over Holder,TALLY: Phase 2: On-Chain Execution
    Holder->>TALLY: 3. Create On-Chain Proposal
    TALLY->>GOV: propose(targets, values, calldatas)

    GOV->>GOV: 4. Voting Period<br/>(7 days)

    Note over GOV: Votes: For: 15M | Against: 2M<br/>Quorum: 10M ✅

    GOV-->>TALLY: ✅ Proposal Passed

    Holder->>TALLY: 5. Queue Proposal
    TALLY->>TIMELOCK: queue(proposal)

    Note over TIMELOCK: 2-day Delay<br/>(Security Buffer)

    Holder->>TALLY: 6. Execute Proposal
    TALLY->>TIMELOCK: execute(proposal)
    TIMELOCK->>TARGET: Call updateParameter()

    TARGET-->>Holder: ✅ Proposal Executed
```

---

## 12. Account Abstraction (ERC-4337) Flow

```mermaid
graph LR
    subgraph "User Experience"
        USER[👤 New User<br/>No Crypto Knowledge]
        SOCIAL[📧 Email/Google Login]
        WALLET[🔐 Smart Wallet<br/>Generated]
    end

    subgraph "UserOperation"
        USEROP[UserOperation Object]
        BUNDLE[Bundler Service]
        PAYMASTER[Paymaster<br/>Sponsor Gas]
    end

    subgraph "On-Chain"
        MEMPOOL[Alt Mempool]
        ENTRY[EntryPoint Contract]
        ACCOUNT[Smart Account]
        TARGET[Target Contract]
    end

    USER --> SOCIAL
    SOCIAL --> WALLET

    WALLET --> USEROP
    USEROP --> BUNDLE
    BUNDLE --> PAYMASTER

    PAYMASTER --> MEMPOOL
    MEMPOOL --> ENTRY
    ENTRY --> ACCOUNT
    ACCOUNT --> TARGET

    TARGET -.Result.-> USER

    style USER fill:#ffd93d
    style WALLET fill:#6bcf7f
    style PAYMASTER fill:#ff8fab
    style ACCOUNT fill:#4d96ff
```

**Benefits:**
- ✅ No seed phrases
- ✅ Social recovery
- ✅ Gasless transactions
- ✅ Batch operations
- ✅ Session keys

---

## 13. Performance Optimization Strategy

```mermaid
graph TD
    subgraph "Frontend Optimization"
        F1[Next.js SSR/SSG]
        F2[Image Optimization<br/>next/image]
        F3[Code Splitting<br/>Dynamic Imports]
        F4[React Query<br/>Cache]
    end

    subgraph "Backend Optimization"
        B1[Redis Cache<br/>TTL 60s]
        B2[PostgreSQL<br/>Read Replicas]
        B3[BullMQ<br/>Job Queue]
        B4[GraphQL<br/>DataLoader]
    end

    subgraph "Smart Contract Optimization"
        S1[Singleton Pattern<br/>-99% gas]
        S2[Flash Accounting<br/>Efficient Swaps]
        S3[Batch Operations<br/>Multi-call]
        S4[Storage Packing<br/>uint256 → uint128]
    end

    subgraph "Network Optimization"
        N1[ANDE Network<br/>~0.0001 gas]
        N2[Celestia DA<br/>Cheap Storage]
        N3[The Graph<br/>Fast Queries]
        N4[CDN<br/>Vercel Edge]
    end

    F1 --> B1
    F2 --> N4
    F3 --> N4
    F4 --> B1

    B1 --> N1
    B2 --> N1
    B3 --> N1
    B4 --> N3

    S1 --> N1
    S2 --> N1
    S3 --> N1
    S4 --> N1

    style S1 fill:#00c853
    style N1 fill:#ff6d00
    style B1 fill:#2979ff
    style F4 fill:#aa00ff
```

---

## 14. Testing Strategy Pyramid

```mermaid
graph BT
    subgraph "Unit Tests"
        U1[Foundry Tests<br/>Individual Functions]
        U2[NestJS Tests<br/>Service Logic]
        U3[React Tests<br/>Component Logic]
    end

    subgraph "Integration Tests"
        I1[Contract Integration<br/>Multi-Contract]
        I2[API Integration<br/>E2E Endpoints]
        I3[Subgraph Tests<br/>Graph Node]
    end

    subgraph "E2E Tests"
        E1[Playwright<br/>Full User Flow]
        E2[Testnet Deployment<br/>Real Network]
    end

    subgraph "Security Tests"
        SE1[Fuzz Testing<br/>Foundry]
        SE2[Invariant Tests<br/>Properties]
        SE3[Formal Verification<br/>Certora]
        SE4[Penetration Tests<br/>Manual]
    end

    U1 --> I1
    U2 --> I2
    U3 --> E1

    I1 --> E2
    I2 --> E2
    I3 --> E2

    E2 --> SE1
    E2 --> SE2
    E2 --> SE3
    E2 --> SE4

    style U1 fill:#4caf50
    style I1 fill:#ff9800
    style E1 fill:#f44336
    style SE3 fill:#9c27b0
```

**Coverage Targets:**
- Unit Tests: **>95%**
- Integration Tests: **>85%**
- E2E Tests: **Critical Paths**
- Security: **100% Critical Functions**

---

## 15. Deployment Pipeline (CI/CD)

```mermaid
graph LR
    subgraph "Development"
        DEV[Developer Push]
        LINT[ESLint + Solhint]
        TEST[Run Tests]
    end

    subgraph "CI - GitHub Actions"
        BUILD[Build All Apps]
        COVERAGE[Test Coverage]
        SECURITY[Slither + Audit]
    end

    subgraph "Staging"
        TESTNET[Deploy Testnet]
        VERIFY[Verify Contracts]
        SMOKE[Smoke Tests]
    end

    subgraph "Production"
        REVIEW[Manual Review<br/>4/7 Multisig]
        MAINNET[Deploy Mainnet]
        MONITOR[Monitor Alerts]
    end

    DEV --> LINT
    LINT --> TEST
    TEST --> BUILD

    BUILD --> COVERAGE
    COVERAGE --> SECURITY

    SECURITY --> TESTNET
    TESTNET --> VERIFY
    VERIFY --> SMOKE

    SMOKE --> REVIEW
    REVIEW --> MAINNET
    MAINNET --> MONITOR

    style SECURITY fill:#ff5252
    style REVIEW fill:#ffab00
    style MAINNET fill:#00c853
```

---

**Diagramas preparados para QentiFi Architecture | 2024-2025**
