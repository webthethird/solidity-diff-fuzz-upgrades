// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../lib/forge-std/src/Test.sol";
import "../../lib/forge-std/src/console2.sol";

contract TestAssert is Test {
    string constant LOG_FILE = "./.log";

    constructor() {
        // Since console logs are not printed until after fuzzing is complete, output logs to a file
        // Here, clear any logs from previous fuzzing campaigns or create the log file if it doesn't exist
        vm.writeFile(LOG_FILE, "");
    }

    function test_assert_eq(uint8 test) public {
        uint i = uint(uint128(test));
        uint j = i * 2000;

        vm.writeLine(LOG_FILE, "i:");
        vm.writeLine(LOG_FILE, vm.toString(i));
        vm.writeLine(LOG_FILE, "j:");
        vm.writeLine(LOG_FILE, vm.toString(j));
        vm.writeLine(LOG_FILE, "");

        assertEq(i, j, "assert failed!");
    }

    function test_assert_approx(uint8 test) public {
        uint i = uint(uint128(test));
        uint j = i * 2000;

        vm.writeLine(LOG_FILE, "i:");
        vm.writeLine(LOG_FILE, vm.toString(i));
        vm.writeLine(LOG_FILE, "j:");
        vm.writeLine(LOG_FILE, vm.toString(j));
        vm.writeLine(LOG_FILE, "");

        assertApproxEqRel(i, j, 1e17, "assert approx failed!");
    }
}