// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.10;

import { ComptrollerHarness as Comptroller_V1 } from "./simplified-compound/ComptrollerV1.sol";
import { ComptrollerHarness as Comptroller_V2 } from "./simplified-compound/ComptrollerV2.sol";
import { Unitroller } from "./simplified-compound/Unitroller.sol";
import { CErc20 } from "./simplified-compound/CErc20.sol";
import { Comp } from "./simplified-compound/Comp.sol";

interface IComptrollerV1 {
    function getAssetsIn(address) external returns (address[] memory);
    function checkMembership(address,address) external returns (bool);
    function enterMarkets(address[] memory) external returns (uint256[] memory);
    function exitMarket(address) external returns (uint256);
    function mintAllowed(address,address,uint256) external returns (uint256);
    function mintVerify(address,address,uint256,uint256) external;
    function redeemAllowed(address,address,uint256) external returns (uint256);
    function redeemVerify(address,address,uint256,uint256) external;
    function borrowAllowed(address,address,uint256) external returns (uint256);
    function borrowVerify(address,address,uint256) external;
    function repayBorrowAllowed(address,address,address,uint256) external returns (uint256);
    function repayBorrowVerify(address,address,address,uint256,uint256) external;
    function liquidateBorrowAllowed(address,address,address,address,uint256) external returns (uint256);
    function liquidateBorrowVerify(address,address,address,address,uint256,uint256) external;
    function seizeAllowed(address,address,address,address,uint256) external returns (uint256);
    function seizeVerify(address,address,address,address,uint256) external;
    function transferAllowed(address,address,address,uint256) external returns (uint256);
    function transferVerify(address,address,address,uint256) external;
    function getAccountLiquidity(address) external returns (uint256);
    function getHypotheticalAccountLiquidity(address,address,uint256,uint256) external returns (uint256);
    function liquidateCalculateSeizeTokens(address,address,uint256) external returns (uint256);
    function _setPriceOracle(address) external returns (uint256);
    function _setCloseFactor(uint256) external returns (uint256);
    function _setCollateralFactor(address,uint256) external returns (uint256);
    function _setLiquidationIncentive(uint256) external returns (uint256);
    function _supportMarket(address) external returns (uint256);
    function _setMarketBorrowCaps(address[] calldata,uint256[] calldata) external;
    function _setBorrowCapGuardian(address) external;
    function _setPauseGuardian(address) external returns (uint256);
    function _setMintPaused(address,bool) external returns (bool);
    function _setBorrowPaused(address,bool) external returns (bool);
    function _setTransferPaused(bool) external returns (bool);
    function _setSeizePaused(bool) external returns (bool);
    function _become(address) external;
    function updateContributorRewards(address) external;
    function claimComp(address) external;
//    function claimComp(address,address[] memory) external;
//    function claimComp(address[] memory,address[] memory,bool,bool) external;
    function _grantComp(address,uint256) external;
    function _setCompSpeed(address,uint256) external;
    function _setContributorCompSpeed(address,uint256) external;
    function getAllMarkets() external returns (address[] memory);
    function isDeprecated(address) external returns (bool);
    function getBlockNumber() external returns (uint256);
    function getCompAddress() external returns (address);
    function admin() external returns (address);
    function pendingAdmin() external returns (address);
    function comptrollerImplementation() external returns (address);
    function pendingComptrollerImplementation() external returns (address);
    function oracle() external returns (address);
    function closeFactorMantissa() external returns (uint256);
    function liquidationIncentiveMantissa() external returns (uint256);
    function maxAssets() external returns (uint256);
    function accountAssets(address,uint256) external returns (address[] memory);
    function pauseGuardian() external returns (address);
    function _mintGuardianPaused() external returns (bool);
    function _borrowGuardianPaused() external returns (bool);
    function transferGuardianPaused() external returns (bool);
    function seizeGuardianPaused() external returns (bool);
    function mintGuardianPaused(address) external returns (bool);
    function borrowGuardianPaused(address) external returns (bool);
    function markets(address) external returns (Market memory);
    function allMarkets(uint256) external returns (address[] memory);
    function compRate() external returns (uint256);
    function compSpeeds(address) external returns (uint256);
    function compSupplyState(address) external returns (CompMarketState memory);
    function compBorrowState(address) external returns (CompMarketState memory);
    function compSupplierIndex(address,address) external returns (uint256);
    function compBorrowerIndex(address,address) external returns (uint256);
    function compAccrued(address) external returns (uint256);
    function borrowCapGuardian() external returns (address);
    function borrowCaps(address) external returns (uint256);
    function compContributorSpeeds(address) external returns (uint256);
    function lastContributorBlock(address) external returns (uint256);
    function isComptroller() external returns (bool);
    function compInitialIndex() external returns (uint224);
    function setCompAddress(address) external;
}

struct CompMarketState {
    uint224 index;
    uint32 block;
}

struct Market {
        bool isListed;
        uint collateralFactorMantissa;
//        mapping(address => bool) accountMembership;
        bool isComped;
    }

interface IComptrollerV2 {
    function getAssetsIn(address) external returns (address[] memory);
    function checkMembership(address,address) external returns (bool);
    function enterMarkets(address[] memory) external returns (uint256[] memory);
    function exitMarket(address) external returns (uint256);
    function mintAllowed(address,address,uint256) external returns (uint256);
    function mintVerify(address,address,uint256,uint256) external;
    function redeemAllowed(address,address,uint256) external returns (uint256);
    function redeemVerify(address,address,uint256,uint256) external;
    function borrowAllowed(address,address,uint256) external returns (uint256);
    function borrowVerify(address,address,uint256) external;
    function repayBorrowAllowed(address,address,address,uint256) external returns (uint256);
    function repayBorrowVerify(address,address,address,uint256,uint256) external;
    function liquidateBorrowAllowed(address,address,address,address,uint256) external returns (uint256);
    function liquidateBorrowVerify(address,address,address,address,uint256,uint256) external;
    function seizeAllowed(address,address,address,address,uint256) external returns (uint256);
    function seizeVerify(address,address,address,address,uint256) external;
    function transferAllowed(address,address,address,uint256) external returns (uint256);
    function transferVerify(address,address,address,uint256) external;
    function getAccountLiquidity(address) external returns (uint256);
    function getHypotheticalAccountLiquidity(address,address,uint256,uint256) external returns (uint256);
    function liquidateCalculateSeizeTokens(address,address,uint256) external returns (uint256);
    function _setPriceOracle(address) external returns (uint256);
    function _setCloseFactor(uint256) external returns (uint256);
    function _setCollateralFactor(address,uint256) external returns (uint256);
    function _setLiquidationIncentive(uint256) external returns (uint256);
    function _supportMarket(address) external returns (uint256);
    function _setMarketBorrowCaps(address[] calldata,uint256[] calldata) external;
    function _setBorrowCapGuardian(address) external;
    function _setPauseGuardian(address) external returns (uint256);
    function _setMintPaused(address,bool) external returns (bool);
    function _setBorrowPaused(address,bool) external returns (bool);
    function _setTransferPaused(bool) external returns (bool);
    function _setSeizePaused(bool) external returns (bool);
    function _become(address) external;
    function _upgradeSplitCompRewards() external;
    function updateContributorRewards(address) external;
    function claimComp(address) external;
//    function claimComp(address,address[] memory) external;
//    function claimComp(address[] memory,address[] memory,bool,bool) external;
    function _grantComp(address,uint256) external;
    function _setCompSpeeds(address[] memory,uint256[] memory,uint256[] memory) external;
    function _setContributorCompSpeed(address,uint256) external;
    function getAllMarkets() external returns (address[] memory);
    function isDeprecated(address) external returns (bool);
    function getBlockNumber() external returns (uint256);
    function getCompAddress() external returns (address);
    function admin() external returns (address);
    function pendingAdmin() external returns (address);
    function comptrollerImplementation() external returns (address);
    function pendingComptrollerImplementation() external returns (address);
    function oracle() external returns (address);
    function closeFactorMantissa() external returns (uint256);
    function liquidationIncentiveMantissa() external returns (uint256);
    function maxAssets() external returns (uint256);
    function accountAssets(address,uint256) external returns (address[] memory);
    function pauseGuardian() external returns (address);
    function _mintGuardianPaused() external returns (bool);
    function _borrowGuardianPaused() external returns (bool);
    function transferGuardianPaused() external returns (bool);
    function seizeGuardianPaused() external returns (bool);
    function mintGuardianPaused(address) external returns (bool);
    function borrowGuardianPaused(address) external returns (bool);
    function markets(address) external returns (Market memory);
    function allMarkets(uint256) external returns (address[] memory);
    function compRate() external returns (uint256);
    function compSpeeds(address) external returns (uint256);
    function compSupplyState(address) external returns (CompMarketState memory);
    function compBorrowState(address) external returns (CompMarketState memory);
    function compSupplierIndex(address,address) external returns (uint256);
    function compBorrowerIndex(address,address) external returns (uint256);
    function compAccrued(address) external returns (uint256);
    function borrowCapGuardian() external returns (address);
    function borrowCaps(address) external returns (uint256);
    function compContributorSpeeds(address) external returns (uint256);
    function lastContributorBlock(address) external returns (uint256);
    function compBorrowSpeeds(address) external returns (uint256);
    function compSupplySpeeds(address) external returns (uint256);
    function isComptroller() external returns (bool);
    function compInitialIndex() external returns (uint224);
    function setCompAddress(address) external;
}

