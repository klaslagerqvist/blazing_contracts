// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Disperse} from "../src/Disperse.sol";


contract DisperseCollectScript is Script {
    Disperse public disperseCollect;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        disperseCollect = new Disperse();

        vm.stopBroadcast();
    }
}
