// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../lib/forge-std/src/Test.sol";
import "../../lib/forge-std/src/console2.sol";

contract TestAssert is Test {
    string constant LOG_FILE = "./.log";

    function setUp() public {
        vm.writeFile(LOG_FILE, "");
    }

    function test_assert_eq(uint256 i) public {
        // vm.assume(i > 0);
        vm.writeLine(LOG_FILE, string.concat("i:", vm.toString(i)));
        assertEq(0, i, "assert failed!"); // should always fail on first run due to `vm.assume`
    }

    function test_assert_addr_eq_zero(address i) public {
        vm.assume(i != address(0));
        vm.writeLine(LOG_FILE, string.concat("i:", vm.toString(i)));
        assertEq(address(0), i, "assert failed!"); // should always fail on first run due to `vm.assume`
    }

    function test_assert_addrs_eq(address i, address j) public {
        vm.assume(i != address(0));
        vm.assume(j != address(0));
        vm.writeLine(LOG_FILE, string.concat("i:", vm.toString(i)));
        vm.writeLine(LOG_FILE, string.concat("j:", vm.toString(j)));
        assertEq(j, i, "assert failed!"); // should always fail on first run due to `vm.assume`
    }


    function test_assert_approx(uint256 i) public {
        vm.assume(i > 0);
        vm.writeLine(LOG_FILE, string.concat("i:", vm.toString(i)));

        assertApproxEqRel(i, 0, 1e17, "assert approx failed!");
    }
}