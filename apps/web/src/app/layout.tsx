import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Providers } from './providers'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'QentiFi - DeFi Platform on ANDE Network',
  description: 'Create, trade, and earn with meme tokens on ANDE Network',
  keywords: ['DeFi', 'ANDE Network', 'Meme Tokens', 'Crypto', 'Web3'],
  authors: [{ name: 'QentiFi Team' }],
  openGraph: {
    title: 'QentiFi - DeFi Platform on ANDE Network',
    description: 'Create, trade, and earn with meme tokens on ANDE Network',
    type: 'website',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
