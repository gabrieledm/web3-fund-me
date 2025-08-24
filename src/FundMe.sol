// SPDX-License-Identifier: MIT

// Use all Solidity versions from 0.8.24 ahead
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

/**
 * @dev Best practice: Naming custom errors by prefixing the error with <contract-name>__
 */
error FundMe__NotOwner();

/**
 * @notice Hybrid SmartContract: A SmartContract that uses external data/computation from a Decentralized Oracle Network (like ChainLink)
 */
contract FundMe {
    // Attach all PriceConverter's library functions to uint256 type
    using PriceConverter for uint256;

    /**
     * @notice Storage variables
     * - Each slot is 32 bytes long and represents the bytes version of the stored object.
     *   - For example the uint256 25 is 0x000...0019 since that's the hex representation
     * - For dynamic values like mappings and dynamic arrays, the elements are stored using a hashing function (keccak256)
     *   - For arrays a sequential storage spot is taken up for the length of the array
     *     - slot[2] = 0x000...0001 -> Array length
     *     - slot[keccak256(<value-in-slot-used-to-store-array-length>)] = 0x000...000de -> Actual array element
     *       - Example: slot[keccak256(0x000...0001)] = 0x000...000de
     *   - For mappings a sequential storage spot is taken up, but left blank
     * - Constants and immutable variables are not in storage but are considered part of the bytecode of the contract
     */
    // ---------- Storage variables ----------

    // This is the USD expressed in terms of ETH
    // 5e18 = (5 * 10) ** 18 = (5 * 10) ^ 18 = 5 USD (expressed in terms of Wei)
    /**
     * @dev Gas optimization: Usage of constant keyword
     */
    uint256 public constant MINIMUM_USD = 5e18;

    /**
     * @dev Track the addresses that fund this contract
     * @dev s_ stand for __storage__
     * @dev Gas optimization: Make storage variables private
     */
    address[] private s_funders;
    /**
     * @dev Track the amount of funds sent by each address
     * @dev s_ stand for __storage__
     * @dev Gas optimization: Make storage variables private
     */
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    /**
     * @dev Gas optimization: Usage of immutable keyword
     */
    address private immutable i_owner;
    AggregatorV3Interface private s_dataFeed;
    // ---------- Storage variables ----------

    constructor(address priceFeed) {
        s_dataFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, new NotOwner());
        /**
         * @dev Gas optimization: Usage of custom errors
         */
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        // Continue the execution of the function in which the modifier is used
        _;
    }

    function getVersion() public view returns (uint256) {
        return s_dataFeed.version();
    }

    /**
     * @dev payable: Allows this function to receive Ether together with a call.
     */
    function fund() public payable {
        // msg.value: get the current Wei sent with the function invocation
        // 1e18 = 1 ETH = 1000000000000000000 Wei = 1 * 10 ** 18
        // If the received ETH, converted in USD, are less than minUSD then reverts the transaction
        require(msg.value.getConversionRate(s_dataFeed) >= MINIMUM_USD, "Didn't send enough ETH");

        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        address[] memory funders = s_funders;
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            s_addressToAmountFunded[funder] = 0;
        }

        // Reset the array of funders
        s_funders = new address[](0);

        // Withdraw the funds
        // Three different ways:
        // - transfer (2300 gas, throws error)
        //        payable(msg.sender).transfer(address(this).balance);

        // - send (2300 gas, returns bool)
        //        bool success = payable(msg.sender).send(address(this).balance);
        //        require(success, "Send failed");

        // - call (forward all gas or set gas, returns bool)
        // Recommended way
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Call failed");
    }

    /**
     * @dev By implementing both receive and fallback we are sure that we can control
     *      all the ways in which this contract can receive Ether
     */
    // Ether is sent to contract and msg.data is empty
    receive() external payable {
        fund();
    }

    // Ether is sent to contract and msg.data is NOT empty
    fallback() external payable {
        fund();
    }

    //---------- View/Pure functions (Getters) ----------
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
    //---------- View/Pure functions (Getters) ----------
}
