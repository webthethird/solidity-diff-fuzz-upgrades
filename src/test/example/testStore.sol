// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../helpers.sol";

contract C {
  address public owner;

  constructor() { // Constructor
    owner = msg.sender;
  }
}

contract TestStore {
    address admin;
    C c;

    constructor() {
        admin = msg.sender;
    }

    function testStore() public {
        c = new C();
        require(c.owner() == address(this));
        CheatCodes(HEVM_ADDRESS).store(address(c), bytes32(0), bytes32(bytes20(admin)));
        assert(address(bytes20(CheatCodes(HEVM_ADDRESS).load(address(c), bytes32(0)))) == admin);
        assert(c.owner() == admin);
    }
}