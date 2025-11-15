import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { defineChain } from 'viem'

// ANDE Network configuration
export const andeNetwork = defineChain({
  id: 31337, // Replace with actual ANDE chain ID
  name: 'ANDE Network',
  nativeCurrency: {
    decimals: 18,
    name: 'ANDE',
    symbol: 'ANDE',
  },
  rpcUrls: {
    default: {
      http: [process.env.NEXT_PUBLIC_ANDE_RPC_URL || 'http://localhost:8545'],
    },
    public: {
      http: [process.env.NEXT_PUBLIC_ANDE_RPC_URL || 'http://localhost:8545'],
    },
  },
  blockExplorers: {
    default: {
      name: 'ANDEScan',
      url: process.env.NEXT_PUBLIC_ANDESCAN_URL || 'http://localhost:4000',
    },
  },
  testnet: true,
})

export const config = getDefaultConfig({
  appName: 'QentiFi',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'YOUR_PROJECT_ID',
  chains: [andeNetwork],
  ssr: true,
})
