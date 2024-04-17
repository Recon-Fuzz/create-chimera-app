// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 2);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        if (x != 0) {
            assertEq(counter.number(), x);
        }
    }
}
