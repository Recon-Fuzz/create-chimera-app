// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "./managers/ActorManager.sol";
import {AssetManager} from "./managers/AssetManager.sol";

// Helpers
import {Utils} from "./helpers/Utils.sol";

// Your deps
import "src/Counter.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    Counter counter;

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        // New Actor, beside address(this)
        _addActor(address(0x411c3));
        _newAsset(18); // New 18 decimals token

        counter = new Counter();

        // TODO: Standardize Mint and allowances to all actors
    }


    /// === Actor Modifiers === ///

    // NOTE: LIMITATION You can use these modifier only for one call, so use them for BASIC TARGETS
    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(_getActor());
        _;
    }
}
