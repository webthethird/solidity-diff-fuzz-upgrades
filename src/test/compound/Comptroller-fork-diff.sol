// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../../../lib/forge-std/src/Test.sol";
import "../../expose/compound/Comptroller.sol";

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
    ExposedComptroller unitroller;
    uint256 immutable before_fork_id;
    uint256 immutable after_fork_id;
    Comp immutable comp;

    constructor(address _unitroller, string calldata _rpc, uint256 _before_block, uint256 _after_block) {
        unitroller = ExposedComptroller(_unitroller);
        comp = Comp(unitroller.getCompAddress());
        before_fork_id = vm.createFork(_rpc, _before_block);
        after_fork_id = vm.createFork(_rpc, _after_block);
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
    function test_claimComp_diff_before_after(address holder) {
        vm.selectFork(before_fork_id);

        // Disregard test run if the given address is not a participant in any Compound markets
        CToken[] memory assetsIn = unitroller.getAssetsIn(holder);
        assume(len(assetsIn) > 0);

        // Check the COMP balance of the holder before and after claiming from the old Comptroller
        uint256 balance_before = comp.balanceOf(holder);
        unitroller.claimComp(holder);
        uint256 new_balance_before = comp.balanceOf(holder);

        // Switch to the fork from after the upgrade, then do the same
        vm.selectFork(after_fork_id);
        uint256 balance_after = comp.balanceOf(holder);
        unitroller.claimComp(holder);
        uint256 new_balance_after = comp.balanceOf(holder);

        // Assert that the change in COMP balance is the same on both forks
        assertEq(new_balance_before - balance_before, new_balance_after - balance_after);
    }
}