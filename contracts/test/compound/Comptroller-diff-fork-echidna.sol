pragma solidity ^0.8.10;

import "../helpers.sol";
import "../../implementation/compound/master-contracts/Comptroller.sol";
import "../../implementation/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../../implementation/compound/master-contracts/Reservoir.sol";
import {CErc20Immutable} from "../../implementation/compound/master-contracts/CErc20Immutable.sol";
import {SimplePriceOracle} from "../../implementation/compound/master-contracts/SimplePriceOracle.sol";
import {Fauceteer} from "../../implementation/compound/master-contracts/Fauceteer.sol";
import "../../implementation/compound/master-contracts/Unitroller.sol";

contract ComptrollerDiffFuzz {
    Comp compToken;
    CToken[] markets;
    Comptroller unitroller;
    uint forkId1;
    uint forkId2;

    address constant OLD_IMPL = 0x75442Ac771a7243433e033F3F8EaB2631e22938f;
    address constant NEW_IMPL = 0x374ABb8cE19A73f2c4EFAd642bda76c797f19233;
    address constant RESERVOIR = address(0x002775b1c75658be0f640272ccb8c72ac986009e38);

    event ObtainedUnderlying(address tokenAddr, string symbol, uint256 amount);
    event MintedCToken(
        address tokenAddr,
        string symbol,
        uint256 underlyingIn,
        uint256 amountOut
    );
    event ClaimCompDeltas(uint256 deltaBefore, uint256 deltaAfter);

    constructor() {
        compToken = Comp(0xc00e94Cb662C3520282E6f5717214004A7f26888);
        unitroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

        forkId1 = CheatCodes(HEVM_ADDRESS).createFork();
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        setAdmin(address(this));
        setImplementation(OLD_IMPL);

        forkId2 = CheatCodes(HEVM_ADDRESS).createFork();
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        setAdmin(address(this));
        setImplementation(NEW_IMPL);
    }

    function _between(uint val, uint low, uint high) internal pure returns (uint) {
        return low + (val % (high - low + 1));
    }

    function setAdmin(address _admin) internal {
        CheatCodes(HEVM_ADDRESS).store(
            address(unitroller),
            bytes32(0),
            bytes32(uint256(uint160(_admin)))
        );
    }

    function setImplementation(address _impl) internal {
        CheatCodes(HEVM_ADDRESS).store(
            address(unitroller),
            bytes32(uint256(2)),
            bytes32(uint256(uint160(_impl)))
        );
    }

    function testCompBalances() public {
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 balanceBefore = compToken.balanceOf(msg.sender);
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        uint256 balanceAfter = compToken.balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testCTokenBalances(uint8 marketIndex) public {
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 index = marketIndex % unitroller.getAllMarkets().length;
        uint256 balanceBefore = unitroller.getAllMarkets()[index].balanceOf(msg.sender);
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        uint256 balanceAfter = unitroller.getAllMarkets()[index].balanceOf(msg.sender);
        assert(balanceBefore == balanceAfter);
    }

    function testUpgrade() public {
        // Actions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 err = Unitroller(payable(address(unitroller)))
            ._setPendingImplementation(OLD_IMPL);
        require(err == 0);
        Comptroller(OLD_IMPL)._become(
            Unitroller(payable(address(unitroller)))
        );

        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        err = Unitroller(payable(address(unitroller)))
            ._setPendingImplementation(NEW_IMPL);
        require(err == 0);
        Comptroller(NEW_IMPL)._become(
            Unitroller(payable(address(unitroller)))
        );

        // Postconditions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        assert(
            unitroller.comptrollerImplementation() == OLD_IMPL
        );
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        assert(
            unitroller.comptrollerImplementation() == NEW_IMPL
        );
    }

    function testSupportExistingMarket(uint8 marketIndex) public {
        // Preconditions
        uint256 numMarkets = unitroller.getAllMarkets().length;
        uint256 index = marketIndex % numMarkets;
        CToken cErc20 = unitroller.getAllMarkets()[index];
        require(cErc20.isCToken());

        // Action
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 result1 = unitroller._supportMarket(cErc20);
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        uint256 result2 = unitroller._supportMarket(cErc20);

        // Postconditions
        assert(result1 > 0 && result2 > 0);
        assert(unitroller.getAllMarkets().length == numMarkets);
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        assert(unitroller.getAllMarkets().length == numMarkets);
    }

    function testCompSpeeds(uint8 marketIndex, uint256 newSpeed) public {
        // Preconditions
        uint256 actualNewSpeed = _between(newSpeed, 1, 300) * 1e15;
        uint256 index = marketIndex % unitroller.getAllMarkets().length;

        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        // Actions
        (bool success1, ) = address(unitroller).call(
            abi.encodeWithSignature(
                "_setCompSpeed(address,uint256)",
                address(markets[index]),
                actualNewSpeed
            )
        );

        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        CToken[] memory cTokens = new CToken[](1);
        cTokens[0] = markets[index];
        uint[] memory compSpeeds = new uint[](1);
        compSpeeds[0] = actualNewSpeed;
        unitroller._setCompSpeeds(cTokens, compSpeeds, compSpeeds);

        // Postconditions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        assert(unitroller.compSpeeds(address(unitroller.getAllMarkets()[index])) == actualNewSpeed);
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        assert(unitroller.compSupplySpeeds(address(unitroller.getAllMarkets()[index])) == actualNewSpeed);
        assert(unitroller.compBorrowSpeeds(address(unitroller.getAllMarkets()[index])) == actualNewSpeed);
    }

    function testClaimComp() public {
        // Preconditions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        Reservoir(RESERVOIR).drip();
        assert(compToken.balanceOf(address(unitroller)) > 0);
        markets = unitroller.getAllMarkets();
        for (uint256 i = 0; i < markets.length; i++) {
            assert(
                unitroller.mintAllowed(
                    address(markets[i]),
                    msg.sender,
                    0
                ) == 0
            );
        }
        require(unitroller.compAccrued(msg.sender) > 0);

        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        Reservoir(RESERVOIR).drip();
        assert(compToken.balanceOf(address(unitroller)) > 0);
        markets = unitroller.getAllMarkets();
        for (uint256 i = 0; i < markets.length; i++) {
            assert(
                unitroller.mintAllowed(
                    address(markets[i]),
                    msg.sender,
                    0
                ) == 0
            );
        }
        require(unitroller.compAccrued(msg.sender) > 0);

        // Actions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 balanceBefore0 = compToken.balanceOf(msg.sender);
        unitroller.claimComp(msg.sender);
        uint256 balanceBefore1 = compToken.balanceOf(msg.sender);
        uint256 deltaBefore = balanceBefore1 - balanceBefore0;

        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        uint256 balanceAfter0 = compToken.balanceOf(msg.sender);
        unitroller.claimComp(msg.sender);
        uint256 balanceAfter1 = compToken.balanceOf(msg.sender);
        uint256 deltaAfter = balanceAfter1 - balanceAfter0;

        emit ClaimCompDeltas(deltaBefore, deltaAfter);

        // Postcondition
        // assert(deltaBefore == deltaAfter);
        assert(balanceBefore1 > balanceBefore0);
        assert(balanceAfter1 > balanceAfter0);
    }

    function testMint(uint8 marketIndex, uint256 mintAmount) public {
        // Preconditions
        require(mintAmount > 0);
        markets = unitroller.getAllMarkets();
        uint256 index = marketIndex % markets.length;
        require(markets[index].isCToken());
        CErc20Interface cErc20 = CErc20Interface(
            address(markets[index])
        );
        address underlying = cErc20.underlying();

        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 balanceBefore = CToken(address(cErc20)).balanceOf(
            msg.sender
        );
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        uint256 balanceAfter = CToken(address(cErc20)).balanceOf(
            msg.sender
        );

        uint256 low = 1e16;
        uint256 high = EIP20Interface(underlying).balanceOf(msg.sender);

        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        require(EIP20Interface(underlying).balanceOf(msg.sender) > low);
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        require(EIP20Interface(underlying).balanceOf(msg.sender) > low);

        uint256 actualMintAmount = _between(mintAmount, low, high);

        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        require(
            unitroller.mintAllowed(
                address(cErc20),
                msg.sender,
                actualMintAmount
            ) == 0
        );
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        EIP20Interface(underlying).approve(
            address(cErc20),
            type(uint256).max
        );
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        require(
            unitroller.mintAllowed(
                address(cErc20),
                msg.sender,
                actualMintAmount
            ) == 0
        );
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        EIP20Interface(underlying).approve(
            address(cErc20),
            type(uint256).max
        );

        // Actions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        uint256 err = cErc20.mint(actualMintAmount);
        assert(err == 0);

        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
        err = cErc20.mint(actualMintAmount);
        assert(err == 0);

        // Postconditions
        CheatCodes(HEVM_ADDRESS).selectFork(forkId1);
        uint256 newBalanceBefore = CToken(address(cErc20)).balanceOf(msg.sender);
        assert(
            newBalanceBefore > balanceBefore
        );
        CheatCodes(HEVM_ADDRESS).selectFork(forkId2);
        uint256 newBalanceAfter = CToken(address(cErc20)).balanceOf(msg.sender);
        assert(
            newBalanceAfter > balanceAfter
        );
        assert(
            newBalanceBefore == newBalanceAfter
        );
    }

//    function testRedeem(uint8 marketIndex, uint256 redeemAmount) public {
//        require(redeemAmount > 0);
//        uint256 index = marketIndex % marketsAfter.length;
//        require(marketsBefore[index].isCToken());
//        require(marketsAfter[index].isCToken());
//        require(
//            marketsBefore[index].balanceOf(msg.sender) > 0 &&
//                marketsAfter[index].balanceOf(msg.sender) > 0
//        );
//        require(
//            marketsAfter[index].balanceOf(msg.sender) ==
//                marketsBefore[index].balanceOf(msg.sender)
//        );
//        uint256 cTokenBalance = marketsAfter[index].balanceOf(msg.sender);
//        CErc20Interface cErc20Before = CErc20Interface(
//            address(marketsBefore[index])
//        );
//        CErc20Interface cErc20After = CErc20Interface(
//            address(marketsAfter[index])
//        );
//        address underlyingBefore = cErc20Before.underlying();
//        address underlyingAfter = cErc20After.underlying();
//        uint256 balanceBefore = ERC20(underlyingBefore).balanceOf(msg.sender);
//        uint256 balanceAfter = ERC20(underlyingAfter).balanceOf(msg.sender);
//        uint256 actualRedeemAmount = _between(redeemAmount, 1e8, cTokenBalance);
//        require(
//            comptrollerBefore.redeemAllowed(
//                address(cErc20Before),
//                msg.sender,
//                actualRedeemAmount
//            ) == 0
//        );
//        require(
//            comptrollerAfter.redeemAllowed(
//                address(cErc20After),
//                msg.sender,
//                actualRedeemAmount
//            ) == 0
//        );
//
//        // Actions
//        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
//        uint256 err = cErc20Before.redeem(actualRedeemAmount);
//        require(err == 0);
//
//        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
//        err = cErc20After.redeem(actualRedeemAmount);
//        require(err == 0);
//
//        // Postconditions
//        assert(ERC20(underlyingBefore).balanceOf(msg.sender) > balanceBefore);
//        assert(ERC20(underlyingAfter).balanceOf(msg.sender) > balanceAfter);
//        assert(
//            ERC20(underlyingAfter).balanceOf(msg.sender) ==
//                ERC20(underlyingBefore).balanceOf(msg.sender)
//        );
//    }
//
//    function testBorrow(uint8 marketIndex, uint256 borrowAmount) public {
//        // Preconditions
//        require(borrowAmount > 0);
//        uint256 index = marketIndex % marketsAfter.length;
//        require(marketsBefore[index].isCToken());
//        require(marketsAfter[index].isCToken());
//        require(
//            marketsBefore[index].comptroller() ==
//                ComptrollerInterface(comptrollerBefore)
//        );
//        require(
//            marketsAfter[index].comptroller() ==
//                ComptrollerInterface(comptrollerAfter)
//        );
//        CErc20Interface cErc20Before = CErc20Interface(
//            address(marketsBefore[index])
//        );
//        CErc20Interface cErc20After = CErc20Interface(
//            address(marketsAfter[index])
//        );
//        address underlyingBefore = cErc20Before.underlying();
//        address underlyingAfter = cErc20After.underlying();
//        uint256 balanceBefore = ERC20(underlyingBefore).balanceOf(msg.sender);
//        uint256 balanceAfter = ERC20(underlyingAfter).balanceOf(msg.sender);
//
//        // Actions
//        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
//        uint256 err = cErc20Before.borrow(borrowAmount);
//        require(err == 0);
//
//        CheatCodes(HEVM_ADDRESS).prank(msg.sender);
//        err = cErc20After.borrow(borrowAmount);
//        require(err == 0);
//
//        // Postconditions
//        assert(ERC20(underlyingBefore).balanceOf(msg.sender) > balanceBefore);
//        assert(ERC20(underlyingAfter).balanceOf(msg.sender) > balanceAfter);
//    }
}
