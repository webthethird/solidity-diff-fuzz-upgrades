pragma solidity ^0.8.2;

contract ContractV1 {
    address admin;
    uint public stateA = 0;
    uint public stateB = 0;
    uint constant CONST = 32;
    bool bug = false;

    function f(uint x) public {
        if (msg.sender == admin) {
            stateA = x;
        }
    }

    function g(uint y) public {
        if (checkA()) {
            stateB = y - 10;
        }
    }

    function h() public {
        if (checkB()) {
            bug = true;
        }
    }

    function checkA() internal returns (bool) {
        return stateA % CONST == 1;
    }

    function checkB() internal returns (bool) {
        return stateB == 62;
    }
}
