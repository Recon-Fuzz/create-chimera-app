// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";
import "forge-std/console2.sol";

contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        bool fork = true; // use this to toggle between local and forked setup

        setup(fork);

        if(fork) {
            // add your rpc url to the .env file to run tests using a forked chain state
            string memory forkRpc = vm.envString("MAINNET_RPC_URL");

            // create a fork from the given rpc url at the block number set in Setup contract
            vm.createSelectFork(forkRpc, BLOCK_NUMBER);
        }
        
    }

    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }
}
