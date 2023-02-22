pragma solidity ^0.6.0;

import "../../../implementation/echidna-exercises/exercise4/token.sol";

contract TestToken is Token {
    address echidna_caller = msg.sender;

    constructor() public {
        balances[echidna_caller] = 10000;
    }

    function test_balance(address to, uint value) public {
        uint balance_from = balances[msg.sender];
        uint balance_to = balances[to];
        transfer(to, value);
        assert(balances[msg.sender] <= balance_from && balances[to] >= balance_to);
    }
}