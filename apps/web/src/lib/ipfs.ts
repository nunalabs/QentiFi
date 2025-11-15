/**
 * IPFS Upload utilities using Pinata
 *
 * Setup:
 * 1. Get API key from https://pinata.cloud
 * 2. Add to .env.local:
 *    NEXT_PUBLIC_PINATA_API_KEY=your-key
 *    NEXT_PUBLIC_PINATA_SECRET=your-secret
 */

const PINATA_API_KEY = process.env.NEXT_PUBLIC_PINATA_API_KEY
const PINATA_SECRET = process.env.NEXT_PUBLIC_PINATA_SECRET
const PINATA_JWT = process.env.NEXT_PUBLIC_PINATA_JWT

interface PinataResponse {
  IpfsHash: string
  PinSize: number
  Timestamp: string
}

/**
 * Upload file to IPFS via Pinata
 * @param file File to upload
 * @param filename Optional filename
 * @returns IPFS hash
 */
export async function uploadToIPFS(
  file: File,
  filename?: string
): Promise<string> {
  try {
    const formData = new FormData()
    formData.append('file', file)

    const metadata = JSON.stringify({
      name: filename || file.name,
      keyvalues: {
        platform: 'qentifi',
        uploadedAt: new Date().toISOString(),
      },
    })
    formData.append('pinataMetadata', metadata)

    const options = JSON.stringify({
      cidVersion: 1,
    })
    formData.append('pinataOptions', options)

    const response = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${PINATA_JWT}`,
      },
      body: formData,
    })

    if (!response.ok) {
      throw new Error(`Upload failed: ${response.statusText}`)
    }

    const data: PinataResponse = await response.json()
    return `ipfs://${data.IpfsHash}`
  } catch (error) {
    console.error('IPFS upload error:', error)
    throw new Error('Failed to upload to IPFS')
  }
}

/**
 * Upload JSON metadata to IPFS
 * @param metadata JSON object
 * @returns IPFS hash
 */
export async function uploadJSONToIPFS(metadata: object): Promise<string> {
  try {
    const response = await fetch('https://api.pinata.cloud/pinning/pinJSONToIPFS', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${PINATA_JWT}`,
      },
      body: JSON.stringify({
        pinataContent: metadata,
        pinataMetadata: {
          name: 'qentifi-metadata',
        },
      }),
    })

    if (!response.ok) {
      throw new Error(`Upload failed: ${response.statusText}`)
    }

    const data: PinataResponse = await response.json()
    return `ipfs://${data.IpfsHash}`
  } catch (error) {
    console.error('IPFS JSON upload error:', error)
    throw new Error('Failed to upload JSON to IPFS')
  }
}

/**
 * Get IPFS gateway URL
 * @param ipfsUri IPFS URI (ipfs://...)
 * @returns HTTP gateway URL
 */
export function getIPFSGatewayURL(ipfsUri: string): string {
  if (!ipfsUri) return ''

  if (ipfsUri.startsWith('ipfs://')) {
    const hash = ipfsUri.replace('ipfs://', '')
    return `https://gateway.pinata.cloud/ipfs/${hash}`
  }

  return ipfsUri
}

/**
 * Validate image file
 * @param file File to validate
 * @returns True if valid
 */
export function validateImageFile(file: File): {
  valid: boolean
  error?: string
} {
  const maxSize = 10 * 1024 * 1024 // 10MB
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']

  if (!allowedTypes.includes(file.type)) {
    return {
      valid: false,
      error: 'Invalid file type. Please upload JPG, PNG, GIF, or WebP.',
    }
  }

  if (file.size > maxSize) {
    return {
      valid: false,
      error: 'File too large. Maximum size is 10MB.',
    }
  }

  return { valid: true }
}

/**
 * Create token metadata object
 * @param name Token name
 * @param symbol Token symbol
 * @param description Token description
 * @param imageUri IPFS URI of image
 * @returns Metadata object
 */
export function createTokenMetadata(
  name: string,
  symbol: string,
  description: string,
  imageUri: string
) {
  return {
    name,
    symbol,
    description,
    image: imageUri,
    attributes: [
      {
        trait_type: 'Platform',
        value: 'QentiFi',
      },
      {
        trait_type: 'Network',
        value: 'ANDE',
      },
      {
        trait_type: 'Created',
        value: new Date().toISOString(),
      },
    ],
    external_url: 'https://qentifi.io',
  }
}
