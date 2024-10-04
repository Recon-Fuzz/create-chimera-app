// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import "src/Counter.sol";

abstract contract Setup {
    Counter counter;

    uint256 BLOCK_NUMBER;
    uint256 BLOCK_TIMESTAMP;

    function setup(bool fork) internal virtual {
        if (fork) {
            _setupFork();
            BLOCK_NUMBER = 20894001; // TODO: replace with the block number you want to fork from 
            BLOCK_TIMESTAMP = 1; // TODO: replace with the block timestamp you want to fork from 
        } else {
            counter = new Counter();
        }
    }

    function _setupFork() internal virtual {
        // TODO: add in address of deployed contract on fork
        counter = Counter(address(0x123)); 
    }
}
