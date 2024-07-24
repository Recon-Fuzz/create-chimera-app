// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {TargetFunctions} from "./TargetFunctions.sol";
import {HalmosTargetFunctions} from "./HalmosTargetFunctions.sol";
import {CryticAsserts} from "@chimera/CryticAsserts.sol";

// Test with Echidna: echidna . --contract CryticTester --config echidna.yaml
// Test with Medusa: medusa fuzz
// Test with Halmos: halmos --contract CryticTester
contract CryticTester is TargetFunctions, HalmosTargetFunctions, CryticAsserts {
    constructor() payable {
        setup();
    }
}
