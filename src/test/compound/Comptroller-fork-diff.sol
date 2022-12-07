// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../../lib/forge-std/src/console2.sol";
import "../Multicall2.sol";
import { Comptroller, Comp, CToken } from "../../interface/compound/Comptroller.sol";

/**
 * Differential fuzz testing contract to test the Compound comptroller contract
 * before and after the upgrade that led to the COMP token distribution bug.
 * To my knowledge, this will only work with Foundry / Forge, not Echidna, which 
 * (according to Echidna developer Gustavo Grieco) doesn't support forked networks.
 * 
 * In this first iteration, this can be used to fuzz the two versions after both
 * were already deployed to mainnet, though in the future we should be able to
 * fuzz the existing (deployed) contract against a new version pre-deployment
 * (or at least a deployed upgrade before it is set as the new implementation).
 */

contract TestComptroller is Test {
    /**
     * For use with Multicall2
     * Address (mainnet): 0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696
     * Deployed at block: 12336033 
     */
    struct Call {
        address target;
        bytes callData;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    Comptroller constant UNITROLLER = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    Comp constant COMP = Comp(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    address constant OLD_IMPL = 0x75442Ac771a7243433e033F3F8EaB2631e22938f;
    address constant NEW_IMPL = 0x374ABb8cE19A73f2c4EFAd642bda76c797f19233;
    
    // Change these to vary the mainnet block numbers at which to compare results
    uint256 constant BEFORE_BLOCK = 13322796;
    uint256 constant AFTER_BLOCK = 13324197;    // 13322799;

    uint256 before_fork_id;
    uint256 after_fork_id;
    string rpc;

    string constant USERS_FILE = "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/compound_accounts_csushi.txt";
    string constant LOG_FILE = "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/.log";
    uint num_users;
    address[] users;
    address[] users_tested;

    constructor() {
        // Since console logs are not printed until after fuzzing is complete, output logs to a file
        // Here, clear any logs from previous fuzzing campaigns or create the log file if it doesn't exist
        vm.writeFile(LOG_FILE, "");

        // Read pre-defined list of known Compound users from file (first line is the number of addresses)
        num_users = vm.parseUint(vm.readLine(USERS_FILE));
        users = new address[](num_users);
        users_tested = new address[](num_users);
        console2.log("Number of addresses: %s", num_users);
        for(uint i = 0; i < num_users; i++) {
            address user_addr = vm.parseAddress(vm.readLine(USERS_FILE));
            // console.log(i, user_addr);
            users[i] = user_addr;
        }
        vm.closeFile(USERS_FILE);
    }

    function setUp() public {
        rpc = vm.envString("RPC_URL");
        before_fork_id = vm.createFork(rpc, BEFORE_BLOCK);
        after_fork_id = vm.createFork(rpc, AFTER_BLOCK); 
    }

    /**
     * Test claiming COMP on both forks and assert that the amount of tokens transfered is roughly the same.
     * 
     * Ideally the gap in block numbers should be minimal to ensure any difference is not due to state
     * changes between blocks, or just more accrual over time (need to double-check how accruals work).
     * 
     * Uses a pre-defined list of known participant addresses to choose randomly from.
     */
    function test_claimComp_diff_before_after(uint8 _index) public { //, bool _double, bool _fromRear) public {
        uint index = uint(_index) % num_users;
        // if(_double) {
        //     index = (2 * index) % num_users;
        // }
        // if(_fromRear && index > 0) {
        //     index = num_users - index;
        // }
        address holder = users[index];

        vm.assume(users_tested[index] == address(0));
        users_tested[index] = holder;

        console2.log("Index %s", index);
        console2.log("Address %s", holder);

        vm.writeLine(LOG_FILE, vm.toString(index));
        vm.writeLine(LOG_FILE, vm.toString(holder));

        vm.selectFork(after_fork_id);

        // Disregard test run if the given address is not a participant in any Compound markets
        // CToken[] memory assetsIn = unitroller.getAssetsIn(holder);
        // vm.assume(assetsIn.length > 0);

        // Check the COMP balance of the holder before and after claiming from the upgraded Comptroller
        Multicall2.Call[] memory calls = new Multicall2.Call[](3);
        // uint256 balance_before = comp.balanceOf(holder);
        calls[0].target = address(COMP);
        calls[0].callData = abi.encodeWithSelector(COMP.balanceOf.selector, holder);
        // unitroller.claimComp(holder);
        calls[1].target = address(UNITROLLER);
        calls[1].callData = abi.encodeWithSignature("claimComp(address)", holder);
        // uint256 new_balance_before = comp.balanceOf(holder);
        calls[2].target = address(COMP);
        calls[2].callData = abi.encodeWithSelector(COMP.balanceOf.selector, holder);
        
        Multicall2.Result[] memory results_after = Multicall2(0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696).tryAggregate(true, calls);
        uint256 balance_after = abi.decode(results_after[0].returnData, (uint256));
        uint256 new_balance_after = abi.decode(results_after[2].returnData, (uint256));
        uint256 delta_after = new_balance_after - balance_after;
        
        // Discard test run if the user does not receive any COMP rewards after upgrade
        vm.assume(new_balance_after > 0 && delta_after > 0);

        // Switch to the fork from before the upgrade, then perform the same calls
        vm.selectFork(before_fork_id);
        Multicall2.Result[] memory results_before = Multicall2(0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696).tryAggregate(true, calls);
        uint256 balance_before = abi.decode(results_before[0].returnData, (uint256));
        uint256 new_balance_before = abi.decode(results_before[2].returnData, (uint256));
        uint256 delta_before = new_balance_before - balance_before;

        console2.log("Delta before = %s", delta_before);
        console2.log("Delta after = %s", delta_after);

        vm.writeLine(LOG_FILE, "Delta before:");
        vm.writeLine(LOG_FILE, vm.toString(delta_before));
        vm.writeLine(LOG_FILE, "Delta after:");
        vm.writeLine(LOG_FILE, vm.toString(delta_after));
        vm.writeLine(LOG_FILE, "");
        
        // Assert that the change in COMP balance is approximately equal on both forks (max delta of 5%)
        assertApproxEqRel(delta_before, delta_after, 5e16, "COMP balance deltas vary by more than 5%");
    }

    /**
     * Test claiming COMP on the "after" fork, with and without using the cheat code vm.store to 
     * reset the old implementation, and assert that the amount of tokens transfered is the same.
     * 
     * Uses a pre-defined list of known participant addresses to choose randomly from.
     */
    function test_claimComp_diff_cheat_upgrade(uint8 _index) public {
        uint index = uint(_index) % num_users;
        address holder = users[index];

        vm.assume(users_tested[index] == address(0));
        users_tested[index] = holder;

        console2.log("Index %s", index);
        console2.log("Address %s", holder);

        vm.writeLine(LOG_FILE, vm.toString(index));
        vm.writeLine(LOG_FILE, vm.toString(holder));

        vm.selectFork(after_fork_id);

        // Check the COMP balance of the holder before and after claiming from the upgraded Comptroller
        Multicall2.Call[] memory calls = new Multicall2.Call[](3);
        // uint256 balance_before = comp.balanceOf(holder);
        calls[0].target = address(COMP);
        calls[0].callData = abi.encodeWithSelector(COMP.balanceOf.selector, holder);
        // unitroller.claimComp(holder);
        calls[1].target = address(UNITROLLER);
        calls[1].callData = abi.encodeWithSignature("claimComp(address)", holder);
        // uint256 new_balance_before = comp.balanceOf(holder);
        calls[2].target = address(COMP);
        calls[2].callData = abi.encodeWithSelector(COMP.balanceOf.selector, holder);
        
        Multicall2.Result[] memory results_after = Multicall2(0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696).tryAggregate(true, calls);
        uint256 balance_after = abi.decode(results_after[0].returnData, (uint256));
        uint256 new_balance_after = abi.decode(results_after[2].returnData, (uint256));
        uint256 delta_after = new_balance_after - balance_after;
        
        // Discard test run if the user does not receive any COMP rewards after upgrade
        vm.assume(new_balance_after > 0 && delta_after > 0);

        // Roll back the fork to the same block as before, store the old implementation address, then perform the same calls
        vm.rollFork(AFTER_BLOCK);
        vm.store(address(UNITROLLER), bytes32(uint256(2)), bytes32(bytes20(OLD_IMPL)));

        Multicall2.Result[] memory results_before = Multicall2(0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696).tryAggregate(true, calls);
        uint256 balance_before = abi.decode(results_before[0].returnData, (uint256));
        uint256 new_balance_before = abi.decode(results_before[2].returnData, (uint256));
        uint256 delta_before = new_balance_before - balance_before;

        console2.log("Delta before = %s", delta_before);
        console2.log("Delta after = %s", delta_after);

        vm.writeLine(LOG_FILE, "Delta before:");
        vm.writeLine(LOG_FILE, vm.toString(delta_before));
        vm.writeLine(LOG_FILE, "Delta after:");
        vm.writeLine(LOG_FILE, vm.toString(delta_after));
        vm.writeLine(LOG_FILE, "");

        assertEq(delta_before, delta_after);
    }

    // function test_changed_impl() public {
    //     vm.selectFork(before_fork_id);
    //     address impl_before = unitroller.comptrollerImplementation();
    //     vm.rollFork(after_block);
    //     address impl_after = unitroller.comptrollerImplementation();
    //     assertFalse(impl_before == impl_after);
    // }
}