import { BigInt, Address, Bytes } from '@graphprotocol/graph-ts'
import {
  TokenCreated,
  TokenGraduated,
} from '../generated/MemeTokenFactory/MemeTokenFactory'
import {
  TokensPurchased,
  TokensSold,
} from '../generated/templates/BondingCurveAMM/BondingCurveAMM'
import {
  Token,
  User,
  TokenHolder,
  Swap,
  DailyStats,
  GlobalStats,
} from '../generated/schema'
import { BondingCurveAMM as BondingCurveTemplate } from '../generated/templates'

// Constants
const ZERO_BI = BigInt.fromI32(0)
const ONE_BI = BigInt.fromI32(1)

// Helper to get or create User
function getOrCreateUser(address: Address, timestamp: BigInt): User {
  let user = User.load(address.toHexString())

  if (user === null) {
    user = new User(address.toHexString())
    user.totalTokensCreated = 0
    user.totalSwaps = 0
    user.totalVolume = ZERO_BI
    user.firstActivityAt = timestamp
    user.lastActivityAt = timestamp
    user.save()

    // Update global stats
    updateGlobalStats(timestamp, true, false, false, ZERO_BI)
  }

  user.lastActivityAt = timestamp
  user.save()

  return user
}

// Helper to get or create GlobalStats
function getOrCreateGlobalStats(timestamp: BigInt): GlobalStats {
  let stats = GlobalStats.load('global')

  if (stats === null) {
    stats = new GlobalStats('global')
    stats.totalTokens = 0
    stats.totalUsers = 0
    stats.totalSwaps = 0
    stats.totalVolume = ZERO_BI
    stats.totalValueLocked = ZERO_BI
    stats.lastUpdate = timestamp
  }

  return stats
}

// Helper to update global stats
function updateGlobalStats(
  timestamp: BigInt,
  newUser: boolean,
  newToken: boolean,
  newSwap: boolean,
  volumeDelta: BigInt
): void {
  let stats = getOrCreateGlobalStats(timestamp)

  if (newUser) stats.totalUsers = stats.totalUsers + 1
  if (newToken) stats.totalTokens = stats.totalTokens + 1
  if (newSwap) stats.totalSwaps = stats.totalSwaps + 1

  stats.totalVolume = stats.totalVolume.plus(volumeDelta)
  stats.lastUpdate = timestamp

  stats.save()
}

// Helper to get or create daily stats
function getOrCreateDailyStats(timestamp: BigInt): DailyStats {
  const dayID = timestamp.toI32() / 86400
  const dayStartTimestamp = dayID * 86400
  const date = new Date(dayStartTimestamp * 1000).toISOString().slice(0, 10)

  let stats = DailyStats.load(date)

  if (stats === null) {
    stats = new DailyStats(date)
    stats.date = date
    stats.tokensCreated = 0
    stats.totalSwaps = 0
    stats.totalVolume = ZERO_BI
    stats.uniqueUsers = 0
    stats.timestamp = BigInt.fromI32(dayStartTimestamp)
  }

  return stats
}

// Handle TokenCreated event
export function handleTokenCreated(event: TokenCreated): void {
  const tokenAddress = event.params.token
  const creator = event.params.creator
  const bondingCurve = event.params.bondingCurve

  // Create token entity
  let token = new Token(tokenAddress.toHexString())
  token.name = event.params.name
  token.symbol = event.params.symbol
  token.imageURI = event.params.imageURI
  token.bondingCurve = bondingCurve
  token.createdAt = event.block.timestamp
  token.graduated = false
  token.totalSupply = ZERO_BI
  token.currentPrice = ZERO_BI
  token.marketCap = ZERO_BI
  token.volume24h = ZERO_BI
  token.volumeTotal = ZERO_BI
  token.holderCount = 0
  token.lastUpdate = event.block.timestamp

  // Get or create user
  let user = getOrCreateUser(creator, event.block.timestamp)
  token.creator = user.id
  user.totalTokensCreated = user.totalTokensCreated + 1
  user.save()

  token.save()

  // Start indexing bonding curve events
  BondingCurveTemplate.create(bondingCurve)

  // Update daily stats
  let dailyStats = getOrCreateDailyStats(event.block.timestamp)
  dailyStats.tokensCreated = dailyStats.tokensCreated + 1
  dailyStats.save()

  // Update global stats
  updateGlobalStats(event.block.timestamp, false, true, false, ZERO_BI)
}

// Handle TokenGraduated event
export function handleTokenGraduated(event: TokenGraduated): void {
  let token = Token.load(event.params.token.toHexString())

  if (token !== null) {
    token.graduated = true
    token.graduatedAt = event.block.timestamp
    token.lastUpdate = event.block.timestamp
    token.save()
  }
}

// Handle TokensPurchased event
export function handleTokensPurchased(event: TokensPurchased): void {
  const bondingCurveAddress = event.address
  const buyer = event.params.buyer
  const andeAmount = event.params.andeAmount
  const tokenAmount = event.params.tokenAmount
  const price = event.params.price

  // Find token by bonding curve
  let token = findTokenByBondingCurve(bondingCurveAddress)
  if (token === null) return

  // Get or create user
  let user = getOrCreateUser(buyer, event.block.timestamp)

  // Create swap entity
  const swapId = event.transaction.hash.toHexString() + '-' + event.logIndex.toString()
  let swap = new Swap(swapId)
  swap.token = token.id
  swap.user = user.id
  swap.type = 'BUY'
  swap.amountIn = andeAmount
  swap.amountOut = tokenAmount
  swap.price = price
  swap.timestamp = event.block.timestamp
  swap.txHash = event.transaction.hash
  swap.save()

  // Update token stats
  token.totalSupply = token.totalSupply.plus(tokenAmount)
  token.currentPrice = price
  token.volumeTotal = token.volumeTotal.plus(andeAmount)
  token.lastUpdate = event.block.timestamp

  // Update market cap (supply * price)
  token.marketCap = token.totalSupply.times(price).div(BigInt.fromI32(10).pow(18))

  token.save()

  // Update or create token holder
  const holderID = token.id + '-' + user.id
  let holder = TokenHolder.load(holderID)

  if (holder === null) {
    holder = new TokenHolder(holderID)
    holder.token = token.id
    holder.holder = user.id
    holder.balance = ZERO_BI
    holder.firstPurchaseAt = event.block.timestamp

    // Increment holder count
    token.holderCount = token.holderCount + 1
    token.save()
  }

  holder.balance = holder.balance.plus(tokenAmount)
  holder.lastActivityAt = event.block.timestamp
  holder.save()

  // Update user stats
  user.totalSwaps = user.totalSwaps + 1
  user.totalVolume = user.totalVolume.plus(andeAmount)
  user.save()

  // Update daily stats
  let dailyStats = getOrCreateDailyStats(event.block.timestamp)
  dailyStats.totalSwaps = dailyStats.totalSwaps + 1
  dailyStats.totalVolume = dailyStats.totalVolume.plus(andeAmount)
  dailyStats.save()

  // Update global stats
  updateGlobalStats(event.block.timestamp, false, false, true, andeAmount)
}

// Handle TokensSold event
export function handleTokensSold(event: TokensSold): void {
  const bondingCurveAddress = event.address
  const seller = event.params.seller
  const tokenAmount = event.params.tokenAmount
  const andeAmount = event.params.andeAmount
  const price = event.params.price

  // Find token by bonding curve
  let token = findTokenByBondingCurve(bondingCurveAddress)
  if (token === null) return

  // Get or create user
  let user = getOrCreateUser(seller, event.block.timestamp)

  // Create swap entity
  const swapId = event.transaction.hash.toHexString() + '-' + event.logIndex.toString()
  let swap = new Swap(swapId)
  swap.token = token.id
  swap.user = user.id
  swap.type = 'SELL'
  swap.amountIn = tokenAmount
  swap.amountOut = andeAmount
  swap.price = price
  swap.timestamp = event.block.timestamp
  swap.txHash = event.transaction.hash
  swap.save()

  // Update token stats
  token.totalSupply = token.totalSupply.minus(tokenAmount)
  token.currentPrice = price
  token.volumeTotal = token.volumeTotal.plus(andeAmount)
  token.lastUpdate = event.block.timestamp

  // Update market cap
  token.marketCap = token.totalSupply.times(price).div(BigInt.fromI32(10).pow(18))

  token.save()

  // Update token holder
  const holderID = token.id + '-' + user.id
  let holder = TokenHolder.load(holderID)

  if (holder !== null) {
    holder.balance = holder.balance.minus(tokenAmount)
    holder.lastActivityAt = event.block.timestamp

    // Remove holder if balance is zero
    if (holder.balance.equals(ZERO_BI)) {
      token.holderCount = token.holderCount - 1
      token.save()
    }

    holder.save()
  }

  // Update user stats
  user.totalSwaps = user.totalSwaps + 1
  user.totalVolume = user.totalVolume.plus(andeAmount)
  user.save()

  // Update daily stats
  let dailyStats = getOrCreateDailyStats(event.block.timestamp)
  dailyStats.totalSwaps = dailyStats.totalSwaps + 1
  dailyStats.totalVolume = dailyStats.totalVolume.plus(andeAmount)
  dailyStats.save()

  // Update global stats
  updateGlobalStats(event.block.timestamp, false, false, true, andeAmount)
}

// Helper to find token by bonding curve address
function findTokenByBondingCurve(bondingCurveAddress: Address): Token | null {
  // This is a simplified version - in production, you'd iterate or maintain a mapping
  // For now, we assume the token ID is derivable from the event context
  // In practice, The Graph will have this relationship from the template data source
  return null // To be implemented with proper token lookup
}
