// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HalmosAsserts} from "@chimera/HalmosAsserts.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {Setup} from "./Setup.sol";
import {Counter} from "../../src/Counter.sol";
import {Test} from "forge-std/Test.sol";

contract HalmosTester is HalmosAsserts {
    Counter counter;

    function setUp() public {
        // setup();

        counter = new Counter();
    }

    function check_Increment(uint256 newNumber) public {
        counter.setNumber(newNumber);

        if (newNumber != 0) {
            eq(counter.number(), newNumber, "number != newNumber"); // throws cheatcode error
            // assert(counter.number() == newNumber);
        }
    }
}
