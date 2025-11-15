// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title StakingVault
 * @notice Single-asset staking vault with rewards
 * @dev Supports multiple reward tokens and flexible APY
 */
contract StakingVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;          // Staked amount
        uint256 rewardDebt;      // Reward debt
        uint256 pendingRewards;  // Pending rewards
        uint256 lastStakeTime;   // Last stake timestamp
        uint256 unlockTime;      // Unlock time for locked staking
    }

    struct VaultInfo {
        IERC20 stakingToken;     // Token being staked
        IERC20 rewardToken;      // Token given as reward
        uint256 totalStaked;     // Total amount staked
        uint256 rewardPerSecond; // Reward rate per second
        uint256 accRewardPerShare; // Accumulated reward per share
        uint256 lastRewardTime;  // Last reward calculation time
        uint256 minStakeAmount;  // Minimum stake amount
        uint256 lockDuration;    // Lock duration (0 for flexible)
        bool isActive;           // Vault active status
    }

    // Vault ID => Vault Info
    mapping(uint256 => VaultInfo) public vaults;

    // Vault ID => User => User Info
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Next vault ID
    uint256 public nextVaultId;

    // Precision for calculations
    uint256 private constant PRECISION = 1e12;

    // Events
    event VaultCreated(
        uint256 indexed vaultId,
        address stakingToken,
        address rewardToken,
        uint256 rewardPerSecond
    );
    event Staked(uint256 indexed vaultId, address indexed user, uint256 amount);
    event Unstaked(uint256 indexed vaultId, address indexed user, uint256 amount);
    event RewardClaimed(uint256 indexed vaultId, address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 indexed vaultId, uint256 newRate);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Create a new staking vault
     * @param stakingToken Token to be staked
     * @param rewardToken Token given as reward
     * @param rewardPerSecond Reward rate per second
     * @param minStakeAmount Minimum stake amount
     * @param lockDuration Lock duration in seconds (0 for flexible)
     */
    function createVault(
        address stakingToken,
        address rewardToken,
        uint256 rewardPerSecond,
        uint256 minStakeAmount,
        uint256 lockDuration
    ) external onlyOwner returns (uint256 vaultId) {
        vaultId = nextVaultId++;

        vaults[vaultId] = VaultInfo({
            stakingToken: IERC20(stakingToken),
            rewardToken: IERC20(rewardToken),
            totalStaked: 0,
            rewardPerSecond: rewardPerSecond,
            accRewardPerShare: 0,
            lastRewardTime: block.timestamp,
            minStakeAmount: minStakeAmount,
            lockDuration: lockDuration,
            isActive: true
        });

        emit VaultCreated(vaultId, stakingToken, rewardToken, rewardPerSecond);
    }

    /**
     * @notice Stake tokens
     * @param vaultId Vault ID
     * @param amount Amount to stake
     */
    function stake(uint256 vaultId, uint256 amount) external nonReentrant {
        VaultInfo storage vault = vaults[vaultId];
        require(vault.isActive, "Vault not active");
        require(amount >= vault.minStakeAmount, "Below minimum stake");

        UserInfo storage user = userInfo[vaultId][msg.sender];

        // Update vault rewards
        _updateVault(vaultId);

        // Claim pending rewards if any
        if (user.amount > 0) {
            uint256 pending = ((user.amount * vault.accRewardPerShare) / PRECISION) - user.rewardDebt;
            if (pending > 0) {
                user.pendingRewards += pending;
            }
        }

        // Transfer tokens
        vault.stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        // Update user info
        user.amount += amount;
        user.lastStakeTime = block.timestamp;
        user.unlockTime = block.timestamp + vault.lockDuration;
        user.rewardDebt = (user.amount * vault.accRewardPerShare) / PRECISION;

        // Update vault total
        vault.totalStaked += amount;

        emit Staked(vaultId, msg.sender, amount);
    }

    /**
     * @notice Unstake tokens
     * @param vaultId Vault ID
     * @param amount Amount to unstake
     */
    function unstake(uint256 vaultId, uint256 amount) external nonReentrant {
        VaultInfo storage vault = vaults[vaultId];
        UserInfo storage user = userInfo[vaultId][msg.sender];

        require(user.amount >= amount, "Insufficient staked");
        require(
            vault.lockDuration == 0 || block.timestamp >= user.unlockTime,
            "Still locked"
        );

        // Update vault rewards
        _updateVault(vaultId);

        // Calculate pending rewards
        uint256 pending = ((user.amount * vault.accRewardPerShare) / PRECISION) - user.rewardDebt;
        if (pending > 0) {
            user.pendingRewards += pending;
        }

        // Update user info
        user.amount -= amount;
        user.rewardDebt = (user.amount * vault.accRewardPerShare) / PRECISION;

        // Update vault total
        vault.totalStaked -= amount;

        // Transfer tokens back
        vault.stakingToken.safeTransfer(msg.sender, amount);

        emit Unstaked(vaultId, msg.sender, amount);
    }

    /**
     * @notice Claim rewards
     * @param vaultId Vault ID
     */
    function claimRewards(uint256 vaultId) external nonReentrant {
        VaultInfo storage vault = vaults[vaultId];
        UserInfo storage user = userInfo[vaultId][msg.sender];

        // Update vault rewards
        _updateVault(vaultId);

        // Calculate total claimable
        uint256 pending = ((user.amount * vault.accRewardPerShare) / PRECISION) - user.rewardDebt;
        uint256 totalReward = user.pendingRewards + pending;

        require(totalReward > 0, "No rewards to claim");

        // Reset pending rewards
        user.pendingRewards = 0;
        user.rewardDebt = (user.amount * vault.accRewardPerShare) / PRECISION;

        // Transfer rewards
        vault.rewardToken.safeTransfer(msg.sender, totalReward);

        emit RewardClaimed(vaultId, msg.sender, totalReward);
    }

    /**
     * @notice Get pending rewards for user
     * @param vaultId Vault ID
     * @param account User address
     */
    function pendingRewards(uint256 vaultId, address account)
        external
        view
        returns (uint256)
    {
        VaultInfo storage vault = vaults[vaultId];
        UserInfo storage user = userInfo[vaultId][account];

        uint256 accRewardPerShare = vault.accRewardPerShare;

        if (block.timestamp > vault.lastRewardTime && vault.totalStaked > 0) {
            uint256 duration = block.timestamp - vault.lastRewardTime;
            uint256 reward = duration * vault.rewardPerSecond;
            accRewardPerShare += (reward * PRECISION) / vault.totalStaked;
        }

        uint256 pending = ((user.amount * accRewardPerShare) / PRECISION) - user.rewardDebt;
        return user.pendingRewards + pending;
    }

    /**
     * @notice Update vault rewards
     * @param vaultId Vault ID
     */
    function _updateVault(uint256 vaultId) internal {
        VaultInfo storage vault = vaults[vaultId];

        if (block.timestamp <= vault.lastRewardTime) {
            return;
        }

        if (vault.totalStaked == 0) {
            vault.lastRewardTime = block.timestamp;
            return;
        }

        uint256 duration = block.timestamp - vault.lastRewardTime;
        uint256 reward = duration * vault.rewardPerSecond;

        vault.accRewardPerShare += (reward * PRECISION) / vault.totalStaked;
        vault.lastRewardTime = block.timestamp;
    }

    /**
     * @notice Update reward rate
     * @param vaultId Vault ID
     * @param newRate New reward per second
     */
    function updateRewardRate(uint256 vaultId, uint256 newRate) external onlyOwner {
        _updateVault(vaultId);
        vaults[vaultId].rewardPerSecond = newRate;
        emit RewardRateUpdated(vaultId, newRate);
    }

    /**
     * @notice Toggle vault active status
     * @param vaultId Vault ID
     */
    function toggleVault(uint256 vaultId) external onlyOwner {
        vaults[vaultId].isActive = !vaults[vaultId].isActive;
    }

    /**
     * @notice Emergency withdraw (no rewards)
     * @param vaultId Vault ID
     */
    function emergencyWithdraw(uint256 vaultId) external nonReentrant {
        VaultInfo storage vault = vaults[vaultId];
        UserInfo storage user = userInfo[vaultId][msg.sender];

        uint256 amount = user.amount;
        require(amount > 0, "Nothing to withdraw");

        // Reset user info
        user.amount = 0;
        user.rewardDebt = 0;
        user.pendingRewards = 0;

        // Update vault total
        vault.totalStaked -= amount;

        // Transfer tokens back
        vault.stakingToken.safeTransfer(msg.sender, amount);

        emit Unstaked(vaultId, msg.sender, amount);
    }
}
