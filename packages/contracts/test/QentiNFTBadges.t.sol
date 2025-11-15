// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/QentiNFTBadges.sol";

contract QentiNFTBadgesTest is Test {
    QentiNFTBadges public badges;

    address public owner = address(1);
    address public minter = address(2);
    address public user1 = address(3);
    address public user2 = address(4);

    event BadgeMinted(
        address indexed to,
        uint256 indexed tokenId,
        QentiNFTBadges.BadgeType badgeType,
        uint8 level
    );

    function setUp() public {
        vm.startPrank(owner);

        badges = new QentiNFTBadges();

        // Grant minter role
        badges.grantRole(badges.MINTER_ROLE(), minter);

        vm.stopPrank();
    }

    function testMintBadge() public {
        vm.startPrank(minter);

        vm.expectEmit(true, true, false, true);
        emit BadgeMinted(user1, 1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR, 1);

        uint256 tokenId = badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://badge/first-meme-creator-1"
        );

        assertEq(tokenId, 1, "Token ID should be 1");
        assertEq(badges.ownerOf(tokenId), user1, "User1 should own the badge");
        assertEq(badges.balanceOf(user1), 1, "User1 should have 1 badge");

        vm.stopPrank();
    }

    function testOnlyMinterCanMint() public {
        vm.startPrank(user1);

        vm.expectRevert();
        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://badge"
        );

        vm.stopPrank();
    }

    function testBadgesAreSoulbound() public {
        vm.startPrank(minter);

        uint256 tokenId = badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://badge"
        );

        vm.stopPrank();

        // User1 tries to transfer badge to user2
        vm.startPrank(user1);

        vm.expectRevert("Badges are soulbound");
        badges.transferFrom(user1, user2, tokenId);

        vm.stopPrank();
    }

    function testCannotApprove() public {
        vm.startPrank(minter);

        uint256 tokenId = badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://badge"
        );

        vm.stopPrank();

        vm.startPrank(user1);

        vm.expectRevert("Badges are soulbound");
        badges.approve(user2, tokenId);

        vm.stopPrank();
    }

    function testCannotSetApprovalForAll() public {
        vm.startPrank(user1);

        vm.expectRevert("Badges are soulbound");
        badges.setApprovalForAll(user2, true);

        vm.stopPrank();
    }

    function testGetBadgeInfo() public {
        vm.startPrank(minter);

        uint256 tokenId = badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.LIQUIDITY_HERO,
            3,
            "ipfs://badge/liquidity-hero-3"
        );

        vm.stopPrank();

        (QentiNFTBadges.BadgeType badgeType, uint8 level, uint256 mintedAt) =
            badges.getBadgeInfo(tokenId);

        assertEq(uint256(badgeType), uint256(QentiNFTBadges.BadgeType.LIQUIDITY_HERO));
        assertEq(level, 3, "Level should be 3");
        assertEq(mintedAt, block.timestamp, "Minted at should be current timestamp");
    }

    function testGetUserBadges() public {
        vm.startPrank(minter);

        // Mint multiple badges to user1
        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://1"
        );
        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.LIQUIDITY_HERO,
            2,
            "ipfs://2"
        );
        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.VOLUME_KING,
            3,
            "ipfs://3"
        );

        vm.stopPrank();

        uint256[] memory userBadges = badges.getUserBadges(user1);

        assertEq(userBadges.length, 3, "User1 should have 3 badges");
        assertEq(userBadges[0], 1, "First badge should be token ID 1");
        assertEq(userBadges[1], 2, "Second badge should be token ID 2");
        assertEq(userBadges[2], 3, "Third badge should be token ID 3");
    }

    function testHasBadge() public {
        vm.startPrank(minter);

        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://badge"
        );

        vm.stopPrank();

        assertTrue(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR),
            "User1 should have FIRST_MEME_CREATOR badge"
        );

        assertFalse(
            badges.hasBadge(user1, QentiNFTBadges.BadgeType.LIQUIDITY_HERO),
            "User1 should not have LIQUIDITY_HERO badge"
        );
    }

    function testMultipleLevels() public {
        vm.startPrank(minter);

        // Mint same badge type but different levels
        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.VOLUME_KING,
            1,
            "ipfs://level-1"
        );

        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.VOLUME_KING,
            2,
            "ipfs://level-2"
        );

        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.VOLUME_KING,
            3,
            "ipfs://level-3"
        );

        vm.stopPrank();

        assertEq(badges.balanceOf(user1), 3, "User1 should have 3 badges");

        uint256[] memory userBadges = badges.getUserBadges(user1);
        assertEq(userBadges.length, 3, "Should have 3 badges");

        // Check levels
        (, uint8 level1,) = badges.getBadgeInfo(userBadges[0]);
        (, uint8 level2,) = badges.getBadgeInfo(userBadges[1]);
        (, uint8 level3,) = badges.getBadgeInfo(userBadges[2]);

        assertEq(level1, 1, "First badge should be level 1");
        assertEq(level2, 2, "Second badge should be level 2");
        assertEq(level3, 3, "Third badge should be level 3");
    }

    function testAllBadgeTypes() public {
        vm.startPrank(minter);

        // Test all 10 badge types
        QentiNFTBadges.BadgeType[10] memory allTypes = [
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            QentiNFTBadges.BadgeType.LIQUIDITY_HERO,
            QentiNFTBadges.BadgeType.VOLUME_KING,
            QentiNFTBadges.BadgeType.CULTURAL_AMBASSADOR,
            QentiNFTBadges.BadgeType.EARLY_ADOPTER,
            QentiNFTBadges.BadgeType.DIAMOND_HANDS,
            QentiNFTBadges.BadgeType.WHALE,
            QentiNFTBadges.BadgeType.COMMUNITY_LEADER,
            QentiNFTBadges.BadgeType.POOL_MASTER,
            QentiNFTBadges.BadgeType.TRADER_PRO
        ];

        for (uint256 i = 0; i < allTypes.length; i++) {
            badges.mintBadge(user1, allTypes[i], 1, string(abi.encodePacked("ipfs://", i)));
        }

        vm.stopPrank();

        assertEq(badges.balanceOf(user1), 10, "User1 should have 10 badges");

        // Verify user has each badge type
        for (uint256 i = 0; i < allTypes.length; i++) {
            assertTrue(
                badges.hasBadge(user1, allTypes[i]),
                "User1 should have all badge types"
            );
        }
    }

    function testTokenURI() public {
        vm.startPrank(minter);

        string memory uri = "ipfs://QmTestHash/metadata.json";
        uint256 tokenId = badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            uri
        );

        vm.stopPrank();

        assertEq(badges.tokenURI(tokenId), uri, "Token URI should match");
    }

    function testSupportsInterface() public {
        // ERC721
        assertTrue(badges.supportsInterface(0x80ac58cd), "Should support ERC721");

        // ERC721Metadata
        assertTrue(badges.supportsInterface(0x5b5e139f), "Should support ERC721Metadata");

        // AccessControl
        assertTrue(badges.supportsInterface(0x7965db0b), "Should support AccessControl");
    }

    function testOnlyAdminCanGrantRoles() public {
        vm.startPrank(user1);

        vm.expectRevert();
        badges.grantRole(badges.MINTER_ROLE(), user2);

        vm.stopPrank();
    }

    function testAdminCanRevokeRoles() public {
        vm.startPrank(owner);

        badges.revokeRole(badges.MINTER_ROLE(), minter);

        vm.stopPrank();

        // Minter should no longer be able to mint
        vm.startPrank(minter);

        vm.expectRevert();
        badges.mintBadge(
            user1,
            QentiNFTBadges.BadgeType.FIRST_MEME_CREATOR,
            1,
            "ipfs://badge"
        );

        vm.stopPrank();
    }

    function testFuzzMintBadge(uint8 badgeTypeRaw, uint8 level) public {
        vm.startPrank(minter);

        // Bound to valid badge type (0-9)
        QentiNFTBadges.BadgeType badgeType = QentiNFTBadges.BadgeType(
            bound(badgeTypeRaw, 0, 9)
        );

        // Bound to valid level (1-5)
        level = uint8(bound(level, 1, 5));

        uint256 tokenId = badges.mintBadge(user1, badgeType, level, "ipfs://test");

        assertEq(badges.ownerOf(tokenId), user1, "User should own the badge");

        (QentiNFTBadges.BadgeType mintedType, uint8 mintedLevel,) =
            badges.getBadgeInfo(tokenId);

        assertEq(uint256(mintedType), uint256(badgeType), "Badge type should match");
        assertEq(mintedLevel, level, "Level should match");

        vm.stopPrank();
    }
}
