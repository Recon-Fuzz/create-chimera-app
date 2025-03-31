// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

// Targets
// NOTE: Always import and apply them in alphabetical order, so much easier to debug!
import {AdminTargets} from "./targets/AdminTargets.sol";
import {DoomsdayTargets} from "./targets/DoomsdayTargets.sol";
import {ManagersTargets} from "./targets/ManagersTargets.sol";

abstract contract TargetFunctions is
    AdminTargets,
    DoomsdayTargets,
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
        } catch (bytes memory err) {
            bool expectedError;
            // checks for custom errors and panics
            expectedError = 
                checkError(err, "abc") || // error string from require statement
                checkError(err, "CustomError()") || // custom error
                checkError(err, Panic.arithmeticPanic); // compiler panic errors
            t(expectedError, "unexpected error");
        }
    }

    function counter_setNumber2(uint256 newNumber) public asActor {
        // same example assertion test as counter_setNumber1 using ghost variables
        __before();

        counter.setNumber(newNumber);

        __after();

        if (newNumber != 0) {
            t(_after.counter_number == newNumber, "number != newNumber");
        }
    }
}
