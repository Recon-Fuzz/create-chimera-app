// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HalmosAsserts} from "@chimera/HalmosAsserts.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {Setup} from "./Setup.sol";
import {Counter} from "../../src/Counter.sol";
import {Test} from "forge-std/Test.sol";

contract HalmosTester is TargetFunctions, HalmosAsserts {
    function setUp() public {
        setup();
    }
}
