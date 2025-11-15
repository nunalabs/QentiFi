'use client'

import { useEffect, useRef, useState } from 'react'
import { createChart, IChartApi, ISeriesApi, ColorType } from 'lightweight-charts'

interface PriceData {
  time: number
  value: number
}

interface PriceChartProps {
  data: PriceData[]
  height?: number
}

export function PriceChart({ data, height = 400 }: PriceChartProps) {
  const chartContainerRef = useRef<HTMLDivElement>(null)
  const chartRef = useRef<IChartApi | null>(null)
  const seriesRef = useRef<ISeriesApi<'Area'> | null>(null)

  useEffect(() => {
    if (!chartContainerRef.current) return

    // Create chart
    const chart = createChart(chartContainerRef.current, {
      layout: {
        background: { type: ColorType.Solid, color: 'transparent' },
        textColor: '#1A1A1A',
      },
      width: chartContainerRef.current.clientWidth,
      height,
      grid: {
        vertLines: { color: '#f0f0f0' },
        horzLines: { color: '#f0f0f0' },
      },
      rightPriceScale: {
        borderColor: '#e0e0e0',
      },
      timeScale: {
        borderColor: '#e0e0e0',
        timeVisible: true,
        secondsVisible: false,
      },
    })

    chartRef.current = chart

    // Create area series
    const areaSeries = chart.addAreaSeries({
      lineColor: '#FF6B00',
      topColor: 'rgba(255, 107, 0, 0.4)',
      bottomColor: 'rgba(255, 107, 0, 0.05)',
      lineWidth: 2,
    })

    seriesRef.current = areaSeries

    // Set data
    if (data && data.length > 0) {
      areaSeries.setData(data)
      chart.timeScale().fitContent()
    }

    // Handle resize
    const handleResize = () => {
      if (chartContainerRef.current && chartRef.current) {
        chartRef.current.applyOptions({
          width: chartContainerRef.current.clientWidth,
        })
      }
    }

    window.addEventListener('resize', handleResize)

    // Cleanup
    return () => {
      window.removeEventListener('resize', handleResize)
      if (chartRef.current) {
        chartRef.current.remove()
        chartRef.current = null
      }
    }
  }, [data, height])

  // Update data when it changes
  useEffect(() => {
    if (seriesRef.current && data && data.length > 0) {
      seriesRef.current.setData(data)
      chartRef.current?.timeScale().fitContent()
    }
  }, [data])

  if (!data || data.length === 0) {
    return (
      <div
        className="flex items-center justify-center bg-gray-50 rounded-lg"
        style={{ height }}
      >
        <div className="text-center text-gray-500">
          <div className="text-4xl mb-2">📈</div>
          <p>No price data available yet</p>
        </div>
      </div>
    )
  }

  return <div ref={chartContainerRef} className="w-full rounded-lg" />
}

// Hook to fetch and format price data
export function usePriceData(tokenAddress: string) {
  const [priceData, setPriceData] = useState<PriceData[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // TODO: Fetch real price data from The Graph or backend
    // For now, generate mock data

    const generateMockData = (): PriceData[] => {
      const data: PriceData[] = []
      const now = Math.floor(Date.now() / 1000)
      const dayAgo = now - 24 * 60 * 60

      let price = 0.0001
      for (let time = dayAgo; time <= now; time += 300) {
        // Every 5 minutes
        price = price * (1 + (Math.random() - 0.45) * 0.1) // Random walk
        data.push({
          time,
          value: price,
        })
      }

      return data
    }

    setIsLoading(true)
    // Simulate API call
    setTimeout(() => {
      setPriceData(generateMockData())
      setIsLoading(false)
    }, 500)
  }, [tokenAddress])

  return { priceData, isLoading }
}
