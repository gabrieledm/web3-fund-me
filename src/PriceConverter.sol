// SPDX-License-Identifier: MIT

// Use all Solidity versions from 0.8.24 ahead
pragma solidity ^0.8.24;

/**
 * @notice An interface gives us the functions used to interact with a SmartContract without knowing the actual implementation
 */
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @dev A Library
 * - can't have any state variables
 * - all the functions have to be marked __internal__
 *     - is embedded into the contract
 *     - otherwise must be deployed and then linked before the contract is deployed
 */
library PriceConverter {
    /**
     * Use the AggregatorV3Interface to get, from an Oracle contract, the ETH price in terms of USD
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        // price is ETH in terms of USD (Es. 2000.0000000)
        // The conversion is needed because in Solidity there are no decimal places so we need to work with whole numbers to maintain decimal precision
        return uint256(price * 1e10);
    }

    /**
     * @dev Converts the msg.value (ETH) in terms of USD by using the __getPrice()__ function
     *      The first parameter will be the type to which the Library is attached to.
     *      All other parameters must be passed normally to the function
     */
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPriceInUSD = getPrice(priceFeed);
        // Both ethPriceInUSD and ethAmount have 18 decimal places so to work with whole numbers we have to divide the result by 1e18
        uint256 ethAmountInUSD = (ethPriceInUSD * ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}
