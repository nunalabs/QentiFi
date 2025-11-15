// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/StakingVault.sol";
import "../src/QentiToken.sol";
import "../src/MemeToken.sol";

contract StakingVaultTest is Test {
    StakingVault public vault;
    QentiToken public qentiToken;
    MemeToken public lpToken;

    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    event VaultCreated(uint256 indexed vaultId, address stakingToken, uint256 rewardPerSecond);
    event Staked(address indexed user, uint256 indexed vaultId, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed vaultId, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 indexed vaultId, uint256 amount);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy tokens
        qentiToken = new QentiToken(
            address(this),
            address(this),
            address(this),
            address(this),
            address(this)
        );

        lpToken = new MemeToken("LP Token", "LP", "ipfs://lp", owner);

        // Deploy staking vault
        vault = new StakingVault(address(qentiToken));

        // Mint some tokens for testing
        lpToken.mint(user1, 10000e18);
        lpToken.mint(user2, 10000e18);

        // Transfer QENTI rewards to vault
        qentiToken.transfer(address(vault), 1_000_000e18);

        vm.stopPrank();
    }

    function testCreateVault() public {
        vm.startPrank(owner);

        uint256 rewardPerSecond = 1e18; // 1 QENTI per second
        uint256 lockDuration = 30 days;

        vm.expectEmit(true, false, false, true);
        emit VaultCreated(0, address(lpToken), rewardPerSecond);

        vault.createVault(address(lpToken), rewardPerSecond, lockDuration);

        (address stakingToken, uint256 rewardRate,, uint256 lock, bool active) =
            vault.vaults(0);

        assertEq(stakingToken, address(lpToken), "Staking token should match");
        assertEq(rewardRate, rewardPerSecond, "Reward rate should match");
        assertEq(lock, lockDuration, "Lock duration should match");
        assertTrue(active, "Vault should be active");

        vm.stopPrank();
    }

    function testStake() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 30 days);
        vm.stopPrank();

        vm.startPrank(user1);

        uint256 stakeAmount = 1000e18;
        lpToken.approve(address(vault), stakeAmount);

        vm.expectEmit(true, true, false, true);
        emit Staked(user1, 0, stakeAmount);

        vault.stake(0, stakeAmount);

        (uint256 amount, uint256 unlockTime,) = vault.userStakes(0, user1);

        assertEq(amount, stakeAmount, "Staked amount should match");
        assertEq(
            unlockTime,
            block.timestamp + 30 days,
            "Unlock time should be set correctly"
        );

        vm.stopPrank();
    }

    function testCannotStakeZero() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 30 days);
        vm.stopPrank();

        vm.startPrank(user1);

        vm.expectRevert("Cannot stake 0");
        vault.stake(0, 0);

        vm.stopPrank();
    }

    function testCannotUnstakeBeforeLock() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 30 days);
        vm.stopPrank();

        vm.startPrank(user1);

        uint256 stakeAmount = 1000e18;
        lpToken.approve(address(vault), stakeAmount);
        vault.stake(0, stakeAmount);

        // Try to unstake immediately
        vm.expectRevert("Tokens still locked");
        vault.unstake(0, stakeAmount);

        // Try after 29 days (still locked)
        vm.warp(block.timestamp + 29 days);
        vm.expectRevert("Tokens still locked");
        vault.unstake(0, stakeAmount);

        vm.stopPrank();
    }

    function testUnstakeAfterLock() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 30 days);
        vm.stopPrank();

        vm.startPrank(user1);

        uint256 stakeAmount = 1000e18;
        lpToken.approve(address(vault), stakeAmount);
        vault.stake(0, stakeAmount);

        uint256 balanceBefore = lpToken.balanceOf(user1);

        // Warp past lock period
        vm.warp(block.timestamp + 30 days + 1);

        vm.expectEmit(true, true, false, true);
        emit Unstaked(user1, 0, stakeAmount);

        vault.unstake(0, stakeAmount);

        assertEq(
            lpToken.balanceOf(user1),
            balanceBefore + stakeAmount,
            "Should receive staked tokens back"
        );

        (uint256 amount,,) = vault.userStakes(0, user1);
        assertEq(amount, 0, "Stake should be 0 after unstaking");

        vm.stopPrank();
    }

    function testEarnRewards() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0); // No lock for this test
        vm.stopPrank();

        vm.startPrank(user1);

        uint256 stakeAmount = 1000e18;
        lpToken.approve(address(vault), stakeAmount);
        vault.stake(0, stakeAmount);

        // Warp 100 seconds
        vm.warp(block.timestamp + 100);

        uint256 pending = vault.pendingRewards(0, user1);

        // With 1 QENTI/second and 100 seconds, should have ~100 QENTI
        // (assuming user1 is the only staker)
        assertApproxEqRel(pending, 100e18, 0.01e18, "Should earn ~100 QENTI");

        vm.stopPrank();
    }

    function testClaimRewards() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0);
        vm.stopPrank();

        vm.startPrank(user1);

        uint256 stakeAmount = 1000e18;
        lpToken.approve(address(vault), stakeAmount);
        vault.stake(0, stakeAmount);

        // Warp 100 seconds
        vm.warp(block.timestamp + 100);

        uint256 balanceBefore = qentiToken.balanceOf(user1);
        uint256 pending = vault.pendingRewards(0, user1);

        vm.expectEmit(true, true, false, false);
        emit RewardsClaimed(user1, 0, 0);

        vault.claimRewards(0);

        uint256 balanceAfter = qentiToken.balanceOf(user1);
        assertGt(balanceAfter, balanceBefore, "Should receive rewards");
        assertApproxEqRel(
            balanceAfter - balanceBefore,
            pending,
            0.01e18,
            "Should receive pending rewards"
        );

        vm.stopPrank();
    }

    function testMultipleStakers() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0);
        vm.stopPrank();

        // User1 stakes 1000
        vm.startPrank(user1);
        lpToken.approve(address(vault), 1000e18);
        vault.stake(0, 1000e18);
        vm.stopPrank();

        // Warp 50 seconds
        vm.warp(block.timestamp + 50);

        // User2 stakes 1000 (now pool has 2000 total)
        vm.startPrank(user2);
        lpToken.approve(address(vault), 1000e18);
        vault.stake(0, 1000e18);
        vm.stopPrank();

        // Warp another 50 seconds
        vm.warp(block.timestamp + 50);

        // User1 should have: 50 (solo) + 25 (50% share) = 75 QENTI
        // User2 should have: 25 (50% share) = 25 QENTI
        uint256 pending1 = vault.pendingRewards(0, user1);
        uint256 pending2 = vault.pendingRewards(0, user2);

        assertApproxEqRel(pending1, 75e18, 0.05e18, "User1 should have ~75 QENTI");
        assertApproxEqRel(pending2, 25e18, 0.05e18, "User2 should have ~25 QENTI");
    }

    function testEmergencyWithdraw() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 30 days);
        vm.stopPrank();

        vm.startPrank(user1);

        uint256 stakeAmount = 1000e18;
        lpToken.approve(address(vault), stakeAmount);
        vault.stake(0, stakeAmount);

        // Emergency withdraw ignores lock period but forfeits rewards
        uint256 balanceBefore = lpToken.balanceOf(user1);

        vault.emergencyWithdraw(0);

        assertEq(
            lpToken.balanceOf(user1),
            balanceBefore + stakeAmount,
            "Should receive staked tokens"
        );

        (uint256 amount,,) = vault.userStakes(0, user1);
        assertEq(amount, 0, "Stake should be 0 after emergency withdraw");

        vm.stopPrank();
    }

    function testPauseVault() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0);

        vault.pauseVault(0);

        (,,,, bool active) = vault.vaults(0);
        assertFalse(active, "Vault should be paused");

        vm.stopPrank();

        // Cannot stake to paused vault
        vm.startPrank(user1);
        lpToken.approve(address(vault), 1000e18);

        vm.expectRevert("Vault not active");
        vault.stake(0, 1000e18);

        vm.stopPrank();
    }

    function testUnpauseVault() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0);

        vault.pauseVault(0);
        vault.unpauseVault(0);

        (,,,, bool active) = vault.vaults(0);
        assertTrue(active, "Vault should be active");

        vm.stopPrank();
    }

    function testUpdateRewardRate() public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0);

        uint256 newRate = 2e18;
        vault.updateRewardRate(0, newRate);

        (, uint256 rewardRate,,,) = vault.vaults(0);
        assertEq(rewardRate, newRate, "Reward rate should be updated");

        vm.stopPrank();
    }

    function testFuzzStake(uint256 amount) public {
        vm.startPrank(owner);
        vault.createVault(address(lpToken), 1e18, 0);
        vm.stopPrank();

        amount = bound(amount, 1e18, 10000e18);

        vm.startPrank(user1);
        lpToken.approve(address(vault), amount);
        vault.stake(0, amount);

        (uint256 stakedAmount,,) = vault.userStakes(0, user1);
        assertEq(stakedAmount, amount, "Staked amount should match");

        vm.stopPrank();
    }

    function testFuzzRewards(uint256 timeElapsed) public {
        vm.startPrank(owner);
        uint256 rewardRate = 1e18;
        vault.createVault(address(lpToken), rewardRate, 0);
        vm.stopPrank();

        timeElapsed = bound(timeElapsed, 1, 365 days);

        vm.startPrank(user1);
        lpToken.approve(address(vault), 1000e18);
        vault.stake(0, 1000e18);

        vm.warp(block.timestamp + timeElapsed);

        uint256 pending = vault.pendingRewards(0, user1);

        // Expected: rewardRate * timeElapsed (user1 is sole staker)
        assertApproxEqRel(
            pending,
            rewardRate * timeElapsed,
            0.01e18,
            "Rewards should match time elapsed"
        );

        vm.stopPrank();
    }
}
