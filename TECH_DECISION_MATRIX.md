# QentiFi - Matriz de Decisiones Tecnológicas

## Comparación de Tecnologías & Justificaciones

Este documento detalla las decisiones arquitectónicas clave para QentiFi, comparando alternativas y justificando cada elección basada en la investigación de mejores prácticas 2024-2025.

---

## 1. Smart Contract Framework

### Opciones Evaluadas

| Característica | Foundry | Hardhat | Truffle |
|---------------|---------|---------|---------|
| **Lenguaje Tests** | Solidity | JavaScript/TypeScript | JavaScript |
| **Velocidad** | ⚡⚡⚡⚡⚡ Rust (ultra-rápido) | ⚡⚡⚡ Node.js | ⚡⚡ Node.js |
| **Fuzz Testing** | ✅ Built-in | ❌ Requiere plugins | ❌ No nativo |
| **Invariant Tests** | ✅ Built-in | ❌ Manual | ❌ No |
| **Gas Reports** | ✅ Detallado | ✅ Via plugin | ✅ Básico |
| **Debugger** | ✅ Excellent | ✅ Excellent | ⚠️ Limitado |
| **Ecosystem** | 🔥 Growing fast | 🏆 Más grande | 📉 Declining |
| **Foundry Book** | ✅ Excelente docs | ✅ Buena docs | ⚠️ Desactualizado |

### ✅ Decisión: **Foundry (Primary) + Hardhat (Deploy/Scripts)**

**Justificación:**
- **Performance:** Foundry es 10-100x más rápido en tests
- **Security:** Fuzz + invariant testing nativo (crítico para DeFi)
- **Developer Experience:** Tests en Solidity = menos context switching
- **Industry Trend:** Uniswap v4, Aave v3, Curve están migrando a Foundry
- **Hybrid Approach:** Hardhat para deploy scripts (mejor ecosystem plugins)

**Implementación:**
```bash
# Foundry para tests y desarrollo
forge test
forge coverage
forge snapshot

# Hardhat para deployment y verificación
npx hardhat deploy --network ande-mainnet
npx hardhat verify --network ande-mainnet
```

---

## 2. Frontend Framework

### Opciones Evaluadas

| Característica | Next.js 14 | Remix | Vite + React | Astro |
|---------------|------------|-------|--------------|-------|
| **Rendering** | SSR/SSG/ISR | SSR | CSR | SSG |
| **App Router** | ✅ Stable | ✅ Nested Routes | ❌ Manual | ✅ File-based |
| **Performance** | ⚡⚡⚡⚡ | ⚡⚡⚡⚡ | ⚡⚡⚡⚡⚡ | ⚡⚡⚡ |
| **SEO** | ✅ Excellent | ✅ Excellent | ⚠️ Limited | ✅ Excellent |
| **Web3 Ecosystem** | 🏆 Best | ✅ Good | ✅ Good | ⚠️ Limited |
| **Deployment** | ✅ Vercel 1-click | ✅ Vercel/Fly.io | ✅ Any | ✅ Vercel/Netlify |
| **Learning Curve** | ⚠️ Medium | ⚠️ Medium | ✅ Easy | ✅ Easy |

### ✅ Decisión: **Next.js 14 (App Router)**

**Justificación:**
- **Web3 Ecosystem:** Mejor integración con Wagmi, RainbowKit, Viem
- **Performance:** App Router + Server Components = carga más rápida
- **SEO:** Crítico para landing pages y token discovery
- **Developer Experience:** Hot reload, TypeScript, Tailwind integration
- **Deployment:** Vercel Edge Network (ultra-rápido en LATAM)
- **Community:** Mayor cantidad de ejemplos Web3

**Benchmarks:**
- Lighthouse Score: **95+**
- First Contentful Paint: **<1s**
- Time to Interactive: **<2s**

---

## 3. Web3 Libraries

### Opciones Evaluadas

| Característica | Viem + Wagmi | ethers.js v6 | web3.js | web3-react |
|---------------|--------------|--------------|---------|------------|
| **TypeScript** | ✅ Native | ✅ Native | ⚠️ Partial | ✅ Native |
| **Bundle Size** | 🏆 ~50KB | ⚠️ ~300KB | ⚠️ ~400KB | ⚠️ ~200KB |
| **Performance** | ⚡⚡⚡⚡⚡ | ⚡⚡⚡ | ⚡⚡ | ⚡⚡⚡ |
| **React Hooks** | ✅ Built-in (Wagmi) | ❌ Manual | ❌ Manual | ✅ Built-in |
| **EIP-1193** | ✅ Native | ✅ Via Provider | ✅ Via Provider | ✅ Native |
| **Account Abstraction** | ✅ ERC-4337 | ⚠️ Custom | ❌ No | ⚠️ Custom |
| **Caching** | ✅ TanStack Query | ❌ Manual | ❌ Manual | ⚠️ Limited |

### ✅ Decisión: **Viem + Wagmi 2.0**

**Justificación:**
- **Performance:** 6x más pequeño que ethers.js
- **TypeScript:** Type-safety completo, mejor DX
- **Modern:** Built for React 18 + Server Components
- **Hooks:** useAccount, useBalance, useContractRead out-of-the-box
- **Account Abstraction:** Primera clase support para ERC-4337
- **Industry Adoption:** Uniswap, Aave, Curve están migrando

**Migration Path:**
```typescript
// Old: ethers.js
const provider = new ethers.providers.Web3Provider(window.ethereum)
const signer = provider.getSigner()
const contract = new ethers.Contract(address, abi, signer)
const balance = await contract.balanceOf(address)

// New: Viem + Wagmi
const { data: balance } = useContractRead({
  address,
  abi,
  functionName: 'balanceOf',
  args: [address]
})
```

---

## 4. Wallet Connection

### Opciones Evaluadas

| Característica | RainbowKit | ConnectKit | Web3Modal | wagmi/core |
|---------------|------------|------------|-----------|-----------|
| **UI/UX** | 🏆 Best | ✅ Good | ✅ Good | ❌ Headless |
| **Customización** | ✅ Theming | ✅ Theming | ⚠️ Limited | ✅ Full control |
| **Wallets Soportados** | 100+ | 50+ | 80+ | Any |
| **Mobile Support** | ✅ Excellent | ✅ Good | ✅ Good | ✅ Good |
| **Chain Switching** | ✅ Built-in | ✅ Built-in | ✅ Built-in | ⚠️ Manual |
| **ENS Support** | ✅ Avatar + Name | ✅ Name | ✅ Name | ⚠️ Manual |

### ✅ Decisión: **RainbowKit 2.0**

**Justificación:**
- **UX Premium:** Modal design más pulido
- **Avatar + ENS:** Muestra avatar automáticamente
- **Recent Transactions:** Historia de transacciones built-in
- **Chain Switching:** UX fluido para multi-chain
- **Customization:** Theming fácil para branding QentiFi
- **Mobile:** Mejor UX en mobile wallets (MetaMask, Trust, Rainbow)

**Custom Theme:**
```typescript
const qentiFiTheme: Theme = {
  ...darkTheme(),
  colors: {
    accentColor: '#FF6B00', // Naranja Andino
    accentColorForeground: '#FFF',
  },
  fonts: {
    body: 'Inter, sans-serif',
  },
}
```

---

## 5. UI Component Library

### Opciones Evaluadas

| Característica | shadcn/ui | Chakra UI | MUI | Mantine |
|---------------|-----------|-----------|-----|---------|
| **Copy-Paste** | ✅ Own code | ❌ Package | ❌ Package | ❌ Package |
| **Customización** | 🏆 100% | ✅ Theming | ✅ Theming | ✅ Theming |
| **Bundle Size** | ⚡ ~10KB | ⚠️ ~150KB | ⚠️ ~300KB | ⚠️ ~200KB |
| **TypeScript** | ✅ Native | ✅ Native | ✅ Native | ✅ Native |
| **Tailwind** | ✅ Built-in | ❌ CSS-in-JS | ❌ Emotion | ❌ Emotion |
| **Accessibility** | ✅ Radix UI | ✅ Good | ✅ Excellent | ✅ Good |

### ✅ Decisión: **shadcn/ui + Tailwind CSS**

**Justificación:**
- **Ownership:** Código en tu repo, no dependency
- **Performance:** Solo importas lo que usas
- **Customización:** 100% control sobre cada componente
- **Tailwind:** Consistencia con utility-first CSS
- **Radix Primitives:** Accessibility out-of-the-box
- **Trend:** Fastest growing UI library 2024

**Example:**
```tsx
// Copy component to your project
npx shadcn-ui@latest add button

// Use with full control
<Button variant="outline" size="lg" className="bg-qenti-orange">
  Create Meme Token
</Button>
```

---

## 6. Backend Framework

### Opciones Evaluadas

| Característica | NestJS | Express.js | Fastify | tRPC |
|---------------|--------|------------|---------|------|
| **Architecture** | ✅ Opinionated | ⚠️ Minimal | ⚠️ Minimal | ✅ Type-safe |
| **TypeScript** | 🏆 First-class | ⚠️ Manual | ✅ Good | 🏆 End-to-end |
| **Microservices** | ✅ Built-in | ❌ Manual | ⚠️ Plugins | ❌ Monolith |
| **GraphQL** | ✅ Built-in | ⚠️ Manual | ⚠️ Manual | ❌ N/A |
| **Dependency Injection** | ✅ Angular-like | ❌ Manual | ❌ Manual | ❌ N/A |
| **Testing** | ✅ Jest built-in | ⚠️ Manual | ⚠️ Manual | ✅ Good |

### ✅ Decisión: **NestJS**

**Justificación:**
- **Microservices:** Built-in support (TCP, Redis, NATS, gRPC)
- **Scalability:** Fácil escalar servicios independientemente
- **GraphQL:** Integración nativa (The Graph compatibility)
- **TypeScript:** Decorators + DI = código más limpio
- **Testing:** Jest + Supertest out-of-the-box
- **Enterprise-Ready:** Usado por Adidas, Roche, Capgemini

**Service Architecture:**
```typescript
// Microservice example
@Controller()
export class IndexerController {
  constructor(
    @Inject('REDIS_SERVICE') private redis: ClientProxy,
  ) {}

  @MessagePattern('token.created')
  async handleTokenCreated(data: TokenCreatedEvent) {
    // Handle event from blockchain
  }
}
```

---

## 7. Data Indexing Strategy

### Opciones Evaluadas

| Característica | The Graph | Custom Indexer | Moralis | Alchemy Subgraphs |
|---------------|-----------|----------------|---------|-------------------|
| **Decentralization** | ✅ Fully | ⚠️ Depends | ❌ Centralized | ⚠️ Partially |
| **GraphQL** | ✅ Native | ⚠️ Build yourself | ✅ Built-in | ✅ Built-in |
| **Cost** | $ (Query fees) | $$$ (Infra) | $$ (Subscription) | $ (Per query) |
| **Customization** | ✅ Full control | 🏆 Complete | ⚠️ Limited | ⚠️ Limited |
| **ANDE Support** | ✅ Any EVM | ✅ Yes | ⚠️ Limited chains | ⚠️ Limited chains |
| **Latency** | ⚡⚡⚡⚡ ~100ms | ⚡⚡⚡⚡⚡ ~10ms | ⚡⚡⚡ ~200ms | ⚡⚡⚡⚡ ~100ms |

### ✅ Decisión: **The Graph (Primary) + Redis Cache (Secondary)**

**Justificación:**
- **Decentralization:** Aligned con valores DeFi
- **GraphQL:** API familiar, fácil de queryar
- **Cost-Effective:** 80% más barato que custom indexer
- **EVM Compatible:** ANDE Network soportado
- **Community:** 10,400+ subgraphs, ecosystem maduro
- **Hybrid:** Redis cache para queries ultra-frecuentes

**Architecture:**
```typescript
// The Graph query
const { data } = useQuery(GET_TOP_TOKENS, {
  variables: { first: 10, orderBy: 'volume' }
})

// Redis cache for hot data (top 10 tokens)
const cachedTopTokens = await redis.get('top_tokens_24h')
if (cachedTopTokens) return JSON.parse(cachedTopTokens)
```

---

## 8. State Management

### Opciones Evaluadas

| Característica | Zustand | Redux Toolkit | Jotai | Recoil | Context API |
|---------------|---------|---------------|-------|--------|-------------|
| **Bundle Size** | 🏆 ~1KB | ⚠️ ~15KB | ✅ ~3KB | ⚠️ ~14KB | ✅ 0KB |
| **Boilerplate** | ✅ Minimal | ⚠️ Medium | ✅ Minimal | ✅ Minimal | ⚠️ Medium |
| **DevTools** | ✅ Redux DevTools | ✅ Native | ✅ Redux DevTools | ✅ Native | ❌ No |
| **TypeScript** | ✅ Excellent | ✅ Excellent | ✅ Excellent | ⚠️ Good | ✅ Good |
| **Learning Curve** | ✅ Easy | ⚠️ Medium | ✅ Easy | ⚠️ Medium | ✅ Easy |
| **Persistence** | ✅ Middleware | ✅ Middleware | ⚠️ Manual | ⚠️ Manual | ❌ Manual |

### ✅ Decisión: **Zustand + TanStack Query**

**Justificación:**
- **Simplicity:** Menos boilerplate que Redux
- **Performance:** Solo re-render componentes necesarios
- **Bundle Size:** 1KB vs 15KB (Redux)
- **TypeScript:** Type inference automático
- **DevTools:** Compatible con Redux DevTools
- **TanStack Query:** Maneja state de server (blockchain data)

**Example:**
```typescript
// Zustand para client state
const useWalletStore = create<WalletState>((set) => ({
  isConnected: false,
  address: null,
  connect: () => set({ isConnected: true }),
}))

// TanStack Query para server state (blockchain)
const { data: balance } = useQuery({
  queryKey: ['balance', address],
  queryFn: () => fetchBalance(address),
  staleTime: 10_000, // 10s cache
})
```

---

## 9. Monorepo Tool

### Opciones Evaluadas

| Característica | Turborepo | Nx | Lerna | pnpm workspaces |
|---------------|-----------|----|----- |-----------------|
| **Cache** | ✅ Local + Remote | ✅ Local + Remote | ⚠️ Limited | ❌ No |
| **Parallel Tasks** | ✅ Full cores | ✅ Full cores | ⚠️ Limited | ⚠️ Manual |
| **Build Speed** | 🏆 150x faster | ✅ 100x faster | ⚠️ Slow | ⚠️ No optimization |
| **Learning Curve** | ✅ Easy | ⚠️ Medium | ✅ Easy | ✅ Easy |
| **Package Manager** | Any (npm/yarn/pnpm) | Any | npm/yarn | pnpm only |
| **Config** | ✅ Simple JSON | ⚠️ Complex | ✅ Simple | ⚠️ Manual |

### ✅ Decisión: **Turborepo + pnpm**

**Justificación:**
- **Performance:** 30s → 0.2s build con cache
- **Simplicity:** turbo.json es minimal
- **Remote Cache:** Vercel integration gratis
- **pnpm:** Single node_modules, disk space efficient
- **Incremental:** Adopción gradual
- **Vercel:** Mismo team que Next.js

**Benchmark:**
```bash
# First build
turbo build
# ✓ Completed in 30s

# Second build (with cache)
turbo build
# ✓ Completed in 0.2s (150x faster!)
```

---

## 10. Testing Strategy

### Opciones Evaluadas

#### Smart Contracts

| Característica | Foundry | Hardhat | Echidna |
|---------------|---------|---------|---------|
| **Unit Tests** | ✅ Solidity | ✅ JS/TS | ❌ No |
| **Fuzz Tests** | ✅ Built-in | ⚠️ Plugins | 🏆 Specialized |
| **Invariant Tests** | ✅ Built-in | ❌ No | 🏆 Specialized |
| **Speed** | 🏆 Fast | ⚠️ Slow | ✅ Fast |
| **Coverage** | ✅ Built-in | ✅ Built-in | ❌ No |

#### Frontend

| Característica | Playwright | Cypress | Vitest | Jest |
|---------------|------------|---------|--------|------|
| **E2E** | 🏆 Best | ✅ Good | ❌ No | ❌ No |
| **Unit Tests** | ⚠️ Limited | ⚠️ Limited | ✅ Fast | ✅ Good |
| **Web3** | ✅ Good | ⚠️ Difficult | ✅ Good | ⚠️ Manual |
| **Speed** | ⚡⚡⚡⚡ | ⚡⚡⚡ | ⚡⚡⚡⚡⚡ | ⚡⚡⚡⚡ |

### ✅ Decisión: **Foundry + Vitest + Playwright**

**Justificación:**
- **Foundry:** Fuzz + invariant tests críticos para DeFi security
- **Vitest:** 10x más rápido que Jest, Vite compatibility
- **Playwright:** Mejor para E2E Web3 (multi-wallet testing)

**Coverage Targets:**
- Smart Contracts: **>95%**
- Frontend Components: **>85%**
- E2E Critical Paths: **100%**

---

## 11. Security Audit Tools

### Opciones Evaluadas

| Tool | Type | Cost | Coverage | False Positives |
|------|------|------|----------|-----------------|
| **Slither** | Static | Free | ✅ High | ⚠️ Medium |
| **Mythril** | Symbolic | Free | ✅ High | ⚠️ High |
| **Certora** | Formal | $$$$ | 🏆 Highest | ✅ Very Low |
| **Trail of Bits** | Manual | $$$$ | 🏆 Highest | ✅ Very Low |
| **OpenZeppelin** | Manual | $$$ | ✅ High | ✅ Very Low |

### ✅ Decisión: **Multi-Layer Approach**

**Strategy:**
1. **Continuous (Free):** Slither en CI/CD
2. **Pre-Audit (Free):** Foundry fuzz tests
3. **Pre-Deploy ($$$):** Certora formal verification
4. **Final ($$$):** Trail of Bits + OpenZeppelin manual audit

**Budget Allocation:**
- Certora: $30k
- Trail of Bits: $50k
- OpenZeppelin: $40k
- Bug Bounty: $50k
- **Total:** ~$170k (industry standard para $10M+ TVL)

---

## 12. Deployment & Hosting

### Opciones Evaluadas

#### Frontend

| Platform | Performance | Cost | DX | Edge Network |
|----------|-------------|------|----|--------------|
| **Vercel** | 🏆 Best | $$$ | 🏆 Best | ✅ Global |
| **Netlify** | ✅ Good | $$ | ✅ Good | ✅ Global |
| **Cloudflare Pages** | ✅ Good | $ | ⚠️ Medium | ✅ Global |
| **AWS Amplify** | ⚠️ Medium | $$ | ⚠️ Complex | ✅ Global |

#### Backend

| Platform | Scalability | Cost | DX | Database |
|----------|-------------|------|----|----------|
| **Railway** | ✅ Auto | $$ | 🏆 Best | ✅ Postgres |
| **Render** | ✅ Auto | $$ | ✅ Good | ✅ Postgres |
| **Fly.io** | ✅ Auto | $ | ⚠️ Medium | ⚠️ Manual |
| **AWS ECS** | 🏆 Unlimited | $$$ | ⚠️ Complex | ✅ RDS |

### ✅ Decisión: **Vercel + Railway**

**Justificación:**
- **Vercel:** Best Next.js performance, Edge network LATAM
- **Railway:** Simple NestJS deployment, Postgres included
- **Cost:** ~$200/month MVP → ~$1000/month at scale
- **DX:** Git push = deploy (CI/CD automático)

---

## 13. Monitoring & Analytics

### Opciones Evaluadas

| Tool | Purpose | Cost | Features |
|------|---------|------|----------|
| **Sentry** | Error Tracking | $$ | ✅ Source maps, user context |
| **Mixpanel** | Product Analytics | $$$ | ✅ Funnels, retention, A/B |
| **Tenderly** | Smart Contract | $$$ | ✅ Debugger, gas profiler |
| **OZ Defender** | Security | $$$ | ✅ Auto-alerts, actions |
| **Dune Analytics** | On-Chain | $ | ✅ SQL queries, dashboards |

### ✅ Decisión: **Full Stack Monitoring**

**Implementation:**
```typescript
// Frontend: Sentry
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  integrations: [new BrowserTracing()],
})

// Contracts: Tenderly
await tenderly.simulateTransaction(tx)

// Security: OpenZeppelin Defender
defender.autotask({
  trigger: 'largeWithdrawal',
  action: 'pauseContract',
})
```

---

## 14. Account Abstraction Provider

### Opciones Evaluadas

| Provider | Features | Cost | Network Support |
|----------|----------|------|-----------------|
| **Pimlico** | Bundler + Paymaster | $$ | 50+ chains |
| **Stackup** | Bundler + Paymaster | $ | 20+ chains |
| **Alchemy AA** | Full stack | $$$ | 10+ chains |
| **Biconomy** | Gasless SDK | $$ | 15+ chains |

### ✅ Decisión: **Pimlico (Primary) + Stackup (Backup)**

**Justificación:**
- **Pimlico:** Best developer experience, 50+ chains
- **Stackup:** Open-source backup option
- **Cost:** Pay-per-UserOp (scalable)
- **ANDE Support:** Custom RPC integration

**Implementation:**
```typescript
import { createSmartAccountClient } from 'permissionless'
import { pimlicoPaymasterActions } from 'permissionless/actions/pimlico'

const smartAccount = await createSmartAccountClient({
  chain: andeNetwork,
  bundlerTransport: http('https://api.pimlico.io/v2/ande/rpc'),
  middleware: {
    sponsorUserOperation: pimlicoPaymasterActions,
  },
})
```

---

## 15. Cross-Chain Messaging (Phase 3)

### Opciones Evaluadas

| Protocol | Security Model | Cost | Chains | Speed |
|----------|----------------|------|--------|-------|
| **LayerZero** | Ultra Light Node | $$ | 70+ | ⚡⚡⚡⚡ |
| **Wormhole** | Guardian Network | $ | 35+ | ⚡⚡⚡ |
| **Axelar** | Proof of Stake | $$ | 50+ | ⚡⚡⚡ |
| **Hyperlane** | Permissionless | $ | Any | ⚡⚡⚡⚡ |

### ✅ Decisión: **LayerZero v2 (Primary) + Wormhole (Backup)**

**Justificación:**
- **LayerZero:** Lightweight, fast, 70+ chains
- **Wormhole:** Proven security post-2022 hack
- **Dual:** Redundancy para critical bridges
- **Cost:** Pay per message (scalable)

**Risk Mitigation:**
- Rate limits en bridges
- Multi-sig approval para >$100k transfers
- 24h timelock en governance bridge changes

---

## Resumen de Decisiones Finales

### Smart Contract Layer
- ✅ **Framework:** Foundry + Hardhat
- ✅ **Architecture:** Hooks System (Uniswap v4)
- ✅ **AMM:** Bonding Curves (Pump.fun) + Concentrated Liquidity (Curve)
- ✅ **Security:** OpenZeppelin + Certora + Trail of Bits
- ✅ **Testing:** Fuzz + Invariant (Foundry)

### Frontend Layer
- ✅ **Framework:** Next.js 14 (App Router)
- ✅ **Web3:** Viem + Wagmi 2.0
- ✅ **Wallet:** RainbowKit 2.0
- ✅ **UI:** shadcn/ui + Tailwind CSS
- ✅ **State:** Zustand + TanStack Query
- ✅ **Account Abstraction:** Pimlico (ERC-4337)

### Backend Layer
- ✅ **Framework:** NestJS Microservices
- ✅ **Indexing:** The Graph + Redis Cache
- ✅ **Database:** PostgreSQL + Redis
- ✅ **API:** REST + GraphQL (Apollo)

### Infrastructure
- ✅ **Monorepo:** Turborepo + pnpm
- ✅ **Hosting:** Vercel (frontend) + Railway (backend)
- ✅ **Monitoring:** Sentry + Tenderly + OZ Defender
- ✅ **Analytics:** Mixpanel + Dune Analytics

### Security
- ✅ **Static Analysis:** Slither (CI/CD)
- ✅ **Formal Verification:** Certora Prover
- ✅ **Manual Audits:** Trail of Bits + OpenZeppelin
- ✅ **Bug Bounty:** $50k+ on Immunefi

---

## Cost Estimates (Annual)

### Development Tools
- Foundry: **Free**
- Certora: **$30k** (one-time)
- Audits: **$90k** (Trail of Bits + OZ)
- Bug Bounty: **$50k** (funded)

### Infrastructure
- Vercel Pro: **$2,400/year**
- Railway: **$12,000/year**
- The Graph: **~$5,000/year** (query fees)
- Pimlico: **~$10,000/year** (UserOp fees)
- Sentry: **$1,200/year**
- Tenderly: **$3,600/year**

### **Total Year 1:** ~$204k
### **Total Year 2+:** ~$85k/year (no audit costs)

---

**Matriz de Decisiones Técnicas - QentiFi | 2024-2025**
**Arquitectura Premium - Escalable - Modular - Segura**
