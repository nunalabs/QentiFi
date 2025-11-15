// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/QentiFiPoolManager.sol";
import "../src/MemeToken.sol";
import "../src/MemeTokenFactory.sol";

contract QentiFiPoolManagerTest is Test {
    QentiFiPoolManager public poolManager;
    MemeTokenFactory public factory;
    MemeToken public token0;
    MemeToken public token1;

    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 fee,
        address hooks
    );

    event SwapExecuted(
        address indexed user,
        address indexed token0,
        address indexed token1,
        bool zeroForOne,
        uint256 amountIn,
        uint256 amountOut
    );

    event LiquidityAdded(
        address indexed provider,
        address indexed token0,
        address indexed token1,
        uint256 amount0,
        uint256 amount1
    );

    function setUp() public {
        vm.startPrank(owner);

        // Deploy factory and pool manager
        factory = new MemeTokenFactory(owner);
        poolManager = new QentiFiPoolManager();

        // Create two tokens for testing
        (address _token0,) = factory.createMemeToken{value: 0.01 ether}(
            "Token0",
            "TK0",
            "ipfs://token0"
        );
        token0 = MemeToken(_token0);

        (address _token1,) = factory.createMemeToken{value: 0.01 ether}(
            "Token1",
            "TK1",
            "ipfs://token1"
        );
        token1 = MemeToken(_token1);

        // Order tokens
        if (address(token0) > address(token1)) {
            (token0, token1) = (token1, token0);
        }

        vm.stopPrank();
    }

    function testCreatePool() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000, // 0.3%
            hooks: address(0)
        });

        vm.expectEmit(true, true, false, false);
        emit PoolCreated(address(token0), address(token1), 3000, address(0));

        poolManager.createPool(key, 1e18); // Initial price 1:1

        // Verify pool was created
        bytes32 poolId = poolManager.getPoolId(key);
        (uint256 reserve0, uint256 reserve1, uint256 totalLiquidity, bool initialized) =
            poolManager.getPool(key);

        assertTrue(initialized, "Pool should be initialized");
        assertEq(totalLiquidity, 0, "Initial liquidity should be 0");

        vm.stopPrank();
    }

    function testCannotCreateDuplicatePool() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Try to create the same pool again
        vm.expectRevert("Pool already exists");
        poolManager.createPool(key, 1e18);

        vm.stopPrank();
    }

    function testAddLiquidity() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Mint tokens to user1
        vm.stopPrank();
        vm.startPrank(user1);
        vm.deal(user1, 100 ether);

        // Get some tokens (assuming they have bonding curves)
        // For now, we'll mint directly from factory owner
        vm.stopPrank();
        vm.startPrank(owner);

        // Approve pool manager
        uint256 amount0 = 1000e18;
        uint256 amount1 = 1000e18;

        token0.approve(address(poolManager), amount0);
        token1.approve(address(poolManager), amount1);

        vm.expectEmit(true, true, true, false);
        emit LiquidityAdded(owner, address(token0), address(token1), amount0, amount1);

        uint256 liquidity = poolManager.addLiquidity(key, amount0, amount1, 0);

        assertTrue(liquidity > 0, "Should receive liquidity tokens");

        vm.stopPrank();
    }

    function testSwap() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Add liquidity
        uint256 amount0 = 10000e18;
        uint256 amount1 = 10000e18;

        token0.approve(address(poolManager), amount0);
        token1.approve(address(poolManager), amount1);
        poolManager.addLiquidity(key, amount0, amount1, 0);

        // Prepare for swap
        uint256 swapAmount = 100e18;
        token0.approve(address(poolManager), swapAmount);

        uint256 balanceBefore = token1.balanceOf(owner);

        vm.expectEmit(true, true, true, false);
        emit SwapExecuted(owner, address(token0), address(token1), true, swapAmount, 0);

        uint256 amountOut = poolManager.swap(key, true, swapAmount, 1);

        assertGt(amountOut, 0, "Should receive tokens");
        assertEq(
            token1.balanceOf(owner),
            balanceBefore + amountOut,
            "Balance should increase"
        );

        vm.stopPrank();
    }

    function testSwapWithSlippageProtection() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Add liquidity
        token0.approve(address(poolManager), 10000e18);
        token1.approve(address(poolManager), 10000e18);
        poolManager.addLiquidity(key, 10000e18, 10000e18, 0);

        // Try swap with unrealistic minAmountOut
        uint256 swapAmount = 100e18;
        token0.approve(address(poolManager), swapAmount);

        vm.expectRevert("Slippage too high");
        poolManager.swap(key, true, swapAmount, 1000e18); // Expecting way too much

        vm.stopPrank();
    }

    function testRemoveLiquidity() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Add liquidity
        uint256 amount0 = 10000e18;
        uint256 amount1 = 10000e18;

        token0.approve(address(poolManager), amount0);
        token1.approve(address(poolManager), amount1);
        uint256 liquidity = poolManager.addLiquidity(key, amount0, amount1, 0);

        // Remove half the liquidity
        uint256 liquidityToRemove = liquidity / 2;

        (uint256 amount0Out, uint256 amount1Out) = poolManager.removeLiquidity(
            key,
            liquidityToRemove,
            0,
            0
        );

        assertGt(amount0Out, 0, "Should receive token0");
        assertGt(amount1Out, 0, "Should receive token1");

        vm.stopPrank();
    }

    function testFuzzSwap(uint256 amount) public {
        // Bound amount to reasonable values
        amount = bound(amount, 1e18, 1000e18);

        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Add liquidity
        token0.approve(address(poolManager), 100000e18);
        token1.approve(address(poolManager), 100000e18);
        poolManager.addLiquidity(key, 100000e18, 100000e18, 0);

        // Swap
        token0.approve(address(poolManager), amount);
        uint256 amountOut = poolManager.swap(key, true, amount, 1);

        assertGt(amountOut, 0, "Should receive tokens");

        vm.stopPrank();
    }

    function testInvariantConstantProduct() public {
        vm.startPrank(owner);

        QentiFiPoolManager.PoolKey memory key = QentiFiPoolManager.PoolKey({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            hooks: address(0)
        });

        poolManager.createPool(key, 1e18);

        // Add liquidity
        uint256 amount0 = 10000e18;
        uint256 amount1 = 10000e18;

        token0.approve(address(poolManager), amount0);
        token1.approve(address(poolManager), amount1);
        poolManager.addLiquidity(key, amount0, amount1, 0);

        (uint256 reserve0Before, uint256 reserve1Before,,) = poolManager.getPool(key);
        uint256 kBefore = reserve0Before * reserve1Before;

        // Perform swap
        uint256 swapAmount = 100e18;
        token0.approve(address(poolManager), swapAmount);
        poolManager.swap(key, true, swapAmount, 1);

        (uint256 reserve0After, uint256 reserve1After,,) = poolManager.getPool(key);
        uint256 kAfter = reserve0After * reserve1After;

        // K should increase or stay the same due to fees
        assertGe(kAfter, kBefore, "K should not decrease");

        vm.stopPrank();
    }
}
