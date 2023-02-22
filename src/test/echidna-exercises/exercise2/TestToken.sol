pragma solidity ^0.6.0;

import "../../../implementation/echidna-exercises/exercise2/token.sol";

contract TestToken is Token {
    address echidna_caller = msg.sender;

    constructor() public {
        paused();
        owner = address(0x0);
    }

    function echidna_no_transfer() public view returns (bool) {
        return is_paused;
    }
}