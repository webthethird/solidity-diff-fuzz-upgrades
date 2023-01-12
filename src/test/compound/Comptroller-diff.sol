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

    function testAddNewMarket(uint8 marketIndex) public {
        require(!marketAdded);
        CToken[] memory marketsBefore = comptrollerBefore.getAllMarkets();
        CToken[] memory marketsAfter = comptrollerAfter.getAllMarkets();
        uint numMarketsBefore = marketsBefore.length;
        uint numMarketsAfter = marketsAfter.length;
        require(numMarketsAfter == numMarketsBefore);
        require(numMarketsBefore > 0 && numMarketsAfter > 0);
        
        CToken cErc20Before = CToken(CErc20Immutable_BEFORE_ADDR);
        CToken cErc20After = CToken(CErc20Immutable_AFTER_ADDR);

        assert(cErc20Before.isCToken());
        assert(cErc20After.isCToken());

        uint index = marketIndex % numMarketsBefore;
        CToken example = marketsBefore[index];
        uint exampleUnderlyingPrice = SimplePriceOracle(address(comptrollerBefore.oracle())).getUnderlyingPrice(example);
        uint exampleDirectPrice = SimplePriceOracle(address(comptrollerBefore.oracle())).assetPrices(address(example));
        uint exampleReserveFactor = example.reserveFactorMantissa();
        uint exampleCollateralFactor = 60e16;

        address adminBefore = cErc20Before.admin();
        CheatCodes(HEVM_ADDRESS).prank(adminBefore);
        cErc20Before._setReserveFactor(exampleReserveFactor);
        address adminAfter = cErc20After.admin();
        CheatCodes(HEVM_ADDRESS).prank(adminAfter);
        cErc20After._setReserveFactor(exampleReserveFactor);

        SimplePriceOracle(address(comptrollerBefore.oracle())).setUnderlyingPrice(cErc20Before, exampleUnderlyingPrice);
        SimplePriceOracle(address(comptrollerAfter.oracle())).setUnderlyingPrice(cErc20After, exampleUnderlyingPrice);
        SimplePriceOracle(address(comptrollerBefore.oracle())).setDirectPrice(address(cErc20Before), exampleDirectPrice);
        SimplePriceOracle(address(comptrollerAfter.oracle())).setDirectPrice(address(cErc20After), exampleDirectPrice);

        comptrollerBefore._supportMarket(cErc20Before);
        comptrollerAfter._supportMarket(cErc20After);

        comptrollerBefore._setCollateralFactor(cErc20Before, exampleCollateralFactor);
        comptrollerAfter._setCollateralFactor(cErc20After, exampleCollateralFactor);

        assert(comptrollerBefore.getAllMarkets().length == numMarketsBefore + 1);
        assert(comptrollerAfter.getAllMarkets().length == numMarketsAfter + 1);

        marketAdded = true;
    }

    function testSupportExistingMarket(uint8 marketIndex) public {
        CToken[] memory marketsBefore = comptrollerBefore.getAllMarkets();
        CToken[] memory marketsAfter = comptrollerAfter.getAllMarkets();
        uint index = marketIndex % marketsAfter.length;
        CToken cErc20Before = marketsBefore[index];
        CToken cErc20After = marketsAfter[index];
        require(cErc20Before.isCToken());
        require(cErc20After.isCToken());

        uint numMarketsBefore = marketsBefore.length;
        uint numMarketsAfter = marketsAfter.length;

        comptrollerBefore._supportMarket(cErc20Before);
        comptrollerAfter._supportMarket(cErc20After);

        assert(comptrollerBefore.getAllMarkets().length == numMarketsBefore);
        assert(comptrollerAfter.getAllMarkets().length == numMarketsAfter);
    }

    function testSetPauseGuardian() public {
        (bool success1,) = address(comptrollerBefore).call(abi.encodeWithSignature("_setPauseGuardian(address)", address(this)));
        (bool success2,) = address(comptrollerAfter).call(abi.encodeWithSignature("_setPauseGuardian(address)", address(this)));
        assert(success1 && success2);
    }

    function testClaimComp(bool[] calldata toClaim) public {
        CToken[] memory marketsBefore = comptrollerBefore.getAllMarkets();
        CToken[] memory marketsAfter = comptrollerAfter.getAllMarkets();
        require(toClaim.length >= marketsBefore.length && marketsBefore.length == marketsAfter.length);
        
        uint h = 0;
        for(uint i = 0; i < toClaim.length; i++) {
            if(toClaim[i] && h < marketsBefore.length) {
                h++;
            }
        }
        require(h > 0);

        CToken[] memory toClaimBefore = new CToken[](h);
        CToken[] memory toClaimAfter = new CToken[](h);
        uint j = 0;
        for(uint i = 0; i < marketsBefore.length; i++) {
            if (toClaim[i]) {
                toClaimBefore[j] = marketsBefore[i];
                toClaimAfter[j] = marketsAfter[i];
                j++;
            }
        }

        assert(compTokenBefore.decimals() == 18);

        uint balanceBefore0 = compTokenBefore.balanceOf(msg.sender);
        comptrollerBefore.claimComp(msg.sender, toClaimBefore);
        uint balanceBefore1 = compTokenBefore.balanceOf(msg.sender);
        uint deltaBefore = balanceBefore1 - balanceBefore0;

        uint balanceAfter0 = compTokenAfter.balanceOf(msg.sender);
        comptrollerAfter.claimComp(msg.sender, toClaimAfter);
        uint balanceAfter1 = compTokenAfter.balanceOf(msg.sender);
        uint deltaAfter = balanceAfter1 - balanceAfter0;

        assert(deltaBefore == deltaAfter);
    }
}