'use client'

import { useState } from 'react'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import Link from 'next/link'
import { Search, TrendingUp, Clock, Users, ExternalLink } from 'lucide-react'

// Mock data - will be replaced with real data from contracts
const MOCK_TOKENS = [
  {
    address: '0x1234567890abcdef',
    name: 'Qenti Coin',
    symbol: 'QENTI',
    image: '🐕',
    marketCap: '$125,000',
    volume24h: '$45,000',
    holders: 234,
    priceChange: '+15.5%',
    createdAt: '2 hours ago',
  },
  {
    address: '0xabcdef1234567890',
    name: 'Andean Llama',
    symbol: 'LLAMA',
    image: '🦙',
    marketCap: '$89,000',
    volume24h: '$32,000',
    holders: 189,
    priceChange: '+8.2%',
    createdAt: '5 hours ago',
  },
  {
    address: '0x9876543210fedcba',
    name: 'Machu Moon',
    symbol: 'MACHU',
    image: '🏔️',
    marketCap: '$67,000',
    volume24h: '$21,000',
    holders: 156,
    priceChange: '+12.3%',
    createdAt: '1 day ago',
  },
]

type SortOption = 'marketCap' | 'volume' | 'holders' | 'newest'

export default function ExplorePage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [sortBy, setSortBy] = useState<SortOption>('marketCap')

  const filteredTokens = MOCK_TOKENS.filter(
    (token) =>
      token.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      token.symbol.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-2">
            <div className="text-3xl">🐕</div>
            <span className="text-2xl font-bold text-qenti-dark">QentiFi</span>
          </Link>
          <div className="flex items-center gap-4">
            <Link
              href="/create"
              className="bg-qenti-orange hover:bg-qenti-orange/90 text-white px-6 py-2 rounded-lg font-semibold transition-all hidden md:block"
            >
              Create Token
            </Link>
            <ConnectButton />
          </div>
        </nav>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-12">
        <div className="max-w-6xl mx-auto">
          {/* Page Header */}
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-qenti-dark mb-2">Explore Tokens</h1>
            <p className="text-gray-600">
              Discover trending meme tokens on ANDE Network
            </p>
          </div>

          {/* Search & Filters */}
          <div className="bg-white rounded-xl shadow-lg p-6 mb-8">
            <div className="flex flex-col md:flex-row gap-4">
              {/* Search */}
              <div className="flex-1 relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
                <input
                  type="text"
                  placeholder="Search tokens..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 border-2 border-gray-200 rounded-lg focus:border-qenti-orange focus:outline-none"
                />
              </div>

              {/* Sort Options */}
              <div className="flex gap-2">
                <SortButton
                  active={sortBy === 'marketCap'}
                  onClick={() => setSortBy('marketCap')}
                  icon={<TrendingUp className="w-4 h-4" />}
                  label="Market Cap"
                />
                <SortButton
                  active={sortBy === 'volume'}
                  onClick={() => setSortBy('volume')}
                  icon={<TrendingUp className="w-4 h-4" />}
                  label="Volume"
                />
                <SortButton
                  active={sortBy === 'holders'}
                  onClick={() => setSortBy('holders')}
                  icon={<Users className="w-4 h-4" />}
                  label="Holders"
                />
                <SortButton
                  active={sortBy === 'newest'}
                  onClick={() => setSortBy('newest')}
                  icon={<Clock className="w-4 h-4" />}
                  label="Newest"
                />
              </div>
            </div>
          </div>

          {/* Stats Overview */}
          <div className="grid md:grid-cols-3 gap-6 mb-8">
            <StatCard label="Total Tokens" value={MOCK_TOKENS.length.toString()} />
            <StatCard label="Total Volume (24h)" value="$98,000" />
            <StatCard label="Total Holders" value="579" />
          </div>

          {/* Tokens Grid */}
          <div className="space-y-4">
            {filteredTokens.length === 0 ? (
              <div className="bg-white rounded-xl shadow-lg p-12 text-center">
                <div className="text-6xl mb-4">🔍</div>
                <h3 className="text-xl font-bold text-qenti-dark mb-2">
                  No tokens found
                </h3>
                <p className="text-gray-600">Try adjusting your search query</p>
              </div>
            ) : (
              filteredTokens.map((token) => <TokenCard key={token.address} token={token} />)
            )}
          </div>
        </div>
      </main>
    </div>
  )
}

function SortButton({
  active,
  onClick,
  icon,
  label,
}: {
  active: boolean
  onClick: () => void
  icon: React.ReactNode
  label: string
}) {
  return (
    <button
      onClick={onClick}
      className={`flex items-center gap-2 px-4 py-2 rounded-lg font-semibold transition-all ${
        active
          ? 'bg-qenti-orange text-white'
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
      }`}
    >
      {icon}
      <span className="hidden md:inline">{label}</span>
    </button>
  )
}

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="bg-white rounded-xl shadow-lg p-6">
      <div className="text-sm text-gray-500 mb-1">{label}</div>
      <div className="text-2xl font-bold text-qenti-dark">{value}</div>
    </div>
  )
}

function TokenCard({ token }: { token: (typeof MOCK_TOKENS)[0] }) {
  return (
    <Link href={`/token/${token.address}`}>
      <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow cursor-pointer">
        <div className="flex items-start gap-4">
          {/* Token Image */}
          <div className="text-5xl">{token.image}</div>

          {/* Token Info */}
          <div className="flex-1">
            <div className="flex items-start justify-between mb-2">
              <div>
                <h3 className="text-xl font-bold text-qenti-dark">{token.name}</h3>
                <div className="text-gray-500">${token.symbol}</div>
              </div>
              <div className="text-right">
                <div className="text-green-500 font-semibold">{token.priceChange}</div>
                <div className="text-sm text-gray-500">{token.createdAt}</div>
              </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-4 mt-4">
              <div>
                <div className="text-sm text-gray-500">Market Cap</div>
                <div className="font-semibold text-qenti-dark">{token.marketCap}</div>
              </div>
              <div>
                <div className="text-sm text-gray-500">Volume 24h</div>
                <div className="font-semibold text-qenti-dark">{token.volume24h}</div>
              </div>
              <div>
                <div className="text-sm text-gray-500">Holders</div>
                <div className="font-semibold text-qenti-dark">{token.holders}</div>
              </div>
            </div>
          </div>

          {/* Arrow */}
          <ExternalLink className="w-5 h-5 text-gray-400" />
        </div>
      </div>
    </Link>
  )
}
