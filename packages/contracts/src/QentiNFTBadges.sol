// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title QentiNFTBadges
 * @notice NFT badges for gamification and achievements
 * @dev Soulbound tokens (non-transferable) representing achievements
 */
contract QentiNFTBadges is ERC721, ERC721URIStorage, AccessControl {
    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    enum BadgeType {
        FIRST_MEME_CREATOR,      // Created first token
        LIQUIDITY_HERO,          // Provided >$1000 liquidity
        VOLUME_KING,             // $10k+ trading volume
        CULTURAL_AMBASSADOR,     // Completed cultural quests
        EARLY_ADOPTER,           // Top 1000 users
        DIAMOND_HANDS,           // Held >90 days
        WHALE,                   // $100k+ in platform
        COMMUNITY_LEADER,        // Referred 50+ users
        POOL_MASTER,             // Created 10+ pools
        TRADER_PRO               // 1000+ trades
    }

    struct Badge {
        BadgeType badgeType;
        uint256 mintedAt;
        uint256 level;           // Badge level (1-5)
        string metadata;         // Additional metadata
    }

    // Token ID => Badge info
    mapping(uint256 => Badge) public badges;

    // User => BadgeType => has badge
    mapping(address => mapping(BadgeType => bool)) public hasBadge;

    // User => BadgeType => badge level
    mapping(address => mapping(BadgeType => uint256)) public badgeLevel;

    // Next token ID
    uint256 private _nextTokenId;

    // Base URI for metadata
    string private _baseTokenURI;

    // Events
    event BadgeMinted(
        address indexed to,
        uint256 indexed tokenId,
        BadgeType badgeType,
        uint256 level
    );
    event BadgeUpgraded(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 newLevel
    );

    constructor(
        string memory baseURI,
        address admin
    ) ERC721("Qenti Badges", "QBADGE") {
        _baseTokenURI = baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    /**
     * @notice Mint a new badge
     * @param to Recipient address
     * @param badgeType Type of badge
     * @param level Badge level (1-5)
     * @param metadata Additional metadata
     */
    function mintBadge(
        address to,
        BadgeType badgeType,
        uint256 level,
        string memory metadata
    ) external onlyRole(MINTER_ROLE) returns (uint256) {
        require(!hasBadge[to][badgeType], "Badge already owned");
        require(level >= 1 && level <= 5, "Invalid level");

        uint256 tokenId = _nextTokenId++;

        // Mint NFT
        _safeMint(to, tokenId);

        // Store badge info
        badges[tokenId] = Badge({
            badgeType: badgeType,
            mintedAt: block.timestamp,
            level: level,
            metadata: metadata
        });

        // Mark as owned
        hasBadge[to][badgeType] = true;
        badgeLevel[to][badgeType] = level;

        emit BadgeMinted(to, tokenId, badgeType, level);

        return tokenId;
    }

    /**
     * @notice Upgrade badge level
     * @param tokenId Token ID to upgrade
     * @param newLevel New level
     */
    function upgradeBadge(uint256 tokenId, uint256 newLevel)
        external
        onlyRole(MINTER_ROLE)
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        require(newLevel >= 1 && newLevel <= 5, "Invalid level");

        Badge storage badge = badges[tokenId];
        require(newLevel > badge.level, "Level must increase");

        address owner = ownerOf(tokenId);

        // Update level
        badge.level = newLevel;
        badgeLevel[owner][badge.badgeType] = newLevel;

        emit BadgeUpgraded(owner, tokenId, newLevel);
    }

    /**
     * @notice Get all badges owned by user
     * @param owner User address
     */
    function getUserBadges(address owner)
        external
        view
        returns (uint256[] memory tokenIds)
    {
        uint256 balance = balanceOf(owner);
        tokenIds = new uint256[](balance);

        uint256 index = 0;
        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (_ownerOf(i) == owner) {
                tokenIds[index] = i;
                index++;
            }
        }
    }

    /**
     * @notice Check if user has specific badge type
     * @param owner User address
     * @param badgeType Badge type to check
     */
    function hasSpecificBadge(address owner, BadgeType badgeType)
        external
        view
        returns (bool)
    {
        return hasBadge[owner][badgeType];
    }

    /**
     * @notice Get badge level for user
     * @param owner User address
     * @param badgeType Badge type
     */
    function getBadgeLevel(address owner, BadgeType badgeType)
        external
        view
        returns (uint256)
    {
        return badgeLevel[owner][badgeType];
    }

    /**
     * @notice Get total badges minted
     */
    function totalBadges() external view returns (uint256) {
        return _nextTokenId;
    }

    /**
     * @notice Override transfer to make badges soulbound
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);

        // Allow minting (from == address(0))
        // Prevent transfers (from != address(0))
        require(from == address(0), "Badges are soulbound and cannot be transferred");

        return super._update(to, tokenId, auth);
    }

    // Override required functions
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        Badge memory badge = badges[tokenId];

        // Return dynamic URI based on badge type and level
        return string(
            abi.encodePacked(
                _baseTokenURI,
                uint256(badge.badgeType).toString(),
                "/",
                badge.level.toString(),
                ".json"
            )
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setBaseURI(string memory baseURI) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI;
    }
}
