// SPDX-License-Identifier: MIT

// Use all Solidity versions from 0.8.24 ahead
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";

/**
 * @dev Best practice
 *         For writing test should be followed these steps
 *             - Arrange:  Setup for the specific test
 *             - Act:      Execute the test
 *             - Assert:   Assert the results of the tests
 */
contract FundMeUnitTest is Test {
    address private owner;
    FundMe private fundMe;

    // Creates a labeled address
    address private USER = makeAddr("user");
    uint256 private constant SEND_VALUE = 0.1 ether;
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 private constant GAS_PRICE = 1;

    // Setup for tests (Es. deploy contract to be tested)
    function setUp() external {
        owner = msg.sender;
        // Set the balance of USER to STARTING_BALANCE
        vm.deal(USER, STARTING_BALANCE);
        // Run the deploy script for FundMe contract
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
    }

    /**
     * @dev Best practice: Use modifiers for common repeated actions
     */
    modifier funded() {
        // The next tx will be sent by USER
        vm.prank(USER);
        // Sending 10 ETH
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testMinimumUSDIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), owner);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        // We expecting the next line should revert
        vm.expectRevert();
        // Sending 0 value
        fundMe.fund();
    }

    function testFundUpdatesFundersDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        /**
         * @dev Enforce usage of gas because by default the Anvil chain used for test has gasPrice=0
         */
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // Sets up a prank from an address that has some ether
            // https://book.getfoundry.sh/reference/forge-std/hoax
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
}
