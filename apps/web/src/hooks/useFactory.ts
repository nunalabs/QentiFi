import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { FACTORY_ABI, FACTORY_ADDRESS } from '@/config/contracts'

export function useCreateMemeToken() {
  const { writeContract, data: hash, isPending, error } = useWriteContract()

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  })

  const createToken = async (name: string, symbol: string, imageURI: string) => {
    try {
      await writeContract({
        address: FACTORY_ADDRESS,
        abi: FACTORY_ABI,
        functionName: 'createMemeToken',
        args: [name, symbol, imageURI],
        value: parseEther('0.01'), // Creation fee
      })
    } catch (err) {
      console.error('Error creating token:', err)
      throw err
    }
  }

  return {
    createToken,
    hash,
    isPending,
    isConfirming,
    isSuccess,
    error,
  }
}

export function useFactoryInfo() {
  const { data: totalTokens } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: FACTORY_ABI,
    functionName: 'totalTokens',
  })

  const { data: creationFee } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: FACTORY_ABI,
    functionName: 'creationFee',
  })

  return {
    totalTokens: totalTokens as bigint | undefined,
    creationFee: creationFee as bigint | undefined,
  }
}

export function useCreatorTokens(creator: string | undefined) {
  const { data: tokens, isLoading } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: FACTORY_ABI,
    functionName: 'getCreatorTokens',
    args: creator ? [creator] : undefined,
    query: {
      enabled: !!creator,
    },
  })

  return {
    tokens: tokens as string[] | undefined,
    isLoading,
  }
}
