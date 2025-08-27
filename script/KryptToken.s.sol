// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {KryptToken} from "../src/KryptToken.sol";

contract KryptTokenScript is Script {
    KryptToken public krypt;

    function setUp() public {}

    function run() public {
        address tokenAdmin = vm.envAddress("TOKEN_ADMIN");

        vm.startBroadcast();

        krypt = new KryptToken(tokenAdmin);

        vm.stopBroadcast();
    }
}
