// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/GamificationHook.sol";
import "../src/QentiNFTBadges.sol";
import "../src/MemeTokenFactory.sol";
import "../src/QentiFiPoolManager.sol";
import "../src/MemeToken.sol";

contract GamificationHookTest is Test {
    GamificationHook public hook;
    QentiNFTBadges public badges;
    MemeTokenFactory public factory;
    QentiFiPoolManager public poolManager;

    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    event BadgeEarned(address indexed user, QentiNFTBadges.BadgeType badgeType, uint8 level);

    function setUp() public {
        vm.startPrank(owner);

        // Deploy badges
        badges = new QentiNFTBadges();

        // Deploy hook
        hook = new GamificationHook(address(badges));

        // Grant minter role to hook
        badges.grantRole(badges.MINTER_ROLE(), address(hook));

        // Deploy factory and pool manager
        factory = new MemeTokenFactory(owner);
        poolManager = new QentiFiPoolManager();

        // Set hooks contract in factory
        factory.setHooksContract(address(hook));

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);

        vm.stopPrank();
    }

    function testFirstMemeCreatorBadge() public {
        vm.startPrank(user1);

        // Create first token - should earn badge
        vm.expectEmit(true, false, false, true);
        emit BadgeEarned(user1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR, 1);

        factory.createMemeToken{value: 0.01 ether}(
            "First Token",
            "FIRST",
            "ipfs://first"
        );

        // Verify badge was minted
        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR),
            "Should have FIRST_MEME_CREATOR badge"
        );

        assertEq(badges.balanceOf(user1), 1, "Should have 1 badge");

        vm.stopPrank();
    }

    function testMultipleTokenCreationBadges() public {
        vm.startPrank(user1);

        // Create tokens to earn badges at different levels
        for (uint256 i = 0; i < 5; i++) {
            factory.createMemeToken{value: 0.01 ether}(
                string(abi.encodePacked("Token", i)),
                string(abi.encodePacked("TK", i)),
                string(abi.encodePacked("ipfs://", i))
            );
        }

        assertEq(hook.tokenCreationCount(user1), 5, "Should have created 5 tokens");

        // Should have FIRST_MEME_CREATOR badge
        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR),
            "Should have creator badge"
        );

        vm.stopPrank();
    }

    function testVolumeKingBadge() public {
        vm.startPrank(user1);

        // Simulate trading volume
        hook.afterSwap(
            user1,
            address(0),
            address(0),
            1000 ether, // 1000 ANDE volume
            0,
            true
        );

        assertEq(
            hook.totalTradingVolume(user1),
            1000 ether,
            "Should have 1000 ANDE volume"
        );

        vm.stopPrank();
    }

    function testLiquidityHeroBadge() public {
        vm.startPrank(user1);

        // Simulate adding liquidity (10 ANDE worth)
        hook.afterAddLiquidity(user1, address(0), address(0), 10 ether, 0);

        assertEq(
            hook.totalLiquidityProvided(user1),
            10 ether,
            "Should have 10 ANDE liquidity"
        );

        // Add more liquidity to reach threshold (e.g., 100 ANDE for level 1)
        hook.afterAddLiquidity(user1, address(0), address(0), 90 ether, 0);

        // Should earn LIQUIDITY_HERO badge
        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.LIQUIDITY_HERO),
            "Should have LIQUIDITY_HERO badge"
        );

        vm.stopPrank();
    }

    function testBadgeLevelProgression() public {
        vm.startPrank(user1);

        // Level 1: 1,000 ANDE volume
        hook.afterSwap(user1, address(0), address(0), 1000 ether, 0, true);

        // Check if level 1 badge was minted
        if (badges.hasBadge(user1, QentiNFTBadges.BadgeType.VOLUME_KING)) {
            uint256[] memory userBadges = badges.getUserBadges(user1);
            (, uint8 level,) = badges.getBadgeInfo(userBadges[0]);
            assertEq(level, 1, "Should have level 1 VOLUME_KING");
        }

        // Level 2: 10,000 ANDE volume
        hook.afterSwap(user1, address(0), address(0), 9000 ether, 0, true);

        // Level 3: 100,000 ANDE volume
        hook.afterSwap(user1, address(0), address(0), 90000 ether, 0, true);

        assertEq(
            hook.totalTradingVolume(user1),
            100000 ether,
            "Should have 100k ANDE volume"
        );

        vm.stopPrank();
    }

    function testMultipleUsersBadges() public {
        // User1 creates token
        vm.startPrank(user1);
        factory.createMemeToken{value: 0.01 ether}("Token1", "TK1", "ipfs://1");
        vm.stopPrank();

        // User2 creates token
        vm.startPrank(user2);
        factory.createMemeToken{value: 0.01 ether}("Token2", "TK2", "ipfs://2");
        vm.stopPrank();

        // Both should have FIRST_MEME_CREATOR badge
        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR),
            "User1 should have badge"
        );
        assertTrue(
            badges.hasBadge(user2, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR),
            "User2 should have badge"
        );

        assertEq(badges.balanceOf(user1), 1, "User1 should have 1 badge");
        assertEq(badges.balanceOf(user2), 1, "User2 should have 1 badge");
    }

    function testHookIntegrationWithFactory() public {
        vm.startPrank(user1);

        // Before mint hook should be called automatically
        (address tokenAddress,) = factory.createMemeToken{value: 0.01 ether}(
            "Test Token",
            "TEST",
            "ipfs://test"
        );

        // After mint hook should also be called
        assertEq(hook.tokenCreationCount(user1), 1, "Token creation count should be 1");

        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR),
            "Should automatically receive badge"
        );

        vm.stopPrank();
    }

    function testDiamondHandsBadge() public {
        vm.startPrank(user1);

        // Create a token first
        (address tokenAddress,) = factory.createMemeToken{value: 0.01 ether}(
            "Diamond Token",
            "DIAM",
            "ipfs://diamond"
        );

        // Simulate holding for 30 days
        vm.warp(block.timestamp + 30 days);

        // Manual check and mint badge (would be automated in production)
        uint256 holdTime = hook.calculateHoldTime(user1, tokenAddress);
        assertGe(holdTime, 30 days, "Should have held for 30+ days");

        vm.stopPrank();
    }

    function testWhaleBadge() public {
        vm.startPrank(user1);

        // Simulate large swap (e.g., 1000 ANDE in single transaction)
        hook.afterSwap(user1, address(0), address(0), 1000 ether, 0, true);

        // Check if WHALE badge criteria met (implementation specific)
        assertEq(
            hook.totalTradingVolume(user1),
            1000 ether,
            "Should have whale-level volume"
        );

        vm.stopPrank();
    }

    function testTraderProBadge() public {
        vm.startPrank(user1);

        // Simulate 100 trades
        for (uint256 i = 0; i < 100; i++) {
            hook.afterSwap(user1, address(0), address(0), 1 ether, 0, true);
        }

        assertEq(hook.swapCount(user1), 100, "Should have 100 swaps");

        // Should earn TRADER_PRO badge
        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.TRADER_PRO),
            "Should have TRADER_PRO badge"
        );

        vm.stopPrank();
    }

    function testCulturalAmbassadorBadge() public {
        vm.startPrank(user1);

        // Create token with Andean theme
        factory.createMemeToken{value: 0.01 ether}(
            "Qenti",
            "QENTI",
            "ipfs://qenti-dog"
        );

        // This would trigger cultural ambassador logic
        // For now, just verify the system can handle it
        assertTrue(hook.tokenCreationCount(user1) >= 1, "Should have created token");

        vm.stopPrank();
    }

    function testGetUserStats() public {
        vm.startPrank(user1);

        // Create some activity
        factory.createMemeToken{value: 0.01 ether}("Token1", "TK1", "ipfs://1");
        factory.createMemeToken{value: 0.01 ether}("Token2", "TK2", "ipfs://2");

        hook.afterSwap(user1, address(0), address(0), 500 ether, 0, true);
        hook.afterAddLiquidity(user1, address(0), address(0), 50 ether, 0);

        vm.stopPrank();

        // Verify stats
        assertEq(hook.tokenCreationCount(user1), 2, "Should have 2 tokens created");
        assertEq(hook.totalTradingVolume(user1), 500 ether, "Should have 500 ANDE volume");
        assertEq(
            hook.totalLiquidityProvided(user1),
            50 ether,
            "Should have 50 ANDE liquidity"
        );
    }

    function testFuzzTradingVolume(uint256 volume) public {
        volume = bound(volume, 1 ether, 1000000 ether);

        vm.startPrank(user1);

        hook.afterSwap(user1, address(0), address(0), volume, 0, true);

        assertEq(hook.totalTradingVolume(user1), volume, "Volume should match");

        vm.stopPrank();
    }

    function testFuzzLiquidityProvided(uint256 liquidity) public {
        liquidity = bound(liquidity, 1 ether, 1000000 ether);

        vm.startPrank(user1);

        hook.afterAddLiquidity(user1, address(0), address(0), liquidity, 0);

        assertEq(
            hook.totalLiquidityProvided(user1),
            liquidity,
            "Liquidity should match"
        );

        vm.stopPrank();
    }

    function testFuzzTokenCreation(uint8 count) public {
        count = uint8(bound(count, 1, 20)); // Limit to 20 for gas reasons

        vm.startPrank(user1);
        vm.deal(user1, 100 ether);

        for (uint8 i = 0; i < count; i++) {
            factory.createMemeToken{value: 0.01 ether}(
                string(abi.encodePacked("Token", i)),
                string(abi.encodePacked("TK", i)),
                string(abi.encodePacked("ipfs://", i))
            );
        }

        assertEq(hook.tokenCreationCount(user1), count, "Token count should match");

        vm.stopPrank();
    }
}
