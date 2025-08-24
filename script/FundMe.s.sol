// SPDX-License-Identifier: MIT

// Use all Solidity versions from 0.8.24 ahead
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundMeScript is Script {
    function run() external returns (FundMe) {
        // Run before startBroadcast to run it in a simulated environment(=not spend gas)
        // Before startBroadcast -> Not a real tx
        HelperConfig helperConfig = new HelperConfig();
        // Destructuring the properties of received struct
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // After startBroadcast -> Real tx

        FundMe fundMe = new FundMe(ethUsdPriceFeed);

        vm.stopBroadcast();

        return fundMe;
    }
}
