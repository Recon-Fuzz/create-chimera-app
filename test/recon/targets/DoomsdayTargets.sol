// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
import {vm} from "@chimera/Hevm.sol";

abstract contract DoomsdayTargets is
    BaseTargetFunctions,
    Properties
{

    /// Makes a handler have no side effects
    /// The fuzzer will call this anyway, and because it reverts it will be removed from shrinking
    /// Replace the "withGhosts" with "stateless" to make the code clean
    modifier stateless() {
        _;
        revert("stateless");
    }

    function doomsday_increment_never_reverts() public stateless asAdmin {
        try counter.increment() {

        } catch {
            t(false, "doomsday_increment_never_reverts");
        }
    }

}