// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {Setup} from "./Setup.sol";

abstract contract Properties is Setup, Asserts {
    // example property test that gets run after each call in sequence
    function invariant_number_never_zero() public returns (bool) {
        return counter.number() != 0;
    }
}
