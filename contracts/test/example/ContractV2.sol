pragma solidity ^0.8.2;

import "./ProxyStorage.sol";

contract ContractV2 is ProxyStorage {
    uint private stateA = 0;
    uint private stateB = 0;
    uint constant CONST = 32;
    bool public bug = false;
    uint private stateC = 0;

    function f(uint x) public {
        if (msg.sender == admin) {
            stateA = x;
        }
    }

    function g(uint y) public {
        if (stateA % CONST == 1) {
            stateB = y - 10;
        }
    }

    function h() public {
        if (stateB == 32) {
            bug = true;
        }
    }

    function i() public {
        stateC = stateC + 1;
    }
}