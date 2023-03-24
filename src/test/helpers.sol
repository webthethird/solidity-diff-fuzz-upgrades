// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

address constant HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
interface CheatCodes {
    // Performs a foreign function call via terminal.
    function ffi(string[] calldata) external returns (bytes memory);
    // Foundry: Generate new fuzzing inputs if conditional not met.
    function assume(bool) external;
    // Sets the block timestamp to x
    function warp(uint x) external;
    // Sets the block number to x
    function roll(uint x) external;
    // Sets the slot loc of contract c to val
    function store(address c, bytes32 loc, bytes32 val) external;
    // Reads the slot loc of contract c
    function load(address c, bytes32 loc) external returns (bytes32 val);
    // Signs the digest using the private key sk. Note that signatures produced via hevm.sign will leak the private key
    function sign(uint sk, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);
    // Derives an ethereum address from the private key sk. 
    // Note that hevm.addr(0) will fail with BadCheatCode as 0 is an invalid ECDSA private key
    function addr(uint sk) external returns (address addr);
    // Sets the msg.sender to sender for the following call
    function prank(address sender) external;
    // Saves the current global state and creates a new fork, returning an identifier to use with selectFork(forkId)
    function createFork() external returns (uint256 forkId);
    // Sets the global state to that of the fork with the given forkId
    function selectFork(uint256 forkId) external;
}

/**
 * Skip invalid fuzzing inputs.
 *
 * Both Foundry and Echidna (in dapptest mode) will take revert/assert errors
 * as test failure. This helper function is for skipping invalid inputs that
 * shouldn't be misunderstood as a fuzzer-finding.
 */
function assuming(bool condition) {
    // Foundry has a special cheatcode for this:
    if (block.gaslimit > 0) {
        // This call will cause Echidna to get stuck, so this "gaslimit" check
        // ensures it's only executed when doing fuzzing within foundry.
        // NOTE: The gaslimit in Echidna will only be 0 if there's an init file!
        CheatCodes(HEVM_ADDRESS).assume(condition);
    }
    // For Echidna in dapptest mode: Use a specific revert reason for skipping.
    require(condition, "FOUNDRY::ASSUME");
}

function exec(string[] memory args) returns (bytes memory) {
    return CheatCodes(HEVM_ADDRESS).ffi(args);
}

function toHex(bytes memory data) pure returns (bytes memory res) {
    res = new bytes(data.length * 2);
    bytes memory alphabet = "0123456789abcdef";
    for (uint i = 0; i < data.length; i++) {
        res[i*2 + 0] = alphabet[uint256(uint8(data[i])) >> 4];
        res[i*2 + 1] = alphabet[uint256(uint8(data[i])) & 15];
    }
}
