// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console2} from "../lib/forge-std/src/Script.sol";
import {FundAllocation} from "../src/FundAllocation.sol";

contract FundAllocationScript is Script {
    FundAllocation public fundAllocation;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        fundAllocation = new FundAllocation();
        vm.stopBroadcast();
    }
}
