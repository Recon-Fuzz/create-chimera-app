// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract TargetFunctions is
    BaseTargetFunctions,
    Properties,
    BeforeAfter
{
    function counter_increment() public {
        counter.increment();
    }

    function counter_setNumber(uint256 newNumber) public {
        // example assertion test replicating testFuzz_SetNumber
        try counter.setNumber(newNumber) {
            if (newNumber != 0) {
                t(counter.number() == newNumber, "number != newNumber");
            }
        } catch {
            t(false, "setNumber reverts");
        }
    }
}
