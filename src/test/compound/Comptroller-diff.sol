pragma solidity ^0.8.10;

import "./Setup.sol";
import "../../implementation/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../../implementation/compound/master-contracts/Reservoir.sol";
import {CErc20Immutable} from "../../implementation/compound/master-contracts/CErc20Immutable.sol";
import {SimplePriceOracle} from "../../implementation/compound/master-contracts/SimplePriceOracle.sol";
import {Fauceteer} from "../../implementation/compound/master-contracts/Fauceteer.sol";

contract ComptrollerDiffFuzz is Setup {
    event ObtainedUnderlying(address tokenAddr, string symbol, uint256 amount);
    event MintedCToken(
        address tokenAddr,
        string symbol,
        uint256 underlyingIn,
        uint256 amountOut
    );

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

    function testClaimComp() public {
        // Preconditions
        /// Drip COMP tokens to Comptrollers
        assert(address(Reservoir(RESERVOIR_BEFORE_ADDR).token()) == address(compTokenBefore));
        assert(compTokenBefore.balanceOf(RESERVOIR_BEFORE_ADDR) > 0);
        assert(address(Reservoir(RESERVOIR_AFTER_ADDR).token()) == address(compTokenAfter));
        assert(compTokenAfter.balanceOf(RESERVOIR_AFTER_ADDR) > 0);
        uint256 blocknumber = block.number >
            Reservoir(RESERVOIR_BEFORE_ADDR).dripStart()
            ? block.number
            : Reservoir(RESERVOIR_BEFORE_ADDR).dripStart();
        CheatCodes(HEVM_ADDRESS).roll(blocknumber + 100);
        Reservoir(RESERVOIR_BEFORE_ADDR).drip();
        Reservoir(RESERVOIR_AFTER_ADDR).drip();

        assert(compTokenBefore.balanceOf(address(comptrollerBefore)) > 0);
        assert(compTokenAfter.balanceOf(address(comptrollerAfter)) > 0);

        // Actions
        uint256 balanceBefore0 = compTokenBefore.balanceOf(msg.sender);
        comptrollerBefore.claimComp(msg.sender);
        uint256 balanceBefore1 = compTokenBefore.balanceOf(msg.sender);
        uint256 deltaBefore = balanceBefore1 - balanceBefore0;

        uint256 balanceAfter0 = compTokenAfter.balanceOf(msg.sender);
        comptrollerAfter.claimComp(msg.sender);
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
        emit ObtainedUnderlying(
            underlyingBefore,
            EIP20Interface(underlyingBefore).symbol(),
            EIP20Interface(underlyingBefore).balanceOf(msg.sender)
        );
        emit ObtainedUnderlying(
            underlyingAfter,
            EIP20Interface(underlyingAfter).symbol(),
            EIP20Interface(underlyingAfter).balanceOf(msg.sender)
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
        uint256 balanceBefore = CToken(address(cErc20Before)).balanceOf(
            msg.sender
        );
        uint256 balanceAfter = CToken(address(cErc20After)).balanceOf(
            msg.sender
        );
        address underlyingBefore = cErc20Before.underlying();
        address underlyingAfter = cErc20After.underlying();
        uint256 low = 1e16;
        uint256 high = EIP20Interface(underlyingBefore).balanceOf(msg.sender);
        require(EIP20Interface(underlyingBefore).balanceOf(msg.sender) > low);
        require(EIP20Interface(underlyingAfter).balanceOf(msg.sender) > low);
        uint256 actualMintAmount = _between(mintAmount, low, high);
        // Allowances
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        EIP20Interface(underlyingBefore).approve(
            address(cErc20Before),
            type(uint256).max
        );
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        EIP20Interface(underlyingAfter).approve(
            address(cErc20After),
            type(uint256).max
        );

        // Actions
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        uint256 err = cErc20Before.mint(actualMintAmount);
        assert(err == 0);
        emit MintedCToken(
            address(cErc20Before),
            CToken(address(cErc20Before)).symbol(),
            actualMintAmount,
            CToken(address(cErc20Before)).balanceOf(msg.sender)
        );

        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        err = cErc20After.mint(actualMintAmount);
        assert(err == 0);
        emit MintedCToken(
            address(cErc20After),
            CToken(address(cErc20After)).symbol(),
            actualMintAmount,
            CToken(address(cErc20After)).balanceOf(msg.sender)
        );

        // Postconditions
        assert(
            CToken(address(cErc20Before)).balanceOf(msg.sender) > balanceBefore
        );
        assert(
            CToken(address(cErc20After)).balanceOf(msg.sender) > balanceAfter
        );
        assert(
            CToken(address(cErc20After)).balanceOf(msg.sender) == CToken(address(cErc20Before)).balanceOf(msg.sender)
        );
    }

    function testRedeem(uint8 marketIndex, uint256 redeemAmount) public {
        require(redeemAmount > 0);
        uint256 index = marketIndex % marketsAfter.length;
        require(marketsBefore[index].isCToken());
        require(marketsAfter[index].isCToken());
        require(marketsBefore[index].balanceOf(msg.sender) > 0 && marketsAfter[index].balanceOf(msg.sender) > 0);
        require(marketsAfter[index].balanceOf(msg.sender) == marketsBefore[index].balanceOf(msg.sender));
        uint256 cTokenBalance = marketsAfter[index].balanceOf(msg.sender);
        CErc20Interface cErc20Before = CErc20Interface(
            address(marketsBefore[index])
        );
        CErc20Interface cErc20After = CErc20Interface(
            address(marketsAfter[index])
        );
        address underlyingBefore = cErc20Before.underlying();
        address underlyingAfter = cErc20After.underlying();
        uint256 balanceBefore = ERC20(underlyingBefore).balanceOf(
            msg.sender
        );
        uint256 balanceAfter = ERC20(underlyingAfter).balanceOf(
            msg.sender
        );
        uint256 actualRedeemAmount = _between(redeemAmount, 1, cTokenBalance);

        // Actions
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        uint256 err = cErc20Before.redeem(actualRedeemAmount);
        require(err == 0);

        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        err = cErc20After.redeem(actualRedeemAmount);
        require(err == 0);

        // Postconditions
        assert(
            ERC20(underlyingBefore).balanceOf(msg.sender) > balanceBefore
        );
        assert(
            ERC20(underlyingAfter).balanceOf(msg.sender) > balanceAfter
        );
        assert(
            ERC20(underlyingAfter).balanceOf(msg.sender) == ERC20(underlyingBefore).balanceOf(msg.sender)
        );
    }

    function testBorrow(uint8 marketIndex, uint256 borrowAmount) public {
        // Preconditions
        require(borrowAmount > 0);
        uint256 index = marketIndex % marketsAfter.length;
        require(marketsBefore[index].isCToken());
        require(marketsAfter[index].isCToken());
        require(marketsBefore[index].comptroller() == ComptrollerInterface(comptrollerBefore));
        require(marketsAfter[index].comptroller() == ComptrollerInterface(comptrollerAfter));
        CErc20Interface cErc20Before = CErc20Interface(
            address(marketsBefore[index])
        );
        CErc20Interface cErc20After = CErc20Interface(
            address(marketsAfter[index])
        );
        address underlyingBefore = cErc20Before.underlying();
        address underlyingAfter = cErc20After.underlying();
        uint256 balanceBefore = ERC20(underlyingBefore).balanceOf(
            msg.sender
        );
        uint256 balanceAfter = ERC20(underlyingAfter).balanceOf(
            msg.sender
        );

        // Actions
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        uint256 err = cErc20Before.borrow(borrowAmount);
        require(err == 0);

        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        err = cErc20After.borrow(borrowAmount);
        require(err == 0);

        // Postconditions
        assert(
            ERC20(underlyingBefore).balanceOf(msg.sender) > balanceBefore
        );
        assert(
            ERC20(underlyingAfter).balanceOf(msg.sender) > balanceAfter
        );
    }
}
