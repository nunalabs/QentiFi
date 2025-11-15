// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/MemeTokenFactory.sol";
import "../src/MemeToken.sol";
import "../src/BondingCurveAMM.sol";

contract MemeTokenFactoryTest is Test {
    MemeTokenFactory public factory;
    address public owner;
    address public creator;
    address public user;

    uint256 constant CREATION_FEE = 0.01 ether;

    event TokenCreated(
        address indexed token,
        address indexed bondingCurve,
        address indexed creator,
        string name,
        string symbol,
        string imageURI
    );

    function setUp() public {
        owner = address(this);
        creator = makeAddr("creator");
        user = makeAddr("user");

        // Deploy factory
        factory = new MemeTokenFactory(owner, CREATION_FEE);

        // Fund creator
        vm.deal(creator, 10 ether);
        vm.deal(user, 10 ether);
    }

    function testCreateMemeToken() public {
        vm.startPrank(creator);

        // Create token
        (address token, address bondingCurve) = factory.createMemeToken{
            value: CREATION_FEE
        }("Qenti Coin", "QENTI", "ipfs://QmTest");

        // Verify token was created
        assertTrue(token != address(0), "Token address should not be zero");
        assertTrue(bondingCurve != address(0), "Bonding curve should not be zero");

        // Verify token info
        (
            address tokenAddress,
            address curve,
            address tokenCreator,
            uint256 createdAt,
            bool graduated
        ) = factory.tokens(token);

        assertEq(tokenAddress, token);
        assertEq(curve, bondingCurve);
        assertEq(tokenCreator, creator);
        assertTrue(createdAt > 0);
        assertFalse(graduated);

        vm.stopPrank();
    }

    function testCreateMemeTokenEmitsEvent() public {
        vm.startPrank(creator);

        vm.expectEmit(false, true, true, false);
        emit TokenCreated(
            address(0), // We don't know the token address yet
            address(0), // We don't know the bonding curve address yet
            creator,
            "Qenti Coin",
            "QENTI",
            "ipfs://QmTest"
        );

        factory.createMemeToken{value: CREATION_FEE}(
            "Qenti Coin",
            "QENTI",
            "ipfs://QmTest"
        );

        vm.stopPrank();
    }

    function testCannotCreateWithInsufficientFee() public {
        vm.startPrank(creator);

        vm.expectRevert("Insufficient creation fee");
        factory.createMemeToken{value: 0.001 ether}(
            "Qenti Coin",
            "QENTI",
            "ipfs://QmTest"
        );

        vm.stopPrank();
    }

    function testCannotCreateWithEmptyName() public {
        vm.startPrank(creator);

        vm.expectRevert("Name cannot be empty");
        factory.createMemeToken{value: CREATION_FEE}("", "QENTI", "ipfs://QmTest");

        vm.stopPrank();
    }

    function testCannotCreateWithEmptySymbol() public {
        vm.startPrank(creator);

        vm.expectRevert("Symbol cannot be empty");
        factory.createMemeToken{value: CREATION_FEE}(
            "Qenti Coin",
            "",
            "ipfs://QmTest"
        );

        vm.stopPrank();
    }

    function testGetCreatorTokens() public {
        vm.startPrank(creator);

        // Create 3 tokens
        factory.createMemeToken{value: CREATION_FEE}("Token1", "TK1", "ipfs://1");
        factory.createMemeToken{value: CREATION_FEE}("Token2", "TK2", "ipfs://2");
        factory.createMemeToken{value: CREATION_FEE}("Token3", "TK3", "ipfs://3");

        // Get creator tokens
        address[] memory tokens = factory.getCreatorTokens(creator);
        assertEq(tokens.length, 3);

        vm.stopPrank();
    }

    function testTotalTokens() public {
        assertEq(factory.totalTokens(), 0);

        vm.prank(creator);
        factory.createMemeToken{value: CREATION_FEE}("Token1", "TK1", "ipfs://1");

        assertEq(factory.totalTokens(), 1);
    }

    function testWithdrawFees() public {
        // Create token (sends fee to factory)
        vm.prank(creator);
        factory.createMemeToken{value: CREATION_FEE}("Token1", "TK1", "ipfs://1");

        uint256 ownerBalanceBefore = owner.balance;

        // Withdraw fees
        factory.withdrawFees();

        uint256 ownerBalanceAfter = owner.balance;
        assertEq(ownerBalanceAfter - ownerBalanceBefore, CREATION_FEE);
    }

    function testOnlyOwnerCanWithdrawFees() public {
        vm.prank(user);
        vm.expectRevert();
        factory.withdrawFees();
    }

    function testSetCreationFee() public {
        uint256 newFee = 0.02 ether;
        factory.setCreationFee(newFee);
        assertEq(factory.creationFee(), newFee);
    }

    function testOnlyOwnerCanSetCreationFee() public {
        vm.prank(user);
        vm.expectRevert();
        factory.setCreationFee(0.02 ether);
    }

    // Fuzz test: Create tokens with random names
    function testFuzz_CreateMemeToken(
        string memory name,
        string memory symbol
    ) public {
        vm.assume(bytes(name).length > 0 && bytes(name).length < 100);
        vm.assume(bytes(symbol).length > 0 && bytes(symbol).length < 20);

        vm.prank(creator);
        (address token, address bondingCurve) = factory.createMemeToken{
            value: CREATION_FEE
        }(name, symbol, "ipfs://test");

        assertTrue(token != address(0));
        assertTrue(bondingCurve != address(0));
    }

    receive() external payable {}
}
