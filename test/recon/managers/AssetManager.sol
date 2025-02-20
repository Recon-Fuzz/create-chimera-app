// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

import {EnumerableSet} from "./utils/EnumerableSet.sol";
import {MockERC20} from "../mocks/MockERC20.sol";

/// @dev Source of truth for the assets being used in the test
/// @notice No assets should be used in the suite without being added here first
abstract contract AssetManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @notice The current target for this set of variables
    address private __asset;

    /// @notice The list of all assets being used
    EnumerableSet.AddressSet private _assets;

    // If the current target is address(0) then it has not been setup yet and should revert
    error NotSetup();
    // Do not allow duplicates
    error Exists();
    // Enable only added assets
    error NotAdded();

    /// @notice Returns the current active asset
    function _getAsset() internal view returns (address) {
        if (__asset == address(0)) {
            revert NotSetup();
        }

        return __asset;
    }

    /// @notice Returns all assets being used
    function _getAssets() internal view returns (address[] memory) {
        return _assets.values();
    }

    /// @notice Creates a new asset and adds it to the list of assets
    /// @param decimals The number of decimals for the asset
    /// @return The address of the new asset
    function _newAsset(uint8 decimals) internal returns (address) {
        address asset_ =  address(new MockERC20("Test Token", "TST", decimals)); // If names get confusing, concatenate the decimals to the name
        _addAsset(asset_);
        __asset = asset_; // sets the asset as the current asset
        return asset_;
    }

    /// @notice Adds an asset to the list of assets
    /// @param target The address of the asset to add
    function _addAsset(address target) internal {
        if (_assets.contains(target)) {
            revert Exists();
        }

        _assets.add(target);
    }

    /// @notice Removes an asset from the list of assets
    /// @param target The address of the asset to remove
    function _removeAsset(address target) internal {
        if (!_assets.contains(target)) {
            revert NotAdded();
        }

        _assets.remove(target);
    }

    /// @notice Switches the current asset based on the entropy
    /// @param entropy The entropy to choose a random asset in the array for switching
    function _switchAsset(uint256 entropy) internal {
        address target = _assets.at(entropy % _assets.length());
        __asset = target;
    }

    /// === Approve & Mint Asset === ///

    /// @notice Mint initial balance and approve allowances for the active asset
    /// @param actorsArray The array of actors to mint the asset to
    /// @param approvalArray The array of addresses to approve the asset to
    /// @param amount The amount of the asset to mint
    function _finalizeAssetDeployment(address[] memory actorsArray, address[] memory approvalArray, uint256 amount) internal {
        _mintAssetToAllActors(actorsArray, amount);
        for(uint256 i; i < approvalArray.length; i++) {
            _approveAssetToAddressForAllActors(actorsArray, approvalArray[i]);
        }
    }

    /// @notice Mint the asset to all actors
    /// @param actorsArray The array of actors to mint the asset to
    /// @param amount The amount of the asset to mint
    function _mintAssetToAllActors(address[] memory actorsArray, uint256 amount) private {
        // mint all actors
        address asset = _getAsset();
        for (uint256 i; i < actorsArray.length; i++) {
            vm.prank(actorsArray[i]);
            MockERC20(asset).mint(actorsArray[i], amount);
        }
    }

    /// @notice Approve the asset to all actors
    /// @param actorsArray The array of actors to approve the asset from
    /// @param addressToApprove The address to approve the asset to
    function _approveAssetToAddressForAllActors(address[] memory actorsArray, address addressToApprove) private {
        // approve to all actors
        address asset = _getAsset();
        for (uint256 i; i < actorsArray.length; i++) {
            vm.prank(actorsArray[i]);
            MockERC20(asset).approve(addressToApprove, type(uint256).max);
        }
    }
}