interface ICErc20 {
//    function initialize(address,address,uint256,string memory,string memory,uint8) external;
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function approve(address,uint256) external returns (bool);
    function allowance(address,address) external returns (uint256);
    function balanceOf(address) external returns (uint256);
    function balanceOfUnderlying(address) external returns (uint256);
    function getAccountSnapshot(address) external returns (uint256);
    function borrowRatePerBlock() external returns (uint256);
    function supplyRatePerBlock() external returns (uint256);
    function totalBorrowsCurrent() external returns (uint256);
    function borrowBalanceCurrent(address) external returns (uint256);
    function borrowBalanceStored(address) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function exchangeRateStored() external returns (uint256);
    function getCash() external returns (uint256);
    function accrueInterest() external returns (uint256);
    function seize(address,address,uint256) external returns (uint256);
    function _setPendingAdmin(address) external returns (uint256);
    function _acceptAdmin() external returns (uint256);
    function _setComptroller(address) external returns (uint256);
    function _setReserveFactor(uint256) external returns (uint256);
    function _reduceReserves(uint256) external returns (uint256);
    function _setInterestRateModel(address) external returns (uint256);
    function initialize(address,address,address,uint256,string memory,string memory,uint8) external;
    function mint(uint256) external returns (uint256);
    function redeem(uint256) external returns (uint256);
    function redeemUnderlying(uint256) external returns (uint256);
    function borrow(uint256) external returns (uint256);
    function repayBorrow(uint256) external returns (uint256);
    function repayBorrowBehalf(address,uint256) external returns (uint256);
    function liquidateBorrow(address,uint256,address) external returns (uint256);
    function sweepToken(address) external;
    function _addReserves(uint256) external returns (uint256);
    function _delegateCompLikeTo(address) external;
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);
    function admin() external returns (address);
    function pendingAdmin() external returns (address);
    function comptroller() external returns (address);
    function interestRateModel() external returns (address);
    function reserveFactorMantissa() external returns (uint256);
    function accrualBlockNumber() external returns (uint256);
    function borrowIndex() external returns (uint256);
    function totalBorrows() external returns (uint256);
    function totalReserves() external returns (uint256);
    function totalSupply() external returns (uint256);
    function protocolSeizeShareMantissa() external returns (uint256);
    function isCToken() external returns (bool);
    function NO_ERROR() external returns (uint256);
    function underlying() external returns (address);
}

