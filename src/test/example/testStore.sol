// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../helpers.sol";

contract C {
    address public owner;

    constructor() {
        // Constructor
        owner = msg.sender;
    }
}

contract TestStore {
    event AdminIs(address admin);
    event OwnerIs(address owner);
    event LoadedValue(bytes32 val);

    address admin;
    C c;

    constructor() {
        admin = msg.sender;
        emit AdminIs(admin);
    }

    function testStore() public {
        c = new C();
        require(c.owner() == address(this));
        emit OwnerIs(c.owner());

        bytes32 loadedValue = CheatCodes(HEVM_ADDRESS).load(
            address(c),
            bytes32(0)
        );
        emit LoadedValue(loadedValue);

        emit AdminIs(admin);
        CheatCodes(HEVM_ADDRESS).store(
            address(c),
            bytes32(0),
            bytes32(uint256(uint160(admin)))
        );

        loadedValue = CheatCodes(HEVM_ADDRESS).load(address(c), bytes32(0));
        emit LoadedValue(loadedValue);

        assert(loadedValue == bytes32(uint256(uint160(admin))));

        emit OwnerIs(c.owner());
        assert(c.owner() == admin);
    }
}
