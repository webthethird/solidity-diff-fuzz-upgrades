pragma solidity ^0.8.10;

import "./Setup.sol";
import "../../implementation/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import {CErc20Immutable} from "../../implementation/compound/master-contracts/CErc20Immutable.sol";
import {SimplePriceOracle} from "../../implementation/compound/master-contracts/SimplePriceOracle.sol";
import {Fauceteer} from "../../implementation/compound/master-contracts/Fauceteer.sol";

contract ComptrollerDiffFuzz is Setup {
    function testCompBalances() public view {
        uint256 balanceBefore = compTokenBefore.balanceOf(msg.sender);
        uint256 balanceAfter = compTokenAfter.balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testCTokenBalances(uint8 marketIndex) public view {
        require(
            marketsAfter.length == comptrollerBefore.getAllMarkets().length
        );
        uint256 index = marketIndex % comptrollerBefore.getAllMarkets().length;
        uint256 balanceBefore = marketsBefore[index].balanceOf(msg.sender);
        uint256 balanceAfter = marketsAfter[index].balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testAddNewMarket(uint8 marketIndex) public {
        // Preconditions
        // require(!marketAdded);
        uint256 numMarketsBefore = marketsBefore.length;
        uint256 numMarketsAfter = marketsAfter.length;
        require(numMarketsAfter == numMarketsBefore);
        require(numMarketsBefore > 0 && numMarketsAfter > 0);

        // Create underlying ERC20 tokens with initial supply given to faucets
        ERC20PresetFixedSupply underlyingBefore = new ERC20PresetFixedSupply(
            "testBefore",
            "BFOR",
            1e28,
            FAUCET_BEFORE_ADDR
        );
        ERC20PresetFixedSupply underlyingAfter = new ERC20PresetFixedSupply(
            "testAfter",
            "AFTR",
            1e28,
            FAUCET_AFTER_ADDR
        );

        // CToken cErc20Before = CToken(CErc20Immutable_BEFORE_ADDR);
        // CToken cErc20After = CToken(CErc20Immutable_AFTER_ADDR);

        // assert(cErc20Before.isCToken());
        // assert(cErc20After.isCToken());

        // Get example initialization values from pre-existing cERC20
        uint256 index = marketIndex % numMarketsBefore;
        CToken example = marketsBefore[index];
        assert(example.isCToken());
        uint256 exampleReserveFactor = example.reserveFactorMantissa();
        uint256 exampleCollateralFactor = 60e16;

        // Deploy cErc20Immutable tokens
        CErc20Immutable cErc20Before = new CErc20Immutable(
            address(underlyingBefore),
            ComptrollerInterface(comptrollerBefore),
            example.interestRateModel(),
            2e16,
            "cTestBefore",
            "cBFOR",
            8,
            payable(address(this))
        );
        CErc20Immutable cErc20After = new CErc20Immutable(
            address(underlyingAfter),
            ComptrollerInterface(comptrollerAfter),
            example.interestRateModel(),
            2e16,
            "cTestAfter",
            "cAFTR",
            8,
            payable(address(this))
        );

        // Actions
        // address adminBefore = cErc20Before.admin();
        // CheatCodes(HEVM_ADDRESS).prank(adminBefore);
        cErc20Before._setReserveFactor(exampleReserveFactor);
        // address adminAfter = cErc20After.admin();
        // CheatCodes(HEVM_ADDRESS).prank(adminAfter);
        cErc20After._setReserveFactor(exampleReserveFactor);

        uint256 exampleUnderlyingPrice = SimplePriceOracle(
            address(comptrollerBefore.oracle())
        ).getUnderlyingPrice(example);
        assert(exampleUnderlyingPrice > 0);
        SimplePriceOracle(address(comptrollerBefore.oracle()))
            .setUnderlyingPrice(cErc20Before, exampleUnderlyingPrice);
        SimplePriceOracle(address(comptrollerAfter.oracle()))
            .setUnderlyingPrice(cErc20After, exampleUnderlyingPrice);
        // SimplePriceOracle(address(comptrollerBefore.oracle())).setDirectPrice(
        //     address(cErc20Before),
        //     exampleDirectPrice
        // );
        // SimplePriceOracle(address(comptrollerAfter.oracle())).setDirectPrice(
        //     address(cErc20After),
        //     exampleDirectPrice
        // );

        comptrollerBefore._supportMarket(cErc20Before);
        comptrollerAfter._supportMarket(cErc20After);

        comptrollerBefore._setCollateralFactor(
            cErc20Before,
            exampleCollateralFactor
        );
        comptrollerAfter._setCollateralFactor(
            cErc20After,
            exampleCollateralFactor
        );

        marketsBefore = comptrollerBefore.getAllMarkets();
        marketsAfter = comptrollerAfter.getAllMarkets();

        // Postconditions
        assert(marketsBefore.length == numMarketsBefore + 1);
        assert(marketsAfter.length == numMarketsAfter + 1);

        // marketAdded = true;
    }

    function testSupportExistingMarket(uint8 marketIndex) public {
        // Preconditions
        uint256 index = marketIndex % marketsAfter.length;
        CToken cErc20Before = marketsBefore[index];
        CToken cErc20After = marketsAfter[index];
        require(cErc20Before.isCToken());
        require(cErc20After.isCToken());

        uint256 numMarketsBefore = marketsBefore.length;
        uint256 numMarketsAfter = marketsAfter.length;

        // Action
        uint256 result1 = comptrollerBefore._supportMarket(cErc20Before);
        uint256 result2 = comptrollerAfter._supportMarket(cErc20After);

        // Postconditions
        assert(result1 > 0 && result2 > 0);
        assert(comptrollerBefore.getAllMarkets().length == numMarketsBefore);
        assert(comptrollerAfter.getAllMarkets().length == numMarketsAfter);
    }

    function testSetPauseGuardian() public {
        (bool success1, ) = address(comptrollerBefore).call(
            abi.encodeWithSignature("_setPauseGuardian(address)", address(this))
        );
        (bool success2, ) = address(comptrollerAfter).call(
            abi.encodeWithSignature("_setPauseGuardian(address)", address(this))
        );
        assert(success1 && success2);
    }

    function testClaimComp(bool[] calldata toClaim) public {
        // Preconditions
        require(
            toClaim.length >= marketsBefore.length &&
                marketsBefore.length == marketsAfter.length
        );

        uint256 h = 0;
        for (uint256 i = 0; i < toClaim.length; i++) {
            if (toClaim[i] && h < marketsBefore.length) {
                h++;
            }
        }
        require(h > 0);

        CToken[] memory toClaimBefore = new CToken[](h);
        CToken[] memory toClaimAfter = new CToken[](h);
        uint256 j = 0;
        for (uint256 i = 0; i < marketsBefore.length; i++) {
            if (toClaim[i]) {
                toClaimBefore[j] = marketsBefore[i];
                toClaimAfter[j] = marketsAfter[i];
                j++;
            }
        }

        assert(compTokenBefore.decimals() == 18);

        // Actions
        uint256 balanceBefore0 = compTokenBefore.balanceOf(msg.sender);
        comptrollerBefore.claimComp(msg.sender, toClaimBefore);
        uint256 balanceBefore1 = compTokenBefore.balanceOf(msg.sender);
        uint256 deltaBefore = balanceBefore1 - balanceBefore0;

        uint256 balanceAfter0 = compTokenAfter.balanceOf(msg.sender);
        comptrollerAfter.claimComp(msg.sender, toClaimAfter);
        uint256 balanceAfter1 = compTokenAfter.balanceOf(msg.sender);
        uint256 deltaAfter = balanceAfter1 - balanceAfter0;

        // Postcondition
        assert(deltaBefore == deltaAfter);
    }

    function testFaucet(uint8 marketIndex) public {
        // Preconditions
        uint256 index = marketIndex % marketsAfter.length;
        require(marketsBefore[index].isCToken());
        require(marketsAfter[index].isCToken());
        CErc20Interface cErc20Before = CErc20Interface(
            address(marketsBefore[index])
        );
        CErc20Interface cErc20After = CErc20Interface(
            address(marketsAfter[index])
        );
        address underlyingBefore = cErc20Before.underlying();
        address underlyingAfter = cErc20After.underlying();
        uint256 balanceBefore = EIP20NonStandardInterface(underlyingBefore)
            .balanceOf(msg.sender);
        uint256 balanceAfter = EIP20NonStandardInterface(underlyingAfter)
            .balanceOf(msg.sender);

        // Actions
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        Fauceteer(FAUCET_BEFORE_ADDR).drip(
            EIP20NonStandardInterface(underlyingBefore)
        );
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        Fauceteer(FAUCET_AFTER_ADDR).drip(
            EIP20NonStandardInterface(underlyingAfter)
        );

        // Postconditions
        assert(
            EIP20NonStandardInterface(underlyingBefore).balanceOf(msg.sender) >
                balanceBefore
        );
        assert(
            EIP20NonStandardInterface(underlyingAfter).balanceOf(msg.sender) >
                balanceAfter
        );
    }

    function testMint(uint8 marketIndex, uint256 mintAmount) public {
        // Preconditions
        require(mintAmount > 0);
        uint256 index = marketIndex % marketsAfter.length;
        require(marketsBefore[index].isCToken());
        require(marketsAfter[index].isCToken());
        CErc20Interface cErc20Before = CErc20Interface(
            address(marketsBefore[index])
        );
        CErc20Interface cErc20After = CErc20Interface(
            address(marketsAfter[index])
        );
        uint256 balanceBefore = CToken(address(cErc20Before)).balanceOf(msg.sender);
        uint256 balanceAfter = CToken(address(cErc20After)).balanceOf(msg.sender);
        address underlyingBefore = cErc20Before.underlying();
        address underlyingAfter = cErc20After.underlying();
        require(
            EIP20NonStandardInterface(underlyingBefore).balanceOf(msg.sender) >
                0
        );
        require(
            EIP20NonStandardInterface(underlyingAfter).balanceOf(msg.sender) > 0
        );

        // Actions
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        cErc20Before.mint(mintAmount);
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        cErc20After.mint(mintAmount);

        // Postconditions
        assert(CToken(address(cErc20Before)).balanceOf(msg.sender) > balanceBefore);
        assert(CToken(address(cErc20After)).balanceOf(msg.sender) > balanceAfter);
    }
}
