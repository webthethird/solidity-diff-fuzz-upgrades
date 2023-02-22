pragma solidity ^0.6.0;

import "../../../implementation/echidna-exercises/exercise1/token.sol";

contract TestToken is Token {
    address echidna_caller = msg.sender;

    constructor() public {
        balances[echidna_caller] = 10000;
    }

    function echidna_test_balance() public view returns (bool) {
        return balances[echidna_caller] <= 10000;
    }
}