// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Targets
// NOTE: Always import and apply them in alphabetical order, so much easier to debug!
import {AdminTargets} from "./targets/AdminTargets.sol";
import {ManagersTargets} from "./targets/ManagersTargets.sol";

abstract contract TargetFunctions is
    AdminTargets,
    ManagersTargets
{
    function counter_increment() public updateGhosts asActor {
        counter.increment();
    }

    function counter_setNumber1(uint256 newNumber) public updateGhosts asActor {
        // example assertion test replicating testFuzz_SetNumber
        try counter.setNumber(newNumber) {
            if (newNumber != 0) {
                t(counter.number() == newNumber, "number != newNumber");
            }
        } catch {
            t(false, "setNumber reverts");
        }
    }

    function counter_setNumber2(uint256 newNumber) public updateGhosts asActor {
        // same example assertion test as counter_setNumber1 using ghost variables
        __before();

        counter.setNumber(newNumber);

        __after();

        if (newNumber != 0) {
            t(_after.counter_number == newNumber, "number != newNumber");
        }
    }
}
