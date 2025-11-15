'use client'

import { useState } from 'react'
import { useParams } from 'next/navigation'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useAccount } from 'wagmi'
import Link from 'next/link'
import {
  ArrowLeft,
  TrendingUp,
  Users,
  Clock,
  ExternalLink,
  Heart,
  ArrowUpRight,
  ArrowDownLeft,
} from 'lucide-react'
import { useBondingCurve } from '@/hooks/useBondingCurve'
import { useTokenStore } from '@/store/useTokenStore'

export default function TokenDetailPage() {
  const params = useParams()
  const address = params.address as string
  const { isConnected } = useAccount()
  const { toggleFavorite, isFavorite } = useTokenStore()

  const [activeTab, setActiveTab] = useState<'buy' | 'sell'>('buy')
  const [amount, setAmount] = useState('')

  // Mock data - will be replaced with real contract data
  const token = {
    address,
    name: 'Qenti Coin',
    symbol: 'QENTI',
    image: '🐕',
    imageURI: 'ipfs://...',
    bondingCurve: '0xabcd...',
    creator: '0x1234...',
    createdAt: Date.now() - 7200000,
    marketCap: '$125,000',
    volume24h: '$45,000',
    holders: 234,
    priceChange: '+15.5%',
  }

  const { currentPrice, currentSupply, totalVolume, buy, sell, isBuying, isSelling } =
    useBondingCurve(token.bondingCurve)

  const handleTrade = async () => {
    if (!amount || !isConnected) return

    try {
      if (activeTab === 'buy') {
        await buy(amount, '0') // TODO: Calculate min tokens with slippage
      } else {
        await sell(amount, '0') // TODO: Calculate min ANDE with slippage
      }
      setAmount('')
    } catch (error) {
      console.error('Trade error:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <Link href="/explore" className="flex items-center gap-2 text-gray-600 hover:text-qenti-orange">
            <ArrowLeft className="w-5 h-5" />
            Back to Explore
          </Link>
          <ConnectButton />
        </nav>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="max-w-6xl mx-auto">
          {/* Token Header */}
          <div className="bg-white rounded-xl shadow-lg p-8 mb-8">
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-6">
                <div className="text-7xl">{token.image}</div>
                <div>
                  <div className="flex items-center gap-3 mb-2">
                    <h1 className="text-4xl font-bold text-qenti-dark">{token.name}</h1>
                    <button
                      onClick={() => toggleFavorite(address)}
                      className={`p-2 rounded-lg transition-colors ${
                        isFavorite(address)
                          ? 'bg-red-100 text-red-500'
                          : 'bg-gray-100 text-gray-400 hover:text-red-500'
                      }`}
                    >
                      <Heart className="w-6 h-6" fill={isFavorite(address) ? 'currentColor' : 'none'} />
                    </button>
                  </div>
                  <div className="flex items-center gap-4 text-gray-600">
                    <span className="font-mono">${token.symbol}</span>
                    <span>•</span>
                    <span className="text-green-500 font-semibold">{token.priceChange}</span>
                  </div>
                </div>
              </div>
              <div className="text-right">
                <div className="text-sm text-gray-500 mb-1">Current Price</div>
                <div className="text-3xl font-bold text-qenti-orange">
                  {currentPrice} ANDE
                </div>
              </div>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mt-8 pt-8 border-t border-gray-200">
              <Stat label="Market Cap" value={token.marketCap} icon={<TrendingUp />} />
              <Stat label="Volume 24h" value={token.volume24h} icon={<TrendingUp />} />
              <Stat label="Holders" value={token.holders.toString()} icon={<Users />} />
              <Stat label="Supply" value={currentSupply} icon={<Clock />} />
            </div>
          </div>

          <div className="grid lg:grid-cols-3 gap-8">
            {/* Trading Interface */}
            <div className="lg:col-span-2">
              <div className="bg-white rounded-xl shadow-lg p-8">
                <h2 className="text-2xl font-bold text-qenti-dark mb-6">Trade</h2>

                {/* Buy/Sell Tabs */}
                <div className="flex gap-2 mb-6">
                  <button
                    onClick={() => setActiveTab('buy')}
                    className={`flex-1 py-3 rounded-lg font-semibold transition-all flex items-center justify-center gap-2 ${
                      activeTab === 'buy'
                        ? 'bg-green-500 text-white'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    <ArrowUpRight className="w-5 h-5" />
                    Buy
                  </button>
                  <button
                    onClick={() => setActiveTab('sell')}
                    className={`flex-1 py-3 rounded-lg font-semibold transition-all flex items-center justify-center gap-2 ${
                      activeTab === 'sell'
                        ? 'bg-red-500 text-white'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    <ArrowDownLeft className="w-5 h-5" />
                    Sell
                  </button>
                </div>

                {!isConnected ? (
                  <div className="text-center py-12">
                    <div className="text-5xl mb-4">🔐</div>
                    <h3 className="text-xl font-bold text-qenti-dark mb-2">
                      Connect Wallet to Trade
                    </h3>
                    <p className="text-gray-600 mb-6">
                      You need to connect your wallet to buy or sell tokens
                    </p>
                    <ConnectButton />
                  </div>
                ) : (
                  <>
                    {/* Amount Input */}
                    <div className="mb-4">
                      <label className="block text-sm font-semibold text-qenti-dark mb-2">
                        {activeTab === 'buy' ? 'ANDE Amount' : 'Token Amount'}
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          value={amount}
                          onChange={(e) => setAmount(e.target.value)}
                          placeholder="0.0"
                          className="w-full px-4 py-4 pr-24 text-2xl border-2 border-gray-200 rounded-lg focus:border-qenti-orange focus:outline-none"
                        />
                        <div className="absolute right-4 top-1/2 transform -translate-y-1/2 font-semibold text-gray-500">
                          {activeTab === 'buy' ? 'ANDE' : token.symbol}
                        </div>
                      </div>
                    </div>

                    {/* You Receive */}
                    {amount && (
                      <div className="bg-gray-50 rounded-lg p-4 mb-6">
                        <div className="text-sm text-gray-500 mb-1">You Receive</div>
                        <div className="text-2xl font-bold text-qenti-dark">
                          ~{parseFloat(amount) * 1000}{' '}
                          {activeTab === 'buy' ? token.symbol : 'ANDE'}
                        </div>
                      </div>
                    )}

                    {/* Trade Button */}
                    <button
                      onClick={handleTrade}
                      disabled={!amount || isBuying || isSelling}
                      className={`w-full py-4 rounded-lg font-semibold text-lg transition-all ${
                        activeTab === 'buy'
                          ? 'bg-green-500 hover:bg-green-600 disabled:bg-gray-300'
                          : 'bg-red-500 hover:bg-red-600 disabled:bg-gray-300'
                      } text-white disabled:cursor-not-allowed`}
                    >
                      {isBuying || isSelling
                        ? 'Processing...'
                        : `${activeTab === 'buy' ? 'Buy' : 'Sell'} ${token.symbol}`}
                    </button>

                    {/* Info */}
                    <div className="mt-4 p-4 bg-qenti-orange/10 rounded-lg">
                      <div className="text-sm text-gray-600 space-y-1">
                        <div className="flex justify-between">
                          <span>Fee:</span>
                          <span className="font-semibold">0.3%</span>
                        </div>
                        <div className="flex justify-between">
                          <span>Slippage Tolerance:</span>
                          <span className="font-semibold">1%</span>
                        </div>
                      </div>
                    </div>
                  </>
                )}
              </div>
            </div>

            {/* Info Panel */}
            <div className="space-y-6">
              {/* Contract Info */}
              <div className="bg-white rounded-xl shadow-lg p-6">
                <h3 className="text-lg font-bold text-qenti-dark mb-4">Contract Info</h3>
                <div className="space-y-3 text-sm">
                  <InfoRow label="Token Address" value={address} copyable />
                  <InfoRow label="Bonding Curve" value={token.bondingCurve} copyable />
                  <InfoRow label="Creator" value={token.creator} link />
                </div>
              </div>

              {/* Progress to Graduation */}
              <div className="bg-white rounded-xl shadow-lg p-6">
                <h3 className="text-lg font-bold text-qenti-dark mb-4">
                  Graduation Progress
                </h3>
                <div className="mb-2">
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-600">Volume</span>
                    <span className="font-semibold">
                      {totalVolume} / 50,000 ANDE
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-qenti-orange h-2 rounded-full transition-all"
                      style={{
                        width: `${(parseFloat(totalVolume) / 50000) * 100}%`,
                      }}
                    />
                  </div>
                </div>
                <p className="text-xs text-gray-500 mt-2">
                  Once 50,000 ANDE volume is reached, this token will graduate to a full DEX pool
                </p>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

function Stat({
  label,
  value,
  icon,
}: {
  label: string
  value: string
  icon: React.ReactNode
}) {
  return (
    <div>
      <div className="flex items-center gap-2 text-sm text-gray-500 mb-1">
        <div className="w-4 h-4">{icon}</div>
        {label}
      </div>
      <div className="text-xl font-bold text-qenti-dark">{value}</div>
    </div>
  )
}

function InfoRow({
  label,
  value,
  copyable,
  link,
}: {
  label: string
  value: string
  copyable?: boolean
  link?: boolean
}) {
  const shortValue = `${value.slice(0, 6)}...${value.slice(-4)}`

  return (
    <div className="flex justify-between items-center">
      <span className="text-gray-600">{label}:</span>
      <div className="flex items-center gap-2">
        <span className="font-mono font-semibold">{shortValue}</span>
        {link && (
          <ExternalLink className="w-4 h-4 text-gray-400 hover:text-qenti-orange cursor-pointer" />
        )}
      </div>
    </div>
  )
}
