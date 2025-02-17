// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract ActorManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    address private _actor;

    EnumerableSet.AddressSet private _actors;

    // If the current target is address(0) then it has not been setup yet and should revert
    error ActorNotSetup();
    // Do not allow duplicates
    error ActorExists();
    // If the actor does not exist
    error ActorNotAdded();
    // Do not allow the default actor
    error DefaultActor();

    constructor() {
        // address(this) is the default actor
        _actors.add(address(this));
        _actor = address(this);
    }

    // use this function to get the current active actor
    function _getActor() internal view returns (address) {
       return _actor;
    }

    // Get regular users
    function _getActors() internal view returns (address[] memory) {
        return _actors.values();
    }

    function _addActor(address target) internal {
        if (_actors.contains(target)) {
            revert ActorExists();
        }

        if (target == address(this)) {
            revert DefaultActor();
        }

        _actors.add(target);
    }

    function _removeActor(address target) internal {
        if (!_actors.contains(target)) {
            revert ActorNotAdded();
        }

        if (target == address(this)) {
            revert DefaultActor();
        }

        _actors.remove(target);
    }

    // Note: expose this function _in `TargetFunctions` for actor switching
    function _switchActor(uint256 entropy) internal {
        address target = _actors.at(entropy % _actors.length());
        _actor = target;
    }
}
