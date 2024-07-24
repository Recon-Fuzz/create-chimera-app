// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {vm} from "@chimera/Hevm.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";

import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";

abstract contract HalmosTargetFunctions is
    BaseTargetFunctions,
    Properties,
    BeforeAfter,
    SymTest
{
    ///@notice checks an individual target function
    function invariant_increment(uint256 newNumber) public {
        assumeSuccessfulCall(
            address(counter),
            calldataFor(counter.setNumber.selector, newNumber)
        );

        // if (newNumber != 0) {
        eq(counter.number(), newNumber, "number != newNumber");
        // }
    }

    ///@notice stateful symbolic execution test
    ///@dev executes calls to multiple functions in the target contract then makes an assertion
    function invariant_counter_symbolic(
        bytes4[] memory selectors,
        uint256 newNumber
    ) public {
        for (uint256 i = 0; i < selectors.length; ++i) {
            assumeValidSelector(selectors[i]);
            assumeSuccessfulCall(
                address(counter),
                calldataFor(selectors[i], newNumber)
            );
        }

        t(counter.number() != 0, "number == 0");
    }

    ///@notice utility for returning the target functions selectors from the Counter contract
    function assumeValidSelector(bytes4 selector) internal {
        vm.assume(
            selector == counter.setNumber.selector ||
                selector == counter.increment.selector
        );
    }

    ///@notice utility for making calls to the target contract
    function assumeSuccessfulCall(address target, bytes memory data) internal {
        (bool success, ) = target.call(data);
        vm.assume(success);
    }

    ///@notice utility for getting calldata for a given function's arguments
    function calldataFor(
        bytes4 selector,
        uint256 newValue
    ) internal view returns (bytes memory) {
        if (selector == counter.setNumber.selector) {
            return abi.encodeWithSelector(selector, newValue);
        } else if (selector == counter.increment.selector) {
            return abi.encodeWithSelector(selector);
        }
    }
}
