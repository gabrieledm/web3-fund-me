// SPDX-License-Identifier: MIT

// Use all Solidity versions from 0.8.24 ahead
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundMeScript} from "../../script/FundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

/**
 * @dev Best practice
 *         For writing test should be followed these steps
 *             - Arrange:  Setup for the specific test
 *             - Act:      Execute the test
 *             - Assert:   Assert the results of the tests
 */
contract FundMeIntegrationTest is Test {
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

    function testUserCanFundAndWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
