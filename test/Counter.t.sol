// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Asserts} from "@chimera/Asserts.sol";
import {Test, console} from "forge-std/Test.sol";

import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

    /// @notice foundry unit test
    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 2);
    }

    /// @notice foundry fuzz test
    function testFuzz_SetNumber(uint256 newNumber) public {
        counter.setNumber(newNumber);
        if (newNumber != 0) {
            assertEq(counter.number(), newNumber);
        }
    }
}
