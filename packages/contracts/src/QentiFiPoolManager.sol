// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IQentiFiHooks.sol";

/**
 * @title QentiFiPoolManager
 * @notice Singleton pool manager inspired by Uniswap v4
 * @dev All pools managed in single contract for gas efficiency
 */
contract QentiFiPoolManager is Ownable, ReentrancyGuard {
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
        address hooks;
    }

    struct Pool {
        uint256 reserve0;
        uint256 reserve1;
        uint256 totalLiquidity;
        uint256 lastUpdate;
        bool initialized;
    }

    struct Position {
        uint256 liquidity;
        uint256 token0Owed;
        uint256 token1Owed;
    }

    // Pool ID => Pool
    mapping(bytes32 => Pool) public pools;

    // Pool ID => User => Position
    mapping(bytes32 => mapping(address => Position)) public positions;

    // Fee tiers (0.01%, 0.05%, 0.3%, 1%)
    uint24 public constant FEE_TIER_LOWEST = 100; // 0.01%
    uint24 public constant FEE_TIER_LOW = 500; // 0.05%
    uint24 public constant FEE_TIER_MEDIUM = 3000; // 0.3%
    uint24 public constant FEE_TIER_HIGH = 10000; // 1%

    // Events
    event PoolInitialized(
        bytes32 indexed poolId,
        address indexed token0,
        address indexed token1,
        uint24 fee
    );
    event LiquidityAdded(
        bytes32 indexed poolId,
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );
    event LiquidityRemoved(
        bytes32 indexed poolId,
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );
    event Swap(
        bytes32 indexed poolId,
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Get pool ID from pool key
     * @param key Pool key
     * @return Pool ID (keccak256 hash)
     */
    function getPoolId(PoolKey memory key) public pure returns (bytes32) {
        return keccak256(abi.encode(key.token0, key.token1, key.fee, key.hooks));
    }

    /**
     * @notice Initialize a new pool
     * @param key Pool key
     * @param initialPrice0 Initial price of token0 in token1
     */
    function initializePool(
        PoolKey memory key,
        uint256 initialPrice0
    ) external onlyOwner returns (bytes32 poolId) {
        require(key.token0 < key.token1, "Tokens must be sorted");
        require(
            key.fee == FEE_TIER_LOWEST ||
            key.fee == FEE_TIER_LOW ||
            key.fee == FEE_TIER_MEDIUM ||
            key.fee == FEE_TIER_HIGH,
            "Invalid fee tier"
        );

        poolId = getPoolId(key);
        require(!pools[poolId].initialized, "Pool already initialized");

        pools[poolId] = Pool({
            reserve0: 0,
            reserve1: 0,
            totalLiquidity: 0,
            lastUpdate: block.timestamp,
            initialized: true
        });

        emit PoolInitialized(poolId, key.token0, key.token1, key.fee);
    }

    /**
     * @notice Add liquidity to pool
     * @param key Pool key
     * @param amount0 Amount of token0
     * @param amount1 Amount of token1
     */
    function addLiquidity(
        PoolKey memory key,
        uint256 amount0,
        uint256 amount1
    ) external nonReentrant returns (uint256 liquidity) {
        bytes32 poolId = getPoolId(key);
        Pool storage pool = pools[poolId];
        require(pool.initialized, "Pool not initialized");

        // Execute beforeAddLiquidity hook if exists
        if (key.hooks != address(0)) {
            // Hook execution here
        }

        // Calculate liquidity
        if (pool.totalLiquidity == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min(
                (amount0 * pool.totalLiquidity) / pool.reserve0,
                (amount1 * pool.totalLiquidity) / pool.reserve1
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");

        // Update pool
        pool.reserve0 += amount0;
        pool.reserve1 += amount1;
        pool.totalLiquidity += liquidity;
        pool.lastUpdate = block.timestamp;

        // Update position
        Position storage position = positions[poolId][msg.sender];
        position.liquidity += liquidity;

        // Transfer tokens (would need actual ERC20 transfers)
        // IERC20(key.token0).transferFrom(msg.sender, address(this), amount0);
        // IERC20(key.token1).transferFrom(msg.sender, address(this), amount1);

        emit LiquidityAdded(poolId, msg.sender, amount0, amount1, liquidity);

        // Execute afterAddLiquidity hook if exists
        if (key.hooks != address(0)) {
            // Hook execution here
        }
    }

    /**
     * @notice Remove liquidity from pool
     * @param key Pool key
     * @param liquidityAmount Amount of liquidity to remove
     */
    function removeLiquidity(
        PoolKey memory key,
        uint256 liquidityAmount
    ) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        bytes32 poolId = getPoolId(key);
        Pool storage pool = pools[poolId];
        Position storage position = positions[poolId][msg.sender];

        require(position.liquidity >= liquidityAmount, "Insufficient liquidity");

        // Calculate amounts
        amount0 = (liquidityAmount * pool.reserve0) / pool.totalLiquidity;
        amount1 = (liquidityAmount * pool.reserve1) / pool.totalLiquidity;

        // Update pool
        pool.reserve0 -= amount0;
        pool.reserve1 -= amount1;
        pool.totalLiquidity -= liquidityAmount;
        pool.lastUpdate = block.timestamp;

        // Update position
        position.liquidity -= liquidityAmount;

        // Transfer tokens back
        // IERC20(key.token0).transfer(msg.sender, amount0);
        // IERC20(key.token1).transfer(msg.sender, amount1);

        emit LiquidityRemoved(poolId, msg.sender, amount0, amount1, liquidityAmount);
    }

    /**
     * @notice Swap tokens
     * @param key Pool key
     * @param zeroForOne True if swapping token0 for token1
     * @param amountIn Amount of input token
     * @param minAmountOut Minimum amount of output token (slippage protection)
     */
    function swap(
        PoolKey memory key,
        bool zeroForOne,
        uint256 amountIn,
        uint256 minAmountOut
    ) external nonReentrant returns (uint256 amountOut) {
        bytes32 poolId = getPoolId(key);
        Pool storage pool = pools[poolId];
        require(pool.initialized, "Pool not initialized");

        // Execute beforeSwap hook
        if (key.hooks != address(0)) {
            IQentiFiHooks(key.hooks).beforeSwap(
                msg.sender,
                zeroForOne ? key.token0 : key.token1,
                zeroForOne ? key.token1 : key.token0,
                amountIn
            );
        }

        // Calculate output amount (constant product formula)
        uint256 amountInWithFee = amountIn * (10000 - key.fee) / 10000;

        if (zeroForOne) {
            amountOut = (pool.reserve1 * amountInWithFee) /
                       (pool.reserve0 + amountInWithFee);
            require(amountOut >= minAmountOut, "Slippage too high");

            pool.reserve0 += amountIn;
            pool.reserve1 -= amountOut;
        } else {
            amountOut = (pool.reserve0 * amountInWithFee) /
                       (pool.reserve1 + amountInWithFee);
            require(amountOut >= minAmountOut, "Slippage too high");

            pool.reserve1 += amountIn;
            pool.reserve0 -= amountOut;
        }

        pool.lastUpdate = block.timestamp;

        emit Swap(
            poolId,
            msg.sender,
            zeroForOne ? key.token0 : key.token1,
            amountIn,
            amountOut
        );

        // Execute afterSwap hook
        if (key.hooks != address(0)) {
            IQentiFiHooks(key.hooks).afterSwap(
                msg.sender,
                zeroForOne ? key.token0 : key.token1,
                zeroForOne ? key.token1 : key.token0,
                amountIn,
                amountOut
            );
        }
    }

    /**
     * @notice Get pool reserves
     * @param poolId Pool ID
     */
    function getReserves(bytes32 poolId)
        external
        view
        returns (uint256 reserve0, uint256 reserve1)
    {
        Pool memory pool = pools[poolId];
        return (pool.reserve0, pool.reserve1);
    }

    // Math helpers
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }
}
