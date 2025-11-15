/**
 * Contract addresses and ABIs for QentiFi
 * Update these after deploying contracts
 */

// Contract addresses (from deployments/ande-testnet.json)
export const FACTORY_ADDRESS =
  (process.env.NEXT_PUBLIC_FACTORY_ADDRESS as `0x${string}`) ||
  '0x0000000000000000000000000000000000000000'

export const POOL_MANAGER_ADDRESS =
  (process.env.NEXT_PUBLIC_POOL_MANAGER_ADDRESS as `0x${string}`) ||
  '0x0000000000000000000000000000000000000000'

export const QENTI_TOKEN_ADDRESS =
  (process.env.NEXT_PUBLIC_QENTI_TOKEN_ADDRESS as `0x${string}`) ||
  '0x0000000000000000000000000000000000000000'

export const STAKING_VAULT_ADDRESS =
  (process.env.NEXT_PUBLIC_STAKING_VAULT_ADDRESS as `0x${string}`) ||
  '0x0000000000000000000000000000000000000000'

export const NFT_BADGES_ADDRESS =
  (process.env.NEXT_PUBLIC_NFT_BADGES_ADDRESS as `0x${string}`) ||
  '0x0000000000000000000000000000000000000000'

// Import ABIs from contract builds
// Note: In production, copy ABIs from packages/contracts/out/ after building

export const FACTORY_ABI = [
  {
    type: 'function',
    name: 'createMemeToken',
    inputs: [
      { name: 'name', type: 'string' },
      { name: 'symbol', type: 'string' },
      { name: 'imageURI', type: 'string' },
    ],
    outputs: [
      { name: 'token', type: 'address' },
      { name: 'bondingCurve', type: 'address' },
    ],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'getAllTokens',
    inputs: [],
    outputs: [{ name: '', type: 'address[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getTokenBondingCurve',
    inputs: [{ name: 'token', type: 'address' }],
    outputs: [{ name: '', type: 'address' }],
    stateMutability: 'view',
  },
  {
    type: 'event',
    name: 'TokenCreated',
    inputs: [
      { name: 'token', type: 'address', indexed: true },
      { name: 'bondingCurve', type: 'address', indexed: true },
      { name: 'creator', type: 'address', indexed: true },
      { name: 'name', type: 'string', indexed: false },
      { name: 'symbol', type: 'string', indexed: false },
      { name: 'imageURI', type: 'string', indexed: false },
    ],
  },
] as const

export const BONDING_CURVE_ABI = [
  {
    type: 'function',
    name: 'buyTokens',
    inputs: [{ name: 'minTokens', type: 'uint256' }],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'sellTokens',
    inputs: [
      { name: 'tokenAmount', type: 'uint256' },
      { name: 'minAnde', type: 'uint256' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'getCurrentPrice',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'totalSupply',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'totalVolume',
    inputs: [],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'event',
    name: 'TokensPurchased',
    inputs: [
      { name: 'buyer', type: 'address', indexed: true },
      { name: 'andeAmount', type: 'uint256', indexed: false },
      { name: 'tokenAmount', type: 'uint256', indexed: false },
      { name: 'newPrice', type: 'uint256', indexed: false },
    ],
  },
  {
    type: 'event',
    name: 'TokensSold',
    inputs: [
      { name: 'seller', type: 'address', indexed: true },
      { name: 'tokenAmount', type: 'uint256', indexed: false },
      { name: 'andeAmount', type: 'uint256', indexed: false },
      { name: 'newPrice', type: 'uint256', indexed: false },
    ],
  },
] as const

export const STAKING_VAULT_ABI = [
  {
    type: 'function',
    name: 'stake',
    inputs: [
      { name: 'vaultId', type: 'uint256' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'unstake',
    inputs: [
      { name: 'vaultId', type: 'uint256' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'claimRewards',
    inputs: [{ name: 'vaultId', type: 'uint256' }],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'pendingRewards',
    inputs: [
      { name: 'vaultId', type: 'uint256' },
      { name: 'user', type: 'address' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
] as const

export const NFT_BADGES_ABI = [
  {
    type: 'function',
    name: 'getUserBadges',
    inputs: [{ name: 'user', type: 'address' }],
    outputs: [{ name: '', type: 'uint256[]' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getBadgeInfo',
    inputs: [{ name: 'tokenId', type: 'uint256' }],
    outputs: [
      { name: 'badgeType', type: 'uint8' },
      { name: 'level', type: 'uint8' },
      { name: 'mintedAt', type: 'uint256' },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'hasBadge',
    inputs: [
      { name: 'user', type: 'address' },
      { name: 'badgeType', type: 'uint8' },
    ],
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'view',
  },
] as const

export const ERC20_ABI = [
  {
    type: 'function',
    name: 'balanceOf',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'approve',
    inputs: [
      { name: 'spender', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'allowance',
    inputs: [
      { name: 'owner', type: 'address' },
      { name: 'spender', type: 'address' },
    ],
    outputs: [{ name: '', type: 'uint256' }],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'transfer',
    inputs: [
      { name: 'to', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [{ name: '', type: 'bool' }],
    stateMutability: 'nonpayable',
  },
] as const
