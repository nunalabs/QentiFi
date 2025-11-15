// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MemeToken.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title BondingCurveAMM
 * @notice Automated Market Maker using exponential bonding curve
 * @dev Implements Pump.fun inspired fair launch mechanism
 *
 * Price formula: price = basePrice * (1 + k * supply)
 * Where k is the growth factor
 */
contract BondingCurveAMM is ReentrancyGuard {
    using Math for uint256;

    MemeToken public immutable token;
    address public immutable factory;

    // Bonding curve parameters
    uint256 public constant BASE_PRICE = 0.0001 ether; // 0.0001 ANDE per token initially
    uint256 public constant GROWTH_FACTOR = 1; // Linear growth for simplicity
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // 1M tokens max
    uint256 public constant FEE_PERCENT = 3; // 0.3% fee

    // State
    uint256 public totalVolume;
    uint256 public currentSupply;
    uint256 public reserveBalance;

    // Events
    event TokensPurchased(
        address indexed buyer,
        uint256 andeAmount,
        uint256 tokenAmount,
        uint256 price
    );
    event TokensSold(
        address indexed seller,
        uint256 tokenAmount,
        uint256 andeAmount,
        uint256 price
    );

    constructor(address _token, address _factory) {
        token = MemeToken(_token);
        factory = _factory;
    }

    /**
     * @notice Buy tokens with ANDE
     * @param minTokens Minimum tokens to receive (slippage protection)
     * @return tokenAmount Amount of tokens received
     */
    function buyTokens(uint256 minTokens)
        external
        payable
        nonReentrant
        returns (uint256 tokenAmount)
    {
        require(msg.value > 0, "Must send ANDE");

        // Calculate how many tokens can be bought
        tokenAmount = calculatePurchaseReturn(msg.value);
        require(tokenAmount >= minTokens, "Slippage too high");
        require(currentSupply + tokenAmount <= MAX_SUPPLY, "Exceeds max supply");

        // Calculate fee
        uint256 fee = (msg.value * FEE_PERCENT) / 1000;
        uint256 netAmount = msg.value - fee;

        // Update state
        currentSupply += tokenAmount;
        reserveBalance += netAmount;
        totalVolume += msg.value;

        // Mint tokens to buyer
        token.mint(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, msg.value, tokenAmount, getCurrentPrice());
    }

    /**
     * @notice Sell tokens for ANDE
     * @param tokenAmount Amount of tokens to sell
     * @param minAnde Minimum ANDE to receive (slippage protection)
     * @return andeAmount Amount of ANDE received
     */
    function sellTokens(uint256 tokenAmount, uint256 minAnde)
        external
        nonReentrant
        returns (uint256 andeAmount)
    {
        require(tokenAmount > 0, "Must sell tokens");
        require(token.balanceOf(msg.sender) >= tokenAmount, "Insufficient balance");

        // Calculate ANDE return
        andeAmount = calculateSaleReturn(tokenAmount);
        require(andeAmount >= minAnde, "Slippage too high");
        require(reserveBalance >= andeAmount, "Insufficient reserve");

        // Calculate fee
        uint256 fee = (andeAmount * FEE_PERCENT) / 1000;
        uint256 netAmount = andeAmount - fee;

        // Update state
        currentSupply -= tokenAmount;
        reserveBalance -= andeAmount;
        totalVolume += andeAmount;

        // Burn tokens
        token.transferFrom(msg.sender, address(this), tokenAmount);
        // Note: In production, implement proper burn mechanism

        // Transfer ANDE to seller
        payable(msg.sender).transfer(netAmount);

        emit TokensSold(msg.sender, tokenAmount, netAmount, getCurrentPrice());
    }

    /**
     * @notice Calculate tokens received for ANDE amount
     * @param andeAmount Amount of ANDE to spend
     * @return tokenAmount Amount of tokens that will be received
     */
    function calculatePurchaseReturn(uint256 andeAmount)
        public
        view
        returns (uint256 tokenAmount)
    {
        // Simplified calculation for linear bonding curve
        // price = BASE_PRICE * (1 + supply/1M)
        // In production, use more sophisticated math

        uint256 avgPrice = BASE_PRICE + (BASE_PRICE * currentSupply) / MAX_SUPPLY;
        tokenAmount = (andeAmount * 10**18) / avgPrice;
    }

    /**
     * @notice Calculate ANDE received for token amount
     * @param tokenAmount Amount of tokens to sell
     * @return andeAmount Amount of ANDE that will be received
     */
    function calculateSaleReturn(uint256 tokenAmount)
        public
        view
        returns (uint256 andeAmount)
    {
        uint256 avgPrice = BASE_PRICE + (BASE_PRICE * currentSupply) / MAX_SUPPLY;
        andeAmount = (tokenAmount * avgPrice) / 10**18;
    }

    /**
     * @notice Get current price per token
     * @return Current price in wei
     */
    function getCurrentPrice() public view returns (uint256) {
        return BASE_PRICE + (BASE_PRICE * currentSupply * GROWTH_FACTOR) / MAX_SUPPLY;
    }

    /**
     * @notice Get quote for buying tokens
     * @param andeAmount Amount of ANDE to spend
     * @return tokens Amount of tokens
     * @return price Price per token
     */
    function getQuoteBuy(uint256 andeAmount)
        external
        view
        returns (uint256 tokens, uint256 price)
    {
        tokens = calculatePurchaseReturn(andeAmount);
        price = getCurrentPrice();
    }

    /**
     * @notice Get quote for selling tokens
     * @param tokenAmount Amount of tokens to sell
     * @return ande Amount of ANDE
     * @return price Price per token
     */
    function getQuoteSell(uint256 tokenAmount)
        external
        view
        returns (uint256 ande, uint256 price)
    {
        ande = calculateSaleReturn(tokenAmount);
        price = getCurrentPrice();
    }
}
