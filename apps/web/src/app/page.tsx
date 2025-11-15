'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'
import Link from 'next/link'
import { Rocket, Coins, TrendingUp, Trophy } from 'lucide-react'

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="text-3xl">🐕</div>
            <span className="text-2xl font-bold text-qenti-dark">QentiFi</span>
          </div>
          <ConnectButton />
        </nav>
      </header>

      {/* Hero Section */}
      <main className="container mx-auto px-4 py-20">
        <div className="text-center animate-fade-in">
          <h1 className="text-6xl font-bold text-qenti-dark mb-6">
            Create. Trade. Earn.
          </h1>
          <p className="text-2xl text-gray-600 mb-8 max-w-2xl mx-auto">
            The first DeFi platform with Andean cultural identity on ANDE Network
          </p>

          <div className="flex gap-4 justify-center mb-16">
            <Link
              href="/create"
              className="bg-qenti-orange hover:bg-qenti-orange/90 text-white px-8 py-4 rounded-lg font-semibold text-lg transition-all transform hover:scale-105"
            >
              Create Meme Token
            </Link>
            <Link
              href="/explore"
              className="bg-white hover:bg-gray-50 text-qenti-dark px-8 py-4 rounded-lg font-semibold text-lg border-2 border-qenti-orange transition-all"
            >
              Explore Tokens
            </Link>
          </div>

          {/* Features Grid */}
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mt-20">
            <FeatureCard
              icon={<Rocket className="w-12 h-12 text-qenti-orange" />}
              title="Fair Launch"
              description="Bonding curves ensure everyone gets a fair price from day one"
            />
            <FeatureCard
              icon={<Coins className="w-12 h-12 text-qenti-orange" />}
              title="Low Fees"
              description="Ultra-low gas fees on ANDE Network make DeFi accessible to all"
            />
            <FeatureCard
              icon={<TrendingUp className="w-12 h-12 text-qenti-orange" />}
              title="Liquidity Mining"
              description="Earn rewards by providing liquidity to your favorite tokens"
            />
            <FeatureCard
              icon={<Trophy className="w-12 h-12 text-qenti-orange" />}
              title="Gamification"
              description="Collect NFT badges and compete on leaderboards"
            />
          </div>

          {/* Stats */}
          <div className="grid md:grid-cols-3 gap-8 mt-20 text-center">
            <StatCard label="Total Tokens Created" value="0" />
            <StatCard label="Total Volume" value="$0" />
            <StatCard label="Active Users" value="0" />
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="container mx-auto px-4 py-8 mt-20 border-t border-gray-200">
        <div className="text-center text-gray-600">
          <p>Built with ❤️ by the QentiFi team | Powered by ANDE Network</p>
        </div>
      </footer>
    </div>
  )
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode
  title: string
  description: string
}) {
  return (
    <div className="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-shadow animate-slide-up">
      <div className="flex justify-center mb-4">{icon}</div>
      <h3 className="text-xl font-bold text-qenti-dark mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  )
}

function StatCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="bg-white p-8 rounded-xl shadow-lg">
      <div className="text-4xl font-bold text-qenti-orange mb-2">{value}</div>
      <div className="text-gray-600">{label}</div>
    </div>
  )
}
