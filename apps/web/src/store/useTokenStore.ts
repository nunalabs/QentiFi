import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface Token {
  address: string
  name: string
  symbol: string
  imageURI: string
  bondingCurve: string
  creator: string
  createdAt: number
}

interface TokenStore {
  tokens: Token[]
  favorites: string[]
  recentlyViewed: string[]

  addToken: (token: Token) => void
  toggleFavorite: (address: string) => void
  addToRecentlyViewed: (address: string) => void
  isFavorite: (address: string) => boolean
}

export const useTokenStore = create<TokenStore>()(
  persist(
    (set, get) => ({
      tokens: [],
      favorites: [],
      recentlyViewed: [],

      addToken: (token) =>
        set((state) => ({
          tokens: [token, ...state.tokens.filter((t) => t.address !== token.address)],
        })),

      toggleFavorite: (address) =>
        set((state) => ({
          favorites: state.favorites.includes(address)
            ? state.favorites.filter((a) => a !== address)
            : [...state.favorites, address],
        })),

      addToRecentlyViewed: (address) =>
        set((state) => ({
          recentlyViewed: [
            address,
            ...state.recentlyViewed.filter((a) => a !== address),
          ].slice(0, 10), // Keep only last 10
        })),

      isFavorite: (address) => get().favorites.includes(address),
    }),
    {
      name: 'qentifi-token-storage',
    }
  )
)