interface IComp {
    function allowance(address,address) external returns (uint256);
    function approve(address,uint256) external returns (bool);
    function balanceOf(address) external returns (uint256);
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function delegate(address) external;
    function delegateBySig(address,uint256,uint256,uint8,bytes32,bytes32) external;
    function getCurrentVotes(address) external returns (uint96);
    function getPriorVotes(address,uint256) external returns (uint96);
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);
    function totalSupply() external returns (uint256);
    function delegates(address) external returns (address);
    function checkpoints(address,uint32) external returns (Checkpoint memory);
    function numCheckpoints(address) external returns (uint32);
    function DOMAIN_TYPEHASH() external returns (bytes32);
    function DELEGATION_TYPEHASH() external returns (bytes32);
    function nonces(address) external returns (uint256);
}

struct Checkpoint {
    uint32 fromBlock;
    uint96 votes;
}

interface IUnitroller {
    function _setPendingImplementation(address) external returns (uint256);
    function _acceptImplementation() external returns (uint256);
    function _setPendingAdmin(address) external returns (uint256);
    function _acceptAdmin() external returns (uint256);
    function admin() external returns (address);
    function pendingAdmin() external returns (address);
    function comptrollerImplementation() external returns (address);
    function pendingComptrollerImplementation() external returns (address);
}

interface IHevm {
    function warp(uint256 newTimestamp) external;
    function roll(uint256 newNumber) external;
    function load(address where, bytes32 slot) external returns (bytes32);
    function store(address where, bytes32 slot, bytes32 value) external;
    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 r, bytes32 v, bytes32 s);
    function addr(uint256 privateKey) external returns (address add);
    function ffi(string[] calldata inputs) external returns (bytes memory result);
    function prank(address newSender) external;
}

contract DiffFuzzUpgrades {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // TODO: Deploy the contracts and put their addresses below
    IComptrollerV1 comptrollerV1;
    IComptrollerV2 comptrollerV2;
    IUnitroller unitrollerV1;
    IUnitroller unitrollerV2;
    ICErc20 cErc20V1;
    ICErc20 cErc20V2;
    IComp compV1;
    IComp compV2;

    constructor() public {
        comptrollerV1 = IComptrollerV1(address(new Comptroller_V1()));
        comptrollerV2 = IComptrollerV2(address(new Comptroller_V2()));
        unitrollerV1 = IUnitroller(address(new Unitroller()));
        unitrollerV2 = IUnitroller(address(new Unitroller()));
        // Store the implementation addresses in the proxy.
        hevm.store(
            address(unitrollerV1),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(comptrollerV1))))
        );
        hevm.store(
            address(unitrollerV2),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(comptrollerV1))))
        );
        cErc20V1 = ICErc20(address(new CErc20()));
        cErc20V2 = ICErc20(address(new CErc20()));
