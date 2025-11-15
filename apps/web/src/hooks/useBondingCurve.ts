import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther, formatEther } from 'viem'
import { BONDING_CURVE_ABI } from '@/lib/contracts'

export function useBondingCurve(bondingCurveAddress: string | undefined) {
  // Get current price
  const { data: currentPrice } = useReadContract({
    address: bondingCurveAddress as `0x${string}`,
    abi: BONDING_CURVE_ABI,
    functionName: 'getCurrentPrice',
    query: {
      enabled: !!bondingCurveAddress,
    },
  })

  // Get current supply
  const { data: currentSupply } = useReadContract({
    address: bondingCurveAddress as `0x${string}`,
    abi: BONDING_CURVE_ABI,
    functionName: 'currentSupply',
    query: {
      enabled: !!bondingCurveAddress,
    },
  })

  // Get total volume
  const { data: totalVolume } = useReadContract({
    address: bondingCurveAddress as `0x${string}`,
    abi: BONDING_CURVE_ABI,
    functionName: 'totalVolume',
    query: {
      enabled: !!bondingCurveAddress,
    },
  })

  // Buy tokens
  const { writeContract: buyTokens, data: buyHash } = useWriteContract()
  const { isLoading: isBuying } = useWaitForTransactionReceipt({ hash: buyHash })

  const buy = async (andeAmount: string, minTokens: string) => {
    if (!bondingCurveAddress) return

    await buyTokens({
      address: bondingCurveAddress as `0x${string}`,
      abi: BONDING_CURVE_ABI,
      functionName: 'buyTokens',
      args: [parseEther(minTokens)],
      value: parseEther(andeAmount),
    })
  }

  // Sell tokens
  const { writeContract: sellTokens, data: sellHash } = useWriteContract()
  const { isLoading: isSelling } = useWaitForTransactionReceipt({ hash: sellHash })

  const sell = async (tokenAmount: string, minAnde: string) => {
    if (!bondingCurveAddress) return

    await sellTokens({
      address: bondingCurveAddress as `0x${string}`,
      abi: BONDING_CURVE_ABI,
      functionName: 'sellTokens',
      args: [parseEther(tokenAmount), parseEther(minAnde)],
    })
  }

  // Get buy quote
  const { data: buyQuote } = useReadContract({
    address: bondingCurveAddress as `0x${string}`,
    abi: BONDING_CURVE_ABI,
    functionName: 'getQuoteBuy',
    args: [parseEther('1')], // Quote for 1 ANDE
    query: {
      enabled: !!bondingCurveAddress,
    },
  })

  return {
    currentPrice: currentPrice ? formatEther(currentPrice as bigint) : '0',
    currentSupply: currentSupply ? formatEther(currentSupply as bigint) : '0',
    totalVolume: totalVolume ? formatEther(totalVolume as bigint) : '0',
    buyQuote: buyQuote as [bigint, bigint] | undefined,
    buy,
    sell,
    isBuying,
    isSelling,
  }
}
