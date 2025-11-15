// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title QentiToken
 * @notice Governance token for QentiFi platform
 * @dev ERC20 with voting, burning, and permit functionality
 */
contract QentiToken is ERC20, ERC20Burnable, ERC20Votes, ERC20Permit, Ownable {
    // Total supply: 1 billion QENTI
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;

    // Distribution addresses
    address public communityRewards;
    address public daoTreasury;
    address public teamAndAdvisors;
    address public earlyBackers;

    // Vesting
    uint256 public immutable vestingStart;
    uint256 public constant VESTING_DURATION = 4 * 365 days; // 4 years
    uint256 public constant CLIFF_DURATION = 365 days; // 1 year cliff

    mapping(address => uint256) public vestedAmount;
    mapping(address => uint256) public claimedAmount;

    event TokensMinted(address indexed to, uint256 amount, string purpose);
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    constructor(
        address _communityRewards,
        address _daoTreasury,
        address _teamAndAdvisors,
        address _earlyBackers,
        address initialOwner
    )
        ERC20("Qenti Token", "QENTI")
        ERC20Permit("Qenti Token")
        Ownable(initialOwner)
    {
        require(_communityRewards != address(0), "Invalid community address");
        require(_daoTreasury != address(0), "Invalid treasury address");
        require(_teamAndAdvisors != address(0), "Invalid team address");
        require(_earlyBackers != address(0), "Invalid backers address");

        communityRewards = _communityRewards;
        daoTreasury = _daoTreasury;
        teamAndAdvisors = _teamAndAdvisors;
        earlyBackers = _earlyBackers;

        vestingStart = block.timestamp;

        // Initial distribution
        // 30% - Community Rewards (300M) - No vesting
        _mint(_communityRewards, 300_000_000 * 10**18);
        emit TokensMinted(_communityRewards, 300_000_000 * 10**18, "Community Rewards");

        // 25% - DAO Treasury (250M) - No vesting
        _mint(_daoTreasury, 250_000_000 * 10**18);
        emit TokensMinted(_daoTreasury, 250_000_000 * 10**18, "DAO Treasury");

        // 20% - Team & Advisors (200M) - 4 year vesting, 1 year cliff
        vestedAmount[_teamAndAdvisors] = 200_000_000 * 10**18;

        // 15% - Early Backers (150M) - 3 year vesting
        vestedAmount[_earlyBackers] = 150_000_000 * 10**18;

        // 10% - Public Sale (100M) - Minted via bonding curve
        // Remaining tokens for public sale
    }

    /**
     * @notice Calculate claimable tokens for vested beneficiary
     * @param beneficiary Address to check
     */
    function claimableTokens(address beneficiary) public view returns (uint256) {
        uint256 vested = vestedAmount[beneficiary];
        if (vested == 0) return 0;

        uint256 elapsed = block.timestamp - vestingStart;

        // Check cliff for team
        if (beneficiary == teamAndAdvisors && elapsed < CLIFF_DURATION) {
            return 0;
        }

        // Calculate vested amount
        uint256 totalVested;
        if (elapsed >= VESTING_DURATION) {
            totalVested = vested;
        } else {
            totalVested = (vested * elapsed) / VESTING_DURATION;
        }

        return totalVested - claimedAmount[beneficiary];
    }

    /**
     * @notice Claim vested tokens
     */
    function claimVestedTokens() external {
        uint256 claimable = claimableTokens(msg.sender);
        require(claimable > 0, "No tokens to claim");

        claimedAmount[msg.sender] += claimable;
        _mint(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    /**
     * @notice Mint tokens for public sale (bonding curve)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mintPublicSale(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
        emit TokensMinted(to, amount, "Public Sale");
    }

    // Override required functions
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
