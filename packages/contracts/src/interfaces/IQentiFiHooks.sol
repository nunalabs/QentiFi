// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IQentiFiHooks
 * @notice Interface for QentiFi hooks system
 * @dev Inspired by Uniswap v4 hooks architecture
 */
interface IQentiFiHooks {
    /**
     * @notice Called before minting a new meme token
     * @param creator Address creating the token
     * @param name Token name
     * @param symbol Token symbol
     * @param imageURI Token image URI
     */
    function beforeMint(
        address creator,
        string memory name,
        string memory symbol,
        string memory imageURI
    ) external;

    /**
     * @notice Called after minting a new meme token
     * @param creator Address that created the token
     * @param token Address of the created token
     * @param bondingCurve Address of the bonding curve
     */
    function afterMint(
        address creator,
        address token,
        address bondingCurve
    ) external;

    /**
     * @notice Called before a swap occurs
     * @param user Address executing the swap
     * @param tokenIn Address of input token
     * @param tokenOut Address of output token
     * @param amountIn Amount of input tokens
     */
    function beforeSwap(
        address user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external;

    /**
     * @notice Called after a swap occurs
     * @param user Address that executed the swap
     * @param tokenIn Address of input token
     * @param tokenOut Address of output token
     * @param amountIn Amount of input tokens
     * @param amountOut Amount of output tokens
     */
    function afterSwap(
        address user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    ) external;
}
