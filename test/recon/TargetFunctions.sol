// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {vm} from "@chimera/Hevm.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";

import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";

abstract contract TargetFunctions is
    BaseTargetFunctions,
    Properties,
    BeforeAfter,
    SymTest
{
    /**
        Echidna/Medusa Target Functions 
    */
    function counter_increment() public {
        counter.increment();
    }

    ///@notice example assertion test replicating testFuzz_SetNumber
    function counter_setNumber1(uint256 newNumber) public {
        try counter.setNumber(newNumber) {
            if (newNumber != 0) {
                eq(counter.number(), newNumber, "number != newNumber");
            }
        } catch {
            t(false, "setNumber reverts");
        }
    }

    ///@notice same example assertion test as counter_setNumber1 using ghost variables
    function counter_setNumber2(uint256 newNumber) public {
        __before();

        counter.setNumber(newNumber);

        __after();

        if (newNumber != 0) {
            t(_after.counter_number == newNumber, "number != newNumber");
        }
    }
}