//        compV1 = IComp(address(new Comp()));
//        compV2 = IComp(address(new Comp()));
    }

    /*** Upgrade Function ***/ 

    function upgradeV2() external virtual {
        hevm.store(
            address(unitrollerV2),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(comptrollerV2))))
        );
    }


    /*** Modified Functions ***/ 

    function Comptroller__supportMarket(address a) public virtual {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._supportMarket.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(comptrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._supportMarket.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__become(address a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._become.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._become.selector, a
            )
        );
        assert(success1 == success2);
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }


    /*** Tainted Functions ***/ 

    function Comptroller_checkMembership(address a, address b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.checkMembership.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.checkMembership.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_exitMarket(address a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.exitMarket.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.exitMarket.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_mintAllowed(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.mintAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.mintAllowed.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_redeemAllowed(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.redeemAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.redeemAllowed.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_borrowAllowed(address a, address b, uint256 c) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.borrowAllowed.selector, a, b, c
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.borrowAllowed.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_repayBorrowAllowed(address a, address b, address c, uint256 d) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_liquidateBorrowAllowed(address a, address b, address c, address d, uint256 e) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_seizeAllowed(address a, address b, address c, address d, uint256 e) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.seizeAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.seizeAllowed.selector, a, b, c, d, e
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_transferAllowed(address a, address b, address c, uint256 d) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.transferAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.transferAllowed.selector, a, b, c, d
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setPriceOracle(address a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setPriceOracle.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setPriceOracle.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setCloseFactor(uint256 a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setCloseFactor.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setCloseFactor.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setCollateralFactor(address a, uint256 b) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setCollateralFactor.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setCollateralFactor.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setLiquidationIncentive(uint256 a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setLiquidationIncentive.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setLiquidationIncentive.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setMarketBorrowCaps(address[] calldata a, uint256[] calldata b) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setMarketBorrowCaps.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setMarketBorrowCaps.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setBorrowCapGuardian(address a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setBorrowCapGuardian.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setBorrowCapGuardian.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setPauseGuardian(address a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setPauseGuardian.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setPauseGuardian.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setMintPaused(address a, bool b) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setMintPaused.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setMintPaused.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setBorrowPaused(address a, bool b) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setBorrowPaused.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setBorrowPaused.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setTransferPaused(bool a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setTransferPaused.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setTransferPaused.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setSeizePaused(bool a) public {
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2._setSeizePaused.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setSeizePaused.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_updateContributorRewards(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.updateContributorRewards.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.updateContributorRewards.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_claimComp(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.claimComp.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

//    function Comptroller_claimComp(address[] memory a, address[] memory b, bool c, bool d) public {
//        hevm.prank(msg.sender);
//        (bool success2, bytes memory output2) = address(unitrollerV2).call(
//            abi.encodeWithSelector(
//                comptrollerV2.claimComp.selector, a, b, c, d
//            )
//        );
//        hevm.prank(msg.sender);
//        (bool success1, bytes memory output1) = address(unitrollerV1).call(
//            abi.encodeWithSelector(
//                comptrollerV1.claimComp.selector, a, b, c, d
//            )
//        );
//        assert(success1 == success2);
//        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
//    }

    function Comptroller_getAllMarkets() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.getAllMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.getAllMarkets.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_isDeprecated(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV2.isDeprecated.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1.isDeprecated.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }


    /*** New Functions ***/ 

    // TODO: Double-check this function for correctness
    // Comptroller._setCompSpeeds(CToken[],uint256[],uint256[])
    // is a new function, which appears to replace a function with a similar name,
    // Comptroller._setCompSpeed(CToken,uint256).
    // If these functions have different arguments, this function may be incorrect.
//    function Comptroller__setCompSpeeds(address[] memory a, uint256[] memory b, uint256[] memory c) public {
//        (bool success2, bytes memory output2) = address(unitrollerV2).call(
//            abi.encodeWithSelector(
//                comptrollerV2._setCompSpeeds.selector, a, b, c
//            )
//        );
//        (bool success1, bytes memory output1) = address(unitrollerV1).call(
//            abi.encodeWithSelector(
//                comptrollerV1._setCompSpeed.selector, a, b
//            )
//        );
//        assert(success1 == success2);
//        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
//    }


    /*** Tainted Variables ***/ 

//    function Comptroller_admin() public {
//        assert(comptrollerV1.admin() == comptrollerV2.admin());
//    }
//
//    function Comptroller_comptrollerImplementation() public {
//        assert(comptrollerV1.comptrollerImplementation() == comptrollerV2.comptrollerImplementation());
//    }
//
//    function Comptroller_oracle() public {
//        assert(comptrollerV1.oracle() == comptrollerV2.oracle());
//    }
//
//    function Comptroller_closeFactorMantissa() public {
//        assert(comptrollerV1.closeFactorMantissa() == comptrollerV2.closeFactorMantissa());
//    }
//
//    function Comptroller_liquidationIncentiveMantissa() public {
//        assert(comptrollerV1.liquidationIncentiveMantissa() == comptrollerV2.liquidationIncentiveMantissa());
//    }
//
//    function Comptroller_accountAssets(address a) public {
//        assert(comptrollerV1.accountAssets(a) == comptrollerV2.accountAssets(a));
//    }
//
//    function Comptroller_markets(address a) public {
//        assert(comptrollerV1.markets(a) == comptrollerV2.markets(a));
//    }

//    function Comptroller_pauseGuardian() public {
//        assert(comptrollerV1.pauseGuardian() == comptrollerV2.pauseGuardian());
//    }
//
//    function Comptroller_transferGuardianPaused() public {
//        assert(comptrollerV1.transferGuardianPaused() == comptrollerV2.transferGuardianPaused());
//    }
//
//    function Comptroller_seizeGuardianPaused() public {
//        assert(comptrollerV1.seizeGuardianPaused() == comptrollerV2.seizeGuardianPaused());
//    }
//
//    function Comptroller_mintGuardianPaused(address a) public {
//        assert(comptrollerV1.mintGuardianPaused(a) == comptrollerV2.mintGuardianPaused(a));
//    }
//
//    function Comptroller_borrowGuardianPaused(address a) public {
//        assert(comptrollerV1.borrowGuardianPaused(a) == comptrollerV2.borrowGuardianPaused(a));
//    }
//
//    function Comptroller_allMarkets(uint i) public {
//        assert(comptrollerV1.allMarkets(i) == comptrollerV2.allMarkets(i));
//    }
//
//    function Comptroller_compSpeeds(address a) public {
//        assert(comptrollerV1.compSpeeds(a) == comptrollerV2.compSpeeds(a));
//    }
//
//    function Comptroller_compSupplyState(address a) public {
//        assert(comptrollerV1.compSupplyState(a) == comptrollerV2.compSupplyState(a));
//    }
//
//    function Comptroller_compBorrowState(address a) public {
//        assert(comptrollerV1.compBorrowState(a) == comptrollerV2.compBorrowState(a));
//    }
//
//    function Comptroller_compSupplierIndex(address a) public {
//        assert(comptrollerV1.compSupplierIndex(a) == comptrollerV2.compSupplierIndex(a));
//    }
//
//    function Comptroller_compBorrowerIndex(address a) public {
//        assert(comptrollerV1.compBorrowerIndex(a) == comptrollerV2.compBorrowerIndex(a));
//    }

    function Comptroller_compAccrued(address a) public {
        assert(comptrollerV1.compAccrued(a) == comptrollerV2.compAccrued(a));
    }

//    function Comptroller_borrowCapGuardian() public {
//        assert(comptrollerV1.borrowCapGuardian() == comptrollerV2.borrowCapGuardian());
//    }
//
//    function Comptroller_borrowCaps(address a) public {
//        assert(comptrollerV1.borrowCaps(a) == comptrollerV2.borrowCaps(a));
//    }
//
//    function Comptroller_compContributorSpeeds(address a) public {
//        assert(comptrollerV1.compContributorSpeeds(a) == comptrollerV2.compContributorSpeeds(a));
//    }
//
//    function Comptroller_lastContributorBlock(address a) public {
//        assert(comptrollerV1.lastContributorBlock(a) == comptrollerV2.lastContributorBlock(a));
//    }


    /*** Additional Targets ***/ 

//    function CErc20_initialize(address a, address b, uint256 c, string memory d, string memory e, uint8 f) public {
//        (bool success2, bytes memory output2) = address(cErc20V2).call(
//            abi.encodeWithSelector(
//                cErc20V2.initialize.selector, a, b, c, d, e, f
//            )
//        );
//        (bool success1, bytes memory output1) = address(cErc20V1).call(
//            abi.encodeWithSelector(
//                cErc20V1.initialize.selector, a, b, c, d, e, f
//            )
//        );
//        assert(success1 == success2);
//        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
//    }

    function CErc20_transfer(address a, uint256 b) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.transfer.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.transfer.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_transferFrom(address a, address b, uint256 c) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.transferFrom.selector, a, b, c
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.transferFrom.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_approve(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.approve.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.approve.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_allowance(address a, address b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.allowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.allowance.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_balanceOf(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.balanceOf.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_balanceOfUnderlying(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.balanceOfUnderlying.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.balanceOfUnderlying.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_getAccountSnapshot(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.getAccountSnapshot.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.getAccountSnapshot.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrowRatePerBlock() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.borrowRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.borrowRatePerBlock.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_supplyRatePerBlock() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.supplyRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.supplyRatePerBlock.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_totalBorrowsCurrent() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.totalBorrowsCurrent.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.totalBorrowsCurrent.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrowBalanceCurrent(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.borrowBalanceCurrent.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.borrowBalanceCurrent.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrowBalanceStored(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.borrowBalanceStored.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.borrowBalanceStored.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_exchangeRateCurrent() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.exchangeRateCurrent.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.exchangeRateCurrent.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_exchangeRateStored() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.exchangeRateStored.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.exchangeRateStored.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_getCash() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.getCash.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.getCash.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_accrueInterest() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.accrueInterest.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.accrueInterest.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_seize(address a, address b, uint256 c) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.seize.selector, a, b, c
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.seize.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setPendingAdmin(address a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._setPendingAdmin.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._setPendingAdmin.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__acceptAdmin() public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._acceptAdmin.selector
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._acceptAdmin.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setComptroller(address a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._setComptroller.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._setComptroller.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setReserveFactor(uint256 a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._setReserveFactor.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._setReserveFactor.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__reduceReserves(uint256 a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._reduceReserves.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._reduceReserves.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setInterestRateModel(address a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._setInterestRateModel.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._setInterestRateModel.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_initialize(address a, address b, address c, uint256 d, string memory e, string memory f, uint8 g) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.initialize.selector, a, b, c, d, e, f, g
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.initialize.selector, a, b, c, d, e, f, g
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_mint(uint256 a) public virtual {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.mint.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.mint.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_redeem(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.redeem.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.redeem.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_redeemUnderlying(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.redeemUnderlying.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.redeemUnderlying.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrow(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.borrow.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.borrow.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_repayBorrow(uint256 a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.repayBorrow.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.repayBorrow.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_repayBorrowBehalf(address a, uint256 b) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.repayBorrowBehalf.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.repayBorrowBehalf.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_liquidateBorrow(address a, uint256 b, address c) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.liquidateBorrow.selector, a, b, c
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.liquidateBorrow.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_sweepToken(address a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2.sweepToken.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1.sweepToken.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__addReserves(uint256 a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._addReserves.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._addReserves.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__delegateCompLikeTo(address a) public {
        (bool success2, bytes memory output2) = address(cErc20V2).call(
            abi.encodeWithSelector(
                cErc20V2._delegateCompLikeTo.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(cErc20V1).call(
            abi.encodeWithSelector(
                cErc20V1._delegateCompLikeTo.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_allowance(address a, address b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.allowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.allowance.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_approve(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.approve.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.approve.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_balanceOf(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.balanceOf.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_transfer(address a, uint256 b) public {
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.transfer.selector, a, b
            )
        );
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.transfer.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_transferFrom(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.transferFrom.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.transferFrom.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_delegate(address a) public {
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.delegate.selector, a
            )
        );
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.delegate.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_delegateBySig(address a, uint256 b, uint256 c, uint8 d, bytes32 e, bytes32 f) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.delegateBySig.selector, a, b, c, d, e, f
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.delegateBySig.selector, a, b, c, d, e, f
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_getCurrentVotes(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.getCurrentVotes.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.getCurrentVotes.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_getPriorVotes(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(compV2).call(
            abi.encodeWithSelector(
                compV2.getPriorVotes.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(compV1).call(
            abi.encodeWithSelector(
                compV1.getPriorVotes.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

}
