// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../helpers.sol";

// import { MintableToken_ADDR } from "../addresses.sol";
import { MintableToken } from "../../../implementation/echidna-exercises/exercise3/mintable.sol";
// import "../../interface/echidna-exercises/IMintable.sol";

contract Test is MintableToken {
    address echidna_sender;

    constructor() MintableToken(10000) public {
        echidna_sender = msg.sender;
    }

    function echidna_mint_excess() public returns (bool) {
        return balances[echidna_sender] <= 10000;
    }
}