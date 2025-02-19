// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Panic} from "./Panic.sol";

contract Utils {

    /// @dev check if the error returned from a call is the same as the expected error
    /// @param err the error returned from a call
    /// @param expected the expected error
    /// @return true if the error is the same as the expected error, false otherwise
    function checkError(bytes memory err, string memory expected) internal pure returns(bool) {
        (string memory revertMsg, bool customError) = _getRevertMsg(err);
        
        bytes32 errorBytes;
        bytes32 expectedBytes;

        if(customError) {
            // Custom error returns the keccak256 hash of the error, so don't need to hash it again
            errorBytes = bytes32(abi.encodePacked(revertMsg, bytes28(0)));
            expectedBytes = bytes4(keccak256(abi.encodePacked(expected)));
        } else {
            errorBytes = keccak256(abi.encodePacked(revertMsg));
            expectedBytes = keccak256(abi.encodePacked(expected));
        }

        // Check if error contains expected string
        return errorBytes == expectedBytes;
    }

    /// @dev get the revert message from a call
    /// @notice based on https://ethereum.stackexchange.com/a/83577
    /// @param returnData the return data from a call
    /// @return the revert message and a boolean indicating if it's a custom error
    function _getRevertMsg(bytes memory returnData) internal pure returns (string memory, bool) {
        // If the returnData length is 0, then the transaction failed silently (without a revert message)
        if (returnData.length == 0) return ("", false);

        // 1. Panic(uint256)
        // Check that the data has the right size: 4 bytes for signature + 32 bytes for panic code
        if (returnData.length == 4 + 32) {
            // Check that the data starts with the Panic signature
            bool panic = _checkIfPanic(returnData);
    
            if (panic) {
                return _getPanicCode(returnData);
            }
        }
        
        // Get the error selector from returnData
        bytes4 errorSelector = _getErrorSelector(returnData);

        // 2. Error(string) - If it's a standard revert string
        bytes4 errorStringSelector = bytes4(keccak256("Error(string)")); // Get the standard Error(string) selector
        
        if (errorSelector == errorStringSelector) {
            assembly {
                // slice the sighash of the error so we can decode the string
                returnData := add(returnData, 0x04)
            }
            return (abi.decode(returnData, (string)), false);
        }

        // 3. Custom error - Return the custom error selector as a string
        return (string(abi.encodePacked(errorSelector)), true);
    }

    function _checkIfPanic(bytes memory returnData) internal pure returns (bool) {
        bytes4 panicSignature = bytes4(keccak256(bytes("Panic(uint256)")));
        
        for (uint256 i = 0; i < 4; i++) {
            if (returnData[i] != panicSignature[i]) {
                return false;
            }
        }

        return true;
    }

    function _getPanicCode(bytes memory returnData) internal pure returns (string memory, bool) {
        uint256 panicCode;
        for (uint256 i = 4; i < 36; i++) {
            panicCode = panicCode << 8;
            panicCode |= uint8(returnData[i]);
        }

        // Convert the panic code into its string representation
        if (panicCode == 1) {
            // call assert with an argument that evaluates to false
            return (Panic.assertionPanic, false);
        } else if (panicCode == 17) {
            // arithmetic operation results in underflow or overflow
            return (Panic.arithmeticPanic, false);
        } else if (panicCode == 18) {
            // division or modulo by zero
            return (Panic.divisionPanic, false);
        } else if (panicCode == 33) {
            // converting a value that's too big or negative into an enum type
            return (Panic.enumPanic, false);
        } else if (panicCode == 34) {
            // access a storage byte array that is incorrectly encoded
            return (Panic.arrayPanic, false);
        } else if (panicCode == 49) {
            // call .pop() on an empty array
            return (Panic.emptyArrayPanic, false);
        } else if (panicCode == 50) {
            // array access out of bounds
            return (Panic.outOfBoundsPanic, false);
        } else if (panicCode == 65) {
            // allocate too much memory or create an array that is too large
            return (Panic.memoryPanic, false);
        } else if (panicCode == 81) {
            // call a zero-initialized variable of internal function type
            return (Panic.functionPanic, false);
        }

        return ("Undefined panic code", false);
    }

    function _getErrorSelector(bytes memory returnData) internal pure returns (bytes4 errorSelector) {
        assembly {
            errorSelector := mload(add(returnData, 0x20))
        }
        return errorSelector;
    }
}