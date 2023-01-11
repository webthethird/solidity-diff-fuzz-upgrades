pragma solidity ^0.8.9;

import "./Setup.sol";
import { CErc20Immutable_BEFORE_ADDR, CErc20Immutable_AFTER_ADDR } from "../addresses.sol";

contract ComptrollerDiffFuzz is Setup {
    function testCompBalances() public view {
        uint balanceBefore = compTokenBefore.balanceOf(msg.sender);
        uint balanceAfter = compTokenAfter.balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testCTokenBalances(uint8 marketIndex) public view {
        require(comptrollerAfter.getAllMarkets().length == comptrollerBefore.getAllMarkets().length);
        uint index = marketIndex % comptrollerBefore.getAllMarkets().length;
        uint balanceBefore = comptrollerBefore.getAllMarkets()[index].balanceOf(msg.sender);
        uint balanceAfter = comptrollerAfter.getAllMarkets()[index].balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testAddNewMarket() public {
        uint numMarketsBefore = comptrollerBefore.getAllMarkets().length;
        uint numMarketsAfter = comptrollerAfter.getAllMarkets().length;
        require(numMarketsAfter == numMarketsBefore);
        CheatCodes(HEVM_ADDRESS).store(UNITROLLER_BEFORE_ADDR, bytes32(0), bytes32(bytes20(address(this))));
        CheatCodes(HEVM_ADDRESS).store(UNITROLLER_AFTER_ADDR, bytes32(0), bytes32(bytes20(address(this))));
        require(address(bytes20(CheatCodes(HEVM_ADDRESS).load(UNITROLLER_BEFORE_ADDR, bytes32(0)))) == address(this));
        require(address(bytes20(CheatCodes(HEVM_ADDRESS).load(UNITROLLER_AFTER_ADDR, bytes32(0)))) == address(this));
        
        CToken cErc20Before = CToken(CErc20Immutable_BEFORE_ADDR);
        CToken cErc20After = CToken(CErc20Immutable_AFTER_ADDR);

        comptrollerBefore._supportMarket(cErc20Before);
        comptrollerAfter._supportMarket(cErc20After);

        assert(comptrollerAfter.getAllMarkets().length == numMarketsAfter + 1);
        assert(comptrollerBefore.getAllMarkets().length == numMarketsBefore + 1);
    }
}