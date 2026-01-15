// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TestrToken} from "../src/TestrToken.sol";

contract TestrTokenScript is Script {
    TestrToken public testr;

    function setUp() public {}

    function run() public {
        address tokenAdmin = vm.envAddress("TOKEN_ADMIN");

        vm.startBroadcast();

        testr = new TestrToken(tokenAdmin);

        vm.stopBroadcast();
    }
}
