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
        require(!marketAdded);
        uint numMarketsBefore = comptrollerBefore.getAllMarkets().length;
        uint numMarketsAfter = comptrollerAfter.getAllMarkets().length;
        require(numMarketsAfter == numMarketsBefore);
        
        CToken cErc20Before = CToken(CErc20Immutable_BEFORE_ADDR);
        CToken cErc20After = CToken(CErc20Immutable_AFTER_ADDR);

        assert(cErc20Before.isCToken());
        assert(cErc20After.isCToken());

        comptrollerBefore._supportMarket(cErc20Before);
        comptrollerAfter._supportMarket(cErc20After);

        assert(comptrollerBefore.getAllMarkets().length == numMarketsBefore + 1);
        assert(comptrollerAfter.getAllMarkets().length == numMarketsAfter + 1);

        marketAdded = true;
    }
}