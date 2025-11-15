// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IQentiFiHooks.sol";
import "../QentiNFTBadges.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GamificationHook
 * @notice Hook implementation for gamification features
 * @dev Tracks user activity and mints achievement badges
 */
contract GamificationHook is IQentiFiHooks, Ownable {
    QentiNFTBadges public immutable badgeContract;

    // User activity tracking
    mapping(address => uint256) public tokenCreationCount;
    mapping(address => uint256) public totalTradingVolume;
    mapping(address => uint256) public totalLiquidityProvided;
    mapping(address => uint256) public firstActivityTimestamp;

    // Thresholds for badges
    uint256 public constant VOLUME_KING_THRESHOLD = 10_000 * 10**18; // 10k ANDE
    uint256 public constant LIQUIDITY_HERO_THRESHOLD = 1_000 * 10**18; // 1k ANDE
    uint256 public constant DIAMOND_HANDS_DURATION = 90 days;
    uint256 public constant POOL_MASTER_THRESHOLD = 10;

    // Events
    event UserActivityRecorded(address indexed user, string activityType, uint256 value);
    event BadgeEarned(address indexed user, QentiNFTBadges.BadgeType badgeType);

    constructor(address _badgeContract, address initialOwner) Ownable(initialOwner) {
        badgeContract = QentiNFTBadges(_badgeContract);
    }

    /**
     * @notice Hook called before minting a token
     */
    function beforeMint(
        address creator,
        string memory, // name
        string memory, // symbol
        string memory  // imageURI
    ) external override {
        // Track first activity
        if (firstActivityTimestamp[creator] == 0) {
            firstActivityTimestamp[creator] = block.timestamp;
        }

        // Increment creation count
        tokenCreationCount[creator]++;

        emit UserActivityRecorded(creator, "token_creation", tokenCreationCount[creator]);
    }

    /**
     * @notice Hook called after minting a token
     */
    function afterMint(
        address creator,
        address, // token
        address  // bondingCurve
    ) external override {
        // Check and mint badges
        _checkAndMintBadges(creator);
    }

    /**
     * @notice Hook called before swap
     */
    function beforeSwap(
        address user,
        address, // tokenIn
        address, // tokenOut
        uint256  // amountIn
    ) external override {
        // Track first activity
        if (firstActivityTimestamp[user] == 0) {
            firstActivityTimestamp[user] = block.timestamp;
        }
    }

    /**
     * @notice Hook called after swap
     */
    function afterSwap(
        address user,
        address, // tokenIn
        address, // tokenOut
        uint256 amountIn,
        uint256  // amountOut
    ) external override {
        // Track trading volume
        totalTradingVolume[user] += amountIn;

        emit UserActivityRecorded(user, "swap", amountIn);

        // Check and mint badges
        _checkAndMintBadges(user);
    }

    /**
     * @notice Record liquidity provision
     * @param user User address
     * @param amount Amount of liquidity
     */
    function recordLiquidityProvision(address user, uint256 amount) external onlyOwner {
        totalLiquidityProvided[user] += amount;

        emit UserActivityRecorded(user, "liquidity_provision", amount);

        _checkAndMintBadges(user);
    }

    /**
     * @notice Check and mint appropriate badges
     * @param user User address
     */
    function _checkAndMintBadges(address user) internal {
        // First Meme Creator badge
        if (
            tokenCreationCount[user] == 1 &&
            !badgeContract.hasSpecificBadge(user, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR)
        ) {
            _mintBadge(user, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR, 1);
        }

        // Volume King badge
        if (
            totalTradingVolume[user] >= VOLUME_KING_THRESHOLD &&
            !badgeContract.hasSpecificBadge(user, QentiNFTBadges.BadgeType.VOLUME_KING)
        ) {
            uint256 level = _calculateVolumeLevel(totalTradingVolume[user]);
            _mintBadge(user, QentiNFTBadges.BadgeType.VOLUME_KING, level);
        }

        // Liquidity Hero badge
        if (
            totalLiquidityProvided[user] >= LIQUIDITY_HERO_THRESHOLD &&
            !badgeContract.hasSpecificBadge(user, QentiNFTBadges.BadgeType.LIQUIDITY_HERO)
        ) {
            uint256 level = _calculateLiquidityLevel(totalLiquidityProvided[user]);
            _mintBadge(user, QentiNFTBadges.BadgeType.LIQUIDITY_HERO, level);
        }

        // Diamond Hands badge
        if (
            firstActivityTimestamp[user] > 0 &&
            block.timestamp >= firstActivityTimestamp[user] + DIAMOND_HANDS_DURATION &&
            !badgeContract.hasSpecificBadge(user, QentiNFTBadges.BadgeType.DIAMOND_HANDS)
        ) {
            _mintBadge(user, QentiNFTBadges.BadgeType.DIAMOND_HANDS, 1);
        }

        // Pool Master badge
        if (
            tokenCreationCount[user] >= POOL_MASTER_THRESHOLD &&
            !badgeContract.hasSpecificBadge(user, QentiNFTBadges.BadgeType.POOL_MASTER)
        ) {
            _mintBadge(user, QentiNFTBadges.BadgeType.POOL_MASTER, 1);
        }
    }

    /**
     * @notice Calculate volume badge level
     */
    function _calculateVolumeLevel(uint256 volume) internal pure returns (uint256) {
        if (volume >= 1_000_000 * 10**18) return 5; // 1M+
        if (volume >= 500_000 * 10**18) return 4;   // 500k+
        if (volume >= 100_000 * 10**18) return 3;   // 100k+
        if (volume >= 50_000 * 10**18) return 2;    // 50k+
        return 1;                                    // 10k+
    }

    /**
     * @notice Calculate liquidity badge level
     */
    function _calculateLiquidityLevel(uint256 liquidity) internal pure returns (uint256) {
        if (liquidity >= 100_000 * 10**18) return 5; // 100k+
        if (liquidity >= 50_000 * 10**18) return 4;  // 50k+
        if (liquidity >= 10_000 * 10**18) return 3;  // 10k+
        if (liquidity >= 5_000 * 10**18) return 2;   // 5k+
        return 1;                                     // 1k+
    }

    /**
     * @notice Mint badge for user
     */
    function _mintBadge(
        address user,
        QentiNFTBadges.BadgeType badgeType,
        uint256 level
    ) internal {
        try badgeContract.mintBadge(user, badgeType, level, "") {
            emit BadgeEarned(user, badgeType);
        } catch {
            // Badge minting failed, continue
        }
    }

    /**
     * @notice Get user stats
     */
    function getUserStats(address user)
        external
        view
        returns (
            uint256 tokensCreated,
            uint256 tradingVolume,
            uint256 liquidityProvided,
            uint256 accountAge
        )
    {
        tokensCreated = tokenCreationCount[user];
        tradingVolume = totalTradingVolume[user];
        liquidityProvided = totalLiquidityProvided[user];

        if (firstActivityTimestamp[user] > 0) {
            accountAge = block.timestamp - firstActivityTimestamp[user];
        }
    }
}
