'use client'

import { useState } from 'react'
import { useAccount, useWaitForTransactionReceipt } from 'wagmi'
import { ConnectButton } from '@rainbow-me/rainbowkit'
import { Upload, Loader2, CheckCircle, AlertCircle } from 'lucide-react'
import Link from 'next/link'

export default function CreateTokenPage() {
  const { address, isConnected } = useAccount()
  const [formData, setFormData] = useState({
    name: '',
    symbol: '',
    imageFile: null as File | null,
    imagePreview: '',
  })
  const [isCreating, setIsCreating] = useState(false)
  const [txHash, setTxHash] = useState<string>()
  const [createdToken, setCreatedToken] = useState<{
    token: string
    bondingCurve: string
  } | null>(null)

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setFormData((prev) => ({
        ...prev,
        imageFile: file,
        imagePreview: URL.createObjectURL(file),
      }))
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!isConnected) return

    setIsCreating(true)
    try {
      // TODO: Upload image to IPFS
      // TODO: Call factory contract createMemeToken
      // For now, simulate
      await new Promise((resolve) => setTimeout(resolve, 2000))

      // Mock data
      setCreatedToken({
        token: '0x1234...5678',
        bondingCurve: '0xabcd...efgh',
      })
    } catch (error) {
      console.error('Error creating token:', error)
    } finally {
      setIsCreating(false)
    }
  }

  if (!isConnected) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">🐕</div>
          <h1 className="text-3xl font-bold text-qenti-dark mb-4">
            Connect Your Wallet
          </h1>
          <p className="text-gray-600 mb-8">
            You need to connect your wallet to create a meme token
          </p>
          <ConnectButton />
        </div>
      </div>
    )
  }

  if (createdToken) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10">
        <div className="container mx-auto px-4 py-20">
          <div className="max-w-2xl mx-auto text-center">
            <CheckCircle className="w-20 h-20 text-green-500 mx-auto mb-6" />
            <h1 className="text-4xl font-bold text-qenti-dark mb-4">
              Token Created Successfully! 🎉
            </h1>
            <p className="text-gray-600 mb-8">
              Your meme token has been deployed and is ready to trade
            </p>

            <div className="bg-white rounded-xl shadow-lg p-8 mb-8">
              <div className="space-y-4">
                <div>
                  <div className="text-sm text-gray-500">Token Address</div>
                  <div className="font-mono text-lg">{createdToken.token}</div>
                </div>
                <div>
                  <div className="text-sm text-gray-500">Bonding Curve</div>
                  <div className="font-mono text-lg">{createdToken.bondingCurve}</div>
                </div>
              </div>
            </div>

            <div className="flex gap-4 justify-center">
              <Link
                href={`/token/${createdToken.token}`}
                className="bg-qenti-orange hover:bg-qenti-orange/90 text-white px-8 py-3 rounded-lg font-semibold"
              >
                View Token
              </Link>
              <Link
                href="/create"
                className="bg-white hover:bg-gray-50 text-qenti-dark px-8 py-3 rounded-lg font-semibold border-2 border-qenti-orange"
              >
                Create Another
              </Link>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-2">
            <div className="text-3xl">🐕</div>
            <span className="text-2xl font-bold text-qenti-dark">QentiFi</span>
          </Link>
          <ConnectButton />
        </nav>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-12">
        <div className="max-w-2xl mx-auto">
          <h1 className="text-4xl font-bold text-qenti-dark mb-2">Create Meme Token</h1>
          <p className="text-gray-600 mb-8">
            Launch your meme token with fair price discovery via bonding curve
          </p>

          <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-lg p-8">
            {/* Token Name */}
            <div className="mb-6">
              <label className="block text-sm font-semibold text-qenti-dark mb-2">
                Token Name *
              </label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="e.g., Qenti Coin"
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-qenti-orange focus:outline-none"
                required
              />
            </div>

            {/* Token Symbol */}
            <div className="mb-6">
              <label className="block text-sm font-semibold text-qenti-dark mb-2">
                Token Symbol *
              </label>
              <input
                type="text"
                value={formData.symbol}
                onChange={(e) =>
                  setFormData({ ...formData, symbol: e.target.value.toUpperCase() })
                }
                placeholder="e.g., QENTI"
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-qenti-orange focus:outline-none uppercase"
                maxLength={10}
                required
              />
            </div>

            {/* Image Upload */}
            <div className="mb-8">
              <label className="block text-sm font-semibold text-qenti-dark mb-2">
                Token Image *
              </label>
              <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-qenti-orange transition-colors">
                {formData.imagePreview ? (
                  <div className="space-y-4">
                    <img
                      src={formData.imagePreview}
                      alt="Preview"
                      className="w-32 h-32 mx-auto rounded-lg object-cover"
                    />
                    <button
                      type="button"
                      onClick={() =>
                        setFormData({ ...formData, imageFile: null, imagePreview: '' })
                      }
                      className="text-sm text-qenti-orange hover:underline"
                    >
                      Change Image
                    </button>
                  </div>
                ) : (
                  <label className="cursor-pointer">
                    <Upload className="w-12 h-12 mx-auto text-gray-400 mb-4" />
                    <p className="text-gray-600 mb-2">Click to upload image</p>
                    <p className="text-sm text-gray-400">PNG, JPG, GIF up to 10MB</p>
                    <input
                      type="file"
                      accept="image/*"
                      onChange={handleImageUpload}
                      className="hidden"
                      required
                    />
                  </label>
                )}
              </div>
            </div>

            {/* Creation Fee Info */}
            <div className="bg-qenti-orange/10 border border-qenti-orange/20 rounded-lg p-4 mb-6">
              <div className="flex items-start gap-3">
                <AlertCircle className="w-5 h-5 text-qenti-orange flex-shrink-0 mt-0.5" />
                <div>
                  <div className="font-semibold text-qenti-dark mb-1">
                    Creation Fee: 0.01 ANDE
                  </div>
                  <div className="text-sm text-gray-600">
                    This fee covers deployment costs and supports the platform
                  </div>
                </div>
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isCreating || !formData.name || !formData.symbol || !formData.imageFile}
              className="w-full bg-qenti-orange hover:bg-qenti-orange/90 disabled:bg-gray-300 disabled:cursor-not-allowed text-white px-8 py-4 rounded-lg font-semibold text-lg transition-all flex items-center justify-center gap-2"
            >
              {isCreating ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Creating Token...
                </>
              ) : (
                'Create Token'
              )}
            </button>
          </form>

          {/* How It Works */}
          <div className="mt-12 bg-white rounded-xl shadow-lg p-8">
            <h2 className="text-2xl font-bold text-qenti-dark mb-6">How It Works</h2>
            <div className="space-y-4">
              <Step number={1} text="Upload your meme image and choose a name" />
              <Step number={2} text="Pay 0.01 ANDE creation fee" />
              <Step
                number={3}
                text="Token is deployed with bonding curve (fair launch)"
              />
              <Step number={4} text="Start trading immediately!" />
            </div>
          </div>
        </div>
      </main>
    </div>
  )
}

function Step({ number, text }: { number: number; text: string }) {
  return (
    <div className="flex items-center gap-4">
      <div className="w-8 h-8 bg-qenti-orange text-white rounded-full flex items-center justify-center font-bold flex-shrink-0">
        {number}
      </div>
      <div className="text-gray-700">{text}</div>
    </div>
  )
}
