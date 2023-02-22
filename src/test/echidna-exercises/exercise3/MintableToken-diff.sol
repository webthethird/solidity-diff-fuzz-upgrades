// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../helpers.sol";

// import { MintableToken_ADDR } from "../addresses.sol";
import { MintableToken } from "../../../implementation/echidna-exercises/exercise3/mintable.sol";
// import "../../interface/echidna-exercises/IMintable.sol";

contract MintableTokenFixed is MintableToken {
    constructor(int _totalMintable) MintableToken(_totalMintable) public {}

    function mint(uint value) isOwner() public override {

        require(totalMinted + int(value) >= totalMinted && int(value) >= 0, "Integer overflow!");
        super.mint(value);
     
    }
}

contract Test {
    MintableToken token_bug;
    MintableTokenFixed token_fix;

    constructor() public {
        token_bug = new MintableToken(10000);
        token_fix = new MintableTokenFixed(10000);
    }

    function mint_both(uint value) public {
        // token_bug.mint(value);
        // token_fix.mint(value);
        (bool successA, bytes memory outputA) = address(token_bug).call(abi.encodeWithSelector(token_bug.mint.selector, value));
        (bool successB, bytes memory outputB) = address(token_fix).call(abi.encodeWithSelector(token_fix.mint.selector, value));
    }

    function echidna_mint_excess() public returns (bool) {
        return token_bug.balances(address(this)) == token_fix.balances(address(this));
    }
}