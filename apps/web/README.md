# @qentifi/web

Next.js 14 frontend for QentiFi platform.

## Features

- ⚡ Next.js 14 with App Router
- 🎨 Tailwind CSS + Custom Design System
- 🔐 RainbowKit + Wagmi + Viem for Web3
- 📱 Responsive & Mobile-First
- 🌐 ERC-4337 Account Abstraction Ready

## Development

```bash
# Install dependencies
pnpm install

# Start dev server
pnpm dev

# Build for production
pnpm build

# Start production server
pnpm start
```

## Environment Variables

Copy `.env.example` to `.env.local` and fill in your values:

```bash
NEXT_PUBLIC_ANDE_RPC_URL=https://rpc.testnet.ande.network
NEXT_PUBLIC_ANDESCAN_URL=https://testnet.andescan.io
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your-project-id
```

## Project Structure

```
src/
├── app/                 # Next.js app router
│   ├── layout.tsx      # Root layout
│   ├── page.tsx        # Home page
│   └── providers.tsx   # Web3 providers
├── components/          # React components
├── config/             # Configuration
│   └── wagmi.ts        # Wagmi configuration
├── hooks/              # Custom React hooks
├── lib/                # Utilities
└── store/              # Zustand stores
```

## Key Technologies

- **Framework:** Next.js 14
- **Styling:** Tailwind CSS
- **Web3:** Wagmi 2.0 + Viem + RainbowKit
- **State:** Zustand + TanStack Query
- **TypeScript:** Full type safety

## License

MIT
