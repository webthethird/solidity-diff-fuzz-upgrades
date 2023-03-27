// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../lib/forge-std/src/Test.sol";
import "../../lib/forge-std/src/console2.sol";

contract TestLogging is Test {
    function setUp() public {
        console2.log("hello from setUp()");
        console2.log("printing uint %s from setUp()", 42);
    }

    // The logs in this function (which always passes) are not caught
    function test_console_passing(uint8 i) public {
        console2.log("hello from test_console_passing(uint8)");
        console2.log("printing uint %s from test_console_passing(uint8)", i);
        assert(i == i);
    }

    // The logs in this function (which fails) are caught 
    function test_console_failing(uint8 i) public {
        console2.log("hello from test_console_failing(uint8)");
        console2.log("printing uint %s from test_console_failing(uint8)", i);
        assert(i == 1337);
    }
}