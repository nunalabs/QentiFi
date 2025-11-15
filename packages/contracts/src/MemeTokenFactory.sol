// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MemeToken.sol";
import "./BondingCurveAMM.sol";
import "./interfaces/IQentiFiHooks.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MemeTokenFactory
 * @notice Factory contract for creating meme tokens with bonding curves
 * @dev Implements hooks system for extensibility (Uniswap v4 inspired)
 */
contract MemeTokenFactory is Ownable, ReentrancyGuard {
    struct TokenInfo {
        address tokenAddress;
        address bondingCurve;
        address creator;
        uint256 createdAt;
        bool graduated;
    }

    // State variables
    mapping(address => TokenInfo) public tokens;
    address[] public allTokens;
    mapping(address => address[]) public creatorTokens;

    address public hooksContract;
    address public poolManager;
    uint256 public creationFee;
    uint256 public constant GRADUATION_THRESHOLD = 50_000 * 10**18; // 50k ANDE volume

    // Events
    event TokenCreated(
        address indexed token,
        address indexed bondingCurve,
        address indexed creator,
        string name,
        string symbol,
        string imageURI
    );
    event TokenGraduated(address indexed token, address indexed pool);
    event HooksContractUpdated(address indexed newHooks);
    event CreationFeeUpdated(uint256 newFee);

    constructor(address initialOwner, uint256 _creationFee) Ownable(initialOwner) {
        creationFee = _creationFee;
    }

    /**
     * @notice Create a new meme token with bonding curve
     * @param name Token name
     * @param symbol Token symbol
     * @param imageURI IPFS URI for token image
     * @return token Address of created token
     * @return bondingCurve Address of bonding curve
     */
    function createMemeToken(
        string memory name,
        string memory symbol,
        string memory imageURI
    ) external payable nonReentrant returns (address token, address bondingCurve) {
        require(msg.value >= creationFee, "Insufficient creation fee");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(symbol).length > 0, "Symbol cannot be empty");

        // Execute beforeMint hook if exists
        if (hooksContract != address(0)) {
            IQentiFiHooks(hooksContract).beforeMint(
                msg.sender,
                name,
                symbol,
                imageURI
            );
        }

        // Deploy token
        MemeToken newToken = new MemeToken(name, symbol, imageURI, msg.sender);
        token = address(newToken);

        // Deploy bonding curve
        BondingCurveAMM curve = new BondingCurveAMM(token, address(this));
        bondingCurve = address(curve);

        // Set bonding curve in token
        newToken.setBondingCurve(bondingCurve);

        // Store token info
        tokens[token] = TokenInfo({
            tokenAddress: token,
            bondingCurve: bondingCurve,
            creator: msg.sender,
            createdAt: block.timestamp,
            graduated: false
        });

        allTokens.push(token);
        creatorTokens[msg.sender].push(token);

        emit TokenCreated(token, bondingCurve, msg.sender, name, symbol, imageURI);

        // Execute afterMint hook if exists
        if (hooksContract != address(0)) {
            IQentiFiHooks(hooksContract).afterMint(msg.sender, token, bondingCurve);
        }

        // Refund excess fee
        if (msg.value > creationFee) {
            payable(msg.sender).transfer(msg.value - creationFee);
        }
    }

    /**
     * @notice Graduate token from bonding curve to DEX pool
     * @param token Address of token to graduate
     */
    function graduateToken(address token) external nonReentrant {
        TokenInfo storage info = tokens[token];
        require(info.tokenAddress != address(0), "Token not found");
        require(!info.graduated, "Token already graduated");

        BondingCurveAMM curve = BondingCurveAMM(info.bondingCurve);
        require(curve.totalVolume() >= GRADUATION_THRESHOLD, "Threshold not met");

        // Mark as graduated
        info.graduated = true;

        // Create liquidity pool (will integrate with PoolManager)
        // TODO: Implement pool creation and liquidity migration

        emit TokenGraduated(token, address(0)); // pool address TBD
    }

    /**
     * @notice Get tokens created by an address
     * @param creator Address of creator
     * @return Array of token addresses
     */
    function getCreatorTokens(address creator) external view returns (address[] memory) {
        return creatorTokens[creator];
    }

    /**
     * @notice Get total number of tokens created
     * @return Total token count
     */
    function totalTokens() external view returns (uint256) {
        return allTokens.length;
    }

    /**
     * @notice Set hooks contract address
     * @param _hooksContract Address of hooks contract
     */
    function setHooksContract(address _hooksContract) external onlyOwner {
        hooksContract = _hooksContract;
        emit HooksContractUpdated(_hooksContract);
    }

    /**
     * @notice Update creation fee
     * @param _creationFee New creation fee in wei
     */
    function setCreationFee(uint256 _creationFee) external onlyOwner {
        creationFee = _creationFee;
        emit CreationFeeUpdated(_creationFee);
    }

    /**
     * @notice Withdraw collected fees
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        payable(owner()).transfer(balance);
    }

    receive() external payable {}
}
