// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/QentiToken.sol";

contract QentiTokenTest is Test {
    QentiToken public token;

    address public communityRewards;
    address public daoTreasury;
    address public liquidityMining;
    address public teamAndAdvisors;
    address public publicSale;

    address public user1 = address(100);
    address public user2 = address(101);

    event VestingClaimed(address indexed beneficiary, uint256 amount);

    function setUp() public {
        communityRewards = address(1);
        daoTreasury = address(2);
        liquidityMining = address(3);
        teamAndAdvisors = address(4);
        publicSale = address(5);

        token = new QentiToken(
            communityRewards,
            daoTreasury,
            liquidityMining,
            teamAndAdvisors,
            publicSale
        );
    }

    function testInitialSupply() public {
        uint256 maxSupply = 1_000_000_000 * 10**18;
        assertEq(token.MAX_SUPPLY(), maxSupply, "Max supply should be 1B");

        // Check initial distributions
        assertEq(
            token.balanceOf(communityRewards),
            300_000_000 * 10**18,
            "Community rewards should have 30%"
        );
        assertEq(
            token.balanceOf(daoTreasury),
            250_000_000 * 10**18,
            "DAO treasury should have 25%"
        );
        assertEq(
            token.balanceOf(liquidityMining),
            150_000_000 * 10**18,
            "Liquidity mining should have 15%"
        );
        assertEq(
            token.balanceOf(publicSale),
            100_000_000 * 10**18,
            "Public sale should have 10%"
        );
    }

    function testVestingSchedule() public {
        // Team vesting: 200M tokens over 4 years with 1 year cliff
        (uint256 total, uint256 claimed, uint256 start, uint256 cliff, uint256 duration) =
            token.vestingSchedules(teamAndAdvisors);

        assertEq(total, 200_000_000 * 10**18, "Team should have 200M vested");
        assertEq(claimed, 0, "No tokens claimed initially");
        assertEq(cliff, 365 days, "Should have 1 year cliff");
        assertEq(duration, 4 * 365 days, "Should vest over 4 years");
    }

    function testCannotClaimBeforeCliff() public {
        vm.startPrank(teamAndAdvisors);

        // Try to claim before cliff
        vm.expectRevert("Cliff not reached");
        token.claimVested();

        // Warp to just before cliff
        vm.warp(block.timestamp + 364 days);

        vm.expectRevert("Cliff not reached");
        token.claimVested();

        vm.stopPrank();
    }

    function testClaimAfterCliff() public {
        vm.startPrank(teamAndAdvisors);

        // Warp past cliff (1 year + 1 day)
        vm.warp(block.timestamp + 366 days);

        uint256 claimable = token.getVestedAmount(teamAndAdvisors);
        assertGt(claimable, 0, "Should have claimable tokens after cliff");

        uint256 balanceBefore = token.balanceOf(teamAndAdvisors);

        vm.expectEmit(true, false, false, true);
        emit VestingClaimed(teamAndAdvisors, claimable);

        token.claimVested();

        assertEq(
            token.balanceOf(teamAndAdvisors),
            balanceBefore + claimable,
            "Balance should increase by claimable amount"
        );

        vm.stopPrank();
    }

    function testFullyVestedAfter4Years() public {
        vm.startPrank(teamAndAdvisors);

        // Warp to end of vesting period
        vm.warp(block.timestamp + 4 * 365 days);

        uint256 claimable = token.getVestedAmount(teamAndAdvisors);
        assertEq(claimable, 200_000_000 * 10**18, "Should be fully vested");

        token.claimVested();

        assertEq(
            token.balanceOf(teamAndAdvisors),
            200_000_000 * 10**18,
            "Should receive all vested tokens"
        );

        // Try to claim again
        vm.expectRevert("No vested tokens available");
        token.claimVested();

        vm.stopPrank();
    }

    function testLinearVesting() public {
        vm.startPrank(teamAndAdvisors);

        // After 1 year (cliff), should have ~25% vested
        vm.warp(block.timestamp + 365 days);
        uint256 claimable1Year = token.getVestedAmount(teamAndAdvisors);

        // After 2 years, should have ~50% vested
        vm.warp(block.timestamp + 2 * 365 days);
        uint256 claimable2Years = token.getVestedAmount(teamAndAdvisors);

        // After 3 years, should have ~75% vested
        vm.warp(block.timestamp + 3 * 365 days);
        uint256 claimable3Years = token.getVestedAmount(teamAndAdvisors);

        uint256 totalVested = 200_000_000 * 10**18;

        // Check linear progression (with some tolerance for rounding)
        assertApproxEqRel(claimable1Year, totalVested / 4, 0.01e18, "~25% after 1 year");
        assertApproxEqRel(claimable2Years, totalVested / 2, 0.01e18, "~50% after 2 years");
        assertApproxEqRel(claimable3Years, (totalVested * 3) / 4, 0.01e18, "~75% after 3 years");

        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(communityRewards);

        uint256 burnAmount = 1000 * 10**18;
        uint256 balanceBefore = token.balanceOf(communityRewards);
        uint256 totalSupplyBefore = token.totalSupply();

        token.burn(burnAmount);

        assertEq(
            token.balanceOf(communityRewards),
            balanceBefore - burnAmount,
            "Balance should decrease"
        );
        assertEq(
            token.totalSupply(),
            totalSupplyBefore - burnAmount,
            "Total supply should decrease"
        );

        vm.stopPrank();
    }

    function testDelegation() public {
        vm.startPrank(communityRewards);

        // Delegate to user1
        token.delegate(user1);

        assertEq(
            token.getVotes(user1),
            token.balanceOf(communityRewards),
            "User1 should have delegated votes"
        );

        vm.stopPrank();
    }

    function testTransferUpdatesDelegation() public {
        vm.startPrank(communityRewards);

        // Delegate to user1
        token.delegate(user1);
        uint256 votesBefore = token.getVotes(user1);

        // Transfer some tokens to user2
        uint256 transferAmount = 1000 * 10**18;
        token.transfer(user2, transferAmount);

        // Votes should decrease
        assertEq(
            token.getVotes(user1),
            votesBefore - transferAmount,
            "Votes should decrease after transfer"
        );

        vm.stopPrank();
    }

    function testPastVotes() public {
        vm.startPrank(communityRewards);

        token.delegate(user1);

        // Mine a block
        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 12);

        uint256 currentVotes = token.getVotes(user1);
        uint256 pastVotes = token.getPastVotes(user1, block.number - 1);

        assertEq(currentVotes, pastVotes, "Past votes should match current");

        vm.stopPrank();
    }

    function testCannotExceedMaxSupply() public {
        // This shouldn't be possible with current setup since we mint exact amounts
        // But test the constraint
        uint256 totalMinted = token.totalSupply();
        assertLe(totalMinted, token.MAX_SUPPLY(), "Cannot exceed max supply");
    }

    function testFuzzTransfer(uint256 amount) public {
        vm.startPrank(communityRewards);

        uint256 balance = token.balanceOf(communityRewards);
        amount = bound(amount, 0, balance);

        if (amount > 0) {
            token.transfer(user1, amount);
            assertEq(token.balanceOf(user1), amount, "User1 should receive tokens");
        }

        vm.stopPrank();
    }

    function testFuzzBurn(uint256 amount) public {
        vm.startPrank(communityRewards);

        uint256 balance = token.balanceOf(communityRewards);
        amount = bound(amount, 0, balance);

        uint256 totalSupplyBefore = token.totalSupply();

        if (amount > 0) {
            token.burn(amount);
            assertEq(
                token.totalSupply(),
                totalSupplyBefore - amount,
                "Total supply should decrease"
            );
        }

        vm.stopPrank();
    }
}
