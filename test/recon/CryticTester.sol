// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {TargetFunctions} from "./TargetFunctions.sol";
import {CryticAsserts} from "@chimera/CryticAsserts.sol";
import {vm} from "@chimera/Hevm.sol";

// echidna . --contract CryticTester --config echidna.yaml
// medusa fuzz
contract CryticTester is TargetFunctions, CryticAsserts {
    constructor() payable {
        bool fork = false; // use this to toggle using a forked or local setup

        setup(fork);
        
        if (fork) {
            // forked setups for Echidna and Medusa require warping/rolling to the desired block number because they start calls from block = 1, block.timestamp = 1
            vm.warp(BLOCK_TIMESTAMP); 
            vm.roll(BLOCK_NUMBER);
        }
    }
}
