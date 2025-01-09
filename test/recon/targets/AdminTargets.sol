// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract AdminTargets is
    BaseTargetFunctions,
    Properties
{

    // usage
    // replace  public {
    // with public updateGhosts asAdmin {
    // Must put `updateGhosts` before else you may consume the prank with updateGhosts
    function counter_increment_asAdmin() public updateGhosts asAdmin {
        counter.increment();
    }

}