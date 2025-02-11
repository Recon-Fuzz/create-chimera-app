// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

contract Utils {
    function expectedError(bytes memory err, string memory expected) internal pure returns(bool) {
        bytes32 errorBytes = keccak256(abi.encodePacked(_getRevertMsg(err)));
        bytes32 expectedBytes = keccak256(abi.encodePacked(expected));

        // Check if error contains expected string
        if (errorBytes == expectedBytes) {
            return true;
        }

        return false;
    }

    // are custom errors and revert strings handled the same way?
    // this determines if we need to add extra handling for custom errors

    // https://ethereum.stackexchange.com/a/83577
    // TODO: add handling for other panic codes
    function _getRevertMsg(bytes memory returnData) internal pure returns (string memory) {

        // Check that the data has the right size: 4 bytes for signature + 32 bytes for panic code
        if (returnData.length == 4 + 32) {
            // Check that the data starts with the Panic signature
            bytes4 panicSignature = bytes4(keccak256(bytes("Panic(uint256)")));
            for (uint256 i = 0; i < 4; i++) {
                if (returnData[i] != panicSignature[i]) return "Undefined signature";
            }

            uint256 panicCode;
            for (uint256 i = 4; i < 36; i++) {
                panicCode = panicCode << 8;
                panicCode |= uint8(returnData[i]);
            }

            // Now convert the panic code into its string representation
            if (panicCode == 0) {
                // generic compiler inserted panics
                return "Panic(0)";
            } else if (panicCode == 1) {
                // call assert with an argument that evaluates to false
                return "Panic(1)";
            } else if (panicCode == 17) {
                // arithmetic operation results in underflow or overflow
                return "Panic(17)";
            } else if (panicCode == 18) {
                // division or modulo by zero
                return "Panic(18)";
            } else if (panicCode == 33) {
                // converting a value that's too big or negative into an enum type
                return "Panic(33)";
            } else if (panicCode == 34) {
                // access a storage byte array that is incorrectly encoded
                return "Panic(34)";
            } else if (panicCode == 49) {
                // call .pop() on an empty array
                return "Panic(49)";
            } else if (panicCode == 50) {
                // array access out of bounds
                return "Panic(50)";
            } else if (panicCode == 65) {
                // allocate too much memory or create an array that is too large
                return "Panic(65)";
            } else if (panicCode == 81) {
                // call a zero-initialized variable of internal function type
                return "Panic(81)";
            }

            return "Undefined panic code";
        }

        // If the returnData length is less than 68, then the transaction failed silently (without a revert message)
        if (returnData.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash of the error
            returnData := add(returnData, 0x04)
        }
        
        // Returns the sighash as a string
        // Custom errors and are encoded as "keccak256(CustomError(uint))" - CustomError can be anything
        // Revert strings are encoded as "keccak256(Error(string))" - Error is always the same for a revert string
        // TODO: for revert strings, we should return the string of the error to be able to check it against the expected string
        return abi.decode(returnData, (string)); 
    }
}