import { getDefaultConfig } from '@rainbow-me/rainbowkit'
import { defineChain } from 'viem'

// Define ANDE Network chain
export const andeTestnet = defineChain({
  id: 42069,
  name: 'ANDE Testnet',
  nativeCurrency: {
    decimals: 18,
    name: 'ANDE',
    symbol: 'ANDE',
  },
  rpcUrls: {
    default: {
      http: [process.env.NEXT_PUBLIC_ANDE_RPC_URL || 'https://rpc-testnet.ande.network'],
    },
    public: {
      http: [process.env.NEXT_PUBLIC_ANDE_RPC_URL || 'https://rpc-testnet.ande.network'],
    },
  },
  blockExplorers: {
    default: {
      name: 'ANDE Explorer',
      url: 'https://explorer-testnet.ande.network',
    },
  },
  testnet: true,
})

export const andeMainnet = defineChain({
  id: 42070,
  name: 'ANDE Network',
  nativeCurrency: {
    decimals: 18,
    name: 'ANDE',
    symbol: 'ANDE',
  },
  rpcUrls: {
    default: {
      http: ['https://rpc.ande.network'],
    },
    public: {
      http: ['https://rpc.ande.network'],
    },
  },
  blockExplorers: {
    default: {
      name: 'ANDE Explorer',
      url: 'https://explorer.ande.network',
    },
  },
  testnet: false,
})

export const config = getDefaultConfig({
  appName: 'QentiFi',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'YOUR_PROJECT_ID',
  chains: [andeTestnet],
  ssr: true,
})
