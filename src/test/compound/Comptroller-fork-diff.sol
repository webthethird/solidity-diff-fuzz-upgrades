// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
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

    Comptroller constant unitroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    Comp constant comp = Comp(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    
    // Change these to vary the mainnet block numbers at which to compare results
    uint256 constant before_block = 13322796;
    uint256 constant after_block = 13322799;

    uint256 before_fork_id;
    uint256 after_fork_id;
    string rpc;

    function setUp() public {
        rpc = vm.envString("RPC_URL");
        before_fork_id = vm.createFork(rpc, before_block);
        after_fork_id = vm.createFork(rpc, after_block);
    }

    /**
     * Test claiming COMP on both forks and assert that the amount of tokens transfered is the same.
     * 
     * Ideally the gap in block numbers should be minimal to ensure any difference is not due to state
     * changes between blocks, or just more accrual over time (need to double-check how accruals work).
     * 
     * Right now the address is what the fuzzer will mutate, but it would be better to have a
     * pre-defined list of known participant addresses to choose randomly from.
     */
    function test_claimComp_diff_before_after(address holder) public {
        vm.selectFork(before_fork_id);

        // Disregard test run if the given address is not a participant in any Compound markets
        CToken[] memory assetsIn = unitroller.getAssetsIn(holder);
        vm.assume(assetsIn.length > 0);

        // Check the COMP balance of the holder before and after claiming from the old Comptroller
        Multicall2.Call[] memory calls = new Multicall2.Call[](3);
        // uint256 balance_before = comp.balanceOf(holder);
        calls[0].target = address(comp);
        calls[0].callData = abi.encodeWithSelector(comp.balanceOf.selector, holder);
        // unitroller.claimComp(holder);
        calls[1].target = address(unitroller);
        calls[1].callData = abi.encodeWithSignature("claimComp(address)", holder);
        // uint256 new_balance_before = comp.balanceOf(holder);
        calls[2].target = address(comp);
        calls[2].callData = abi.encodeWithSelector(comp.balanceOf.selector, holder);
        
        Multicall2.Result[] memory results_before = Multicall2(0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696).tryAggregate(false, calls);
        uint256 balance_before = abi.decode(results_before[0].returnData, (uint256));
        uint256 new_balance_before = abi.decode(results_before[2].returnData, (uint256));
        uint256 delta_before = new_balance_before - balance_before;

        // Switch to the fork from after the upgrade, then perform the same calls
        vm.selectFork(after_fork_id);
        Multicall2.Result[] memory results_after = Multicall2(0x5BA1e12693Dc8F9c48aAD8770482f4739bEeD696).tryAggregate(false, calls);
        uint256 balance_after = abi.decode(results_after[0].returnData, (uint256));
        uint256 new_balance_after = abi.decode(results_after[2].returnData, (uint256));
        uint256 delta_after = new_balance_after - balance_after;
        
        // Assert that the change in COMP balance is approximately equal on both forks (max delta of 5%)
        assertApproxEqRel(delta_before, delta_after, 0.05e18, "COMP balance deltas vary by more than 5%");
    }

    // function test_changed_impl() public {
    //     vm.selectFork(before_fork_id);
    //     address impl_before = unitroller.comptrollerImplementation();
    //     vm.rollFork(after_block);
    //     address impl_after = unitroller.comptrollerImplementation();
    //     assertFalse(impl_before == impl_after);
    // }
}