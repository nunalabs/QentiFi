'use client'

import { Component, ReactNode } from 'react'
import { AlertTriangle, RefreshCw } from 'lucide-react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
    }
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo)

    // Log to error tracking service (Sentry, etc.)
    if (typeof window !== 'undefined' && (window as any).Sentry) {
      (window as any).Sentry.captureException(error, { extra: errorInfo })
    }
  }

  handleReset = () => {
    this.setState({ hasError: false, error: undefined })
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback
      }

      return (
        <div className="min-h-screen bg-gradient-to-br from-qenti-cream via-white to-qenti-orange/10 flex items-center justify-center p-4">
          <div className="max-w-md w-full bg-white rounded-xl shadow-lg p-8 text-center">
            <div className="mb-6">
              <AlertTriangle className="w-16 h-16 text-red-500 mx-auto mb-4" />
              <h1 className="text-2xl font-bold text-qenti-dark mb-2">
                Oops! Something went wrong
              </h1>
              <p className="text-gray-600">
                We're sorry for the inconvenience. An error occurred while loading this page.
              </p>
            </div>

            {this.state.error && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6 text-left">
                <p className="text-sm font-mono text-red-800 break-all">
                  {this.state.error.message}
                </p>
              </div>
            )}

            <div className="space-y-3">
              <button
                onClick={this.handleReset}
                className="w-full bg-qenti-orange hover:bg-qenti-orange/90 text-white px-6 py-3 rounded-lg font-semibold flex items-center justify-center gap-2 transition-all"
              >
                <RefreshCw className="w-5 h-5" />
                Try Again
              </button>
              <button
                onClick={() => (window.location.href = '/')}
                className="w-full bg-white hover:bg-gray-50 text-qenti-dark px-6 py-3 rounded-lg font-semibold border-2 border-qenti-orange transition-all"
              >
                Go Home
              </button>
            </div>

            <p className="text-sm text-gray-500 mt-6">
              If this problem persists, please{' '}
              <a
                href="https://github.com/nunalabs/QentiFi/issues"
                target="_blank"
                rel="noopener noreferrer"
                className="text-qenti-orange hover:underline"
              >
                report it on GitHub
              </a>
              .
            </p>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

// Hook version for functional components
export function useErrorHandler() {
  const handleError = (error: Error) => {
    console.error('Error:', error)

    // Log to tracking service
    if (typeof window !== 'undefined' && (window as any).Sentry) {
      (window as any).Sentry.captureException(error)
    }
  }

  return { handleError }
}
