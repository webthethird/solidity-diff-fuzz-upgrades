pragma solidity ^0.8.9;

import "./Setup.sol";

contract ComptrollerDiffFuzz is Setup {
    function testCompBalances() public {
        uint balanceBefore = compTokenBefore.balanceOf(msg.sender);
        uint balanceAfter = compTokenAfter.balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testCTokenBalances(uint8 marketIndex) public {
        require(marketsAfter.length == marketsBefore.length);
        uint index = marketIndex % marketsBefore.length;
        uint balanceBefore = marketsBefore[index].balanceOf(msg.sender);
        uint balanceAfter = marketsAfter[index].balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }
}