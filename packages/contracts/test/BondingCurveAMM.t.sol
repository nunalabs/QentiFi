// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BondingCurveAMM.sol";
import "../src/MemeToken.sol";

contract BondingCurveAMMTest is Test {
    BondingCurveAMM public curve;
    MemeToken public token;

    address public factory;
    address public buyer;
    address public seller;

    function setUp() public {
        factory = address(this);
        buyer = makeAddr("buyer");
        seller = makeAddr("seller");

        // Deploy token
        token = new MemeToken("Test Token", "TEST", "ipfs://test", factory);

        // Deploy bonding curve
        curve = new BondingCurveAMM(address(token), factory);

        // Set bonding curve in token
        token.setBondingCurve(address(curve));

        // Fund test accounts
        vm.deal(buyer, 100 ether);
        vm.deal(seller, 100 ether);
    }

    function testBuyTokens() public {
        vm.startPrank(buyer);

        uint256 andeAmount = 1 ether;
        uint256 expectedTokens = curve.calculatePurchaseReturn(andeAmount);

        uint256 tokensBought = curve.buyTokens{value: andeAmount}(expectedTokens - 1000);

        assertTrue(tokensBought > 0, "Should receive tokens");
        assertEq(token.balanceOf(buyer), tokensBought, "Buyer should have tokens");
        assertEq(curve.totalVolume(), andeAmount, "Volume should be recorded");

        vm.stopPrank();
    }

    function testSellTokens() public {
        // First buy some tokens
        vm.startPrank(buyer);
        uint256 tokensBought = curve.buyTokens{value: 1 ether}(0);
        vm.stopPrank();

        // Now sell half
        vm.startPrank(buyer);
        uint256 tokensToSell = tokensBought / 2;
        token.approve(address(curve), tokensToSell);

        uint256 andeReceived = curve.sellTokens(tokensToSell, 0);
        assertTrue(andeReceived > 0, "Should receive ANDE");

        vm.stopPrank();
    }

    function testPriceIncreasesWithSupply() public {
        uint256 price1 = curve.getCurrentPrice();

        vm.prank(buyer);
        curve.buyTokens{value: 1 ether}(0);

        uint256 price2 = curve.getCurrentPrice();
        assertTrue(price2 > price1, "Price should increase after purchase");
    }

    function testCannotBuyWithZeroANDE() public {
        vm.prank(buyer);
        vm.expectRevert("Must send ANDE");
        curve.buyTokens{value: 0}(0);
    }

    function testCannotSellZeroTokens() public {
        vm.prank(seller);
        vm.expectRevert("Must sell tokens");
        curve.sellTokens(0, 0);
    }

    function testSlippageProtectionBuy() public {
        vm.startPrank(buyer);

        uint256 expectedTokens = curve.calculatePurchaseReturn(1 ether);

        vm.expectRevert("Slippage too high");
        curve.buyTokens{value: 1 ether}(expectedTokens * 2); // Unrealistic expectation

        vm.stopPrank();
    }

    function testGetQuoteBuy() public {
        uint256 andeAmount = 1 ether;
        (uint256 tokens, uint256 price) = curve.getQuoteBuy(andeAmount);

        assertTrue(tokens > 0, "Quote should return tokens");
        assertTrue(price > 0, "Quote should return price");
    }

    function testGetQuoteSell() public {
        // First buy tokens
        vm.prank(buyer);
        uint256 tokensBought = curve.buyTokens{value: 1 ether}(0);

        (uint256 ande, uint256 price) = curve.getQuoteSell(tokensBought);

        assertTrue(ande > 0, "Quote should return ANDE");
        assertTrue(price > 0, "Quote should return price");
    }

    // Fuzz test: Buy with random ANDE amounts
    function testFuzz_BuyTokens(uint256 andeAmount) public {
        vm.assume(andeAmount > 0.001 ether && andeAmount < 10 ether);

        vm.deal(buyer, andeAmount + 1 ether);
        vm.prank(buyer);
        uint256 tokens = curve.buyTokens{value: andeAmount}(0);

        assertTrue(tokens > 0, "Should receive tokens");
    }

    // Invariant: Total supply should never exceed MAX_SUPPLY
    function invariant_MaxSupply() public {
        assertTrue(
            curve.currentSupply() <= curve.MAX_SUPPLY(),
            "Supply should not exceed max"
        );
    }

    receive() external payable {}
}
