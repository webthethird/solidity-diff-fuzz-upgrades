// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.5.16;

import { Comptroller as Comptroller_V1 } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/src/implementation/compound/Comptroller-before/contracts/Comptroller.sol";
import { Comptroller as Comptroller_V2 } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/src/implementation/compound/Comptroller-after/contracts/Comptroller.sol";
import { Unitroller } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/src/implementation/compound/Comptroller-after/contracts/Unitroller.sol";
import { CErc20 } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/src/implementation/compound/Comptroller-after/contracts/CErc20.sol";
import { Comp } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/src/implementation/compound/Comptroller-after/contracts/Governance/Comp.sol";

interface IComptrollerV1 {
    function getAssetsIn(address) external returns (address[] memory);
    function checkMembership(address,address) external returns (bool);
    function enterMarkets(address[] calldata) external returns (uint256[] memory);
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
    function claimComp(address,address[] calldata) external;
    function claimComp(address[] calldata,address[] calldata,bool,bool) external;
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
    function allMarkets(uint256) external returns (address[] memory);
    function compRate() external returns (uint256);
    function compSpeeds(address) external returns (uint256);
    function compSupplyState(address) external returns (uint224,uint32);
    function compBorrowState(address) external returns (uint224,uint32);
    function compSupplierIndex(address,address) external returns (uint256);
    function compBorrowerIndex(address,address) external returns (uint256);
    function compAccrued(address) external returns (uint256);
    function borrowCapGuardian() external returns (address);
    function borrowCaps(address) external returns (uint256);
    function compContributorSpeeds(address) external returns (uint256);
    function lastContributorBlock(address) external returns (uint256);
    function isComptroller() external returns (bool);
    function compInitialIndex() external returns (uint224);
}

interface IComptrollerV2 {
    function getAssetsIn(address) external returns (address[] memory);
    function checkMembership(address,address) external returns (bool);
    function enterMarkets(address[] calldata) external returns (uint256[] memory);
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
    function claimComp(address,address[] calldata) external;
    function claimComp(address[] calldata,address[] calldata,bool,bool) external;
    function _grantComp(address,uint256) external;
    function _setCompSpeeds(address[] calldata,uint256[] calldata,uint256[] calldata) external;
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
    function allMarkets(uint256) external returns (address[] memory);
    function compRate() external returns (uint256);
    function compSpeeds(address) external returns (uint256);
    function compSupplyState(address) external returns (uint224,uint32);
    function compBorrowState(address) external returns (uint224,uint32);
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
}

interface ICErc20 {
    function initialize(address,address,uint256,string calldata,string calldata,uint8) external;
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
    function initialize(address,address,address,uint256,string calldata,string calldata,uint8) external;
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
    function numCheckpoints(address) external returns (uint32);
    function DOMAIN_TYPEHASH() external returns (bytes32);
    function DELEGATION_TYPEHASH() external returns (bytes32);
    function nonces(address) external returns (uint256);
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
    IComptrollerV1 ComptrollerV1;
    IComptrollerV2 ComptrollerV2;
    IUnitroller UnitrollerV1;
    IUnitroller UnitrollerV2;
    ICErc20 CErc20V1;
    ICErc20 CErc20V2;
    IComp CompV1;
    IComp CompV2;

    constructor() public {
        ComptrollerV1 = IComptrollerV1(address(new Comptroller_V1()));
        ComptrollerV2 = IComptrollerV2(address(new Comptroller_V2()));
        UnitrollerV1 = IUnitroller(address(new Unitroller()));
        UnitrollerV2 = IUnitroller(address(new Unitroller()));
        hevm.store(
            address(UnitrollerV1),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(ComptrollerV1))))
        );
        hevm.store(
            address(UnitrollerV2),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(ComptrollerV2))))
        );
        CErc20V1 = ICErc20(address(new CErc20()));
        CErc20V2 = ICErc20(address(new CErc20()));
        CompV1 = IComp(address(new Comp()));
        CompV2 = IComp(address(new Comp()));
    }


    /*** Modified Functions ***/ 

    function Comptroller__supportMarket(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._supportMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._supportMarket.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__become(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._become.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._become.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }


    /*** Tainted Functions ***/ 

    function Comptroller_checkMembership(address a, address b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.checkMembership.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.checkMembership.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_exitMarket(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.exitMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.exitMarket.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_mintAllowed(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.mintAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.mintAllowed.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_redeemAllowed(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.redeemAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.redeemAllowed.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_borrowAllowed(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.borrowAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.borrowAllowed.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_repayBorrowAllowed(address a, address b, address c, uint256 d) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_liquidateBorrowAllowed(address a, address b, address c, address d, uint256 e) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_seizeAllowed(address a, address b, address c, address d, uint256 e) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.seizeAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.seizeAllowed.selector, a, b, c, d, e
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_transferAllowed(address a, address b, address c, uint256 d) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.transferAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.transferAllowed.selector, a, b, c, d
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setPriceOracle(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setPriceOracle.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setPriceOracle.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setCloseFactor(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setCloseFactor.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setCloseFactor.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setCollateralFactor(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setCollateralFactor.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setCollateralFactor.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setLiquidationIncentive(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setLiquidationIncentive.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setLiquidationIncentive.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setMarketBorrowCaps(address[] memory a, uint256[] memory b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setMarketBorrowCaps.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setMarketBorrowCaps.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setBorrowCapGuardian(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setBorrowCapGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setBorrowCapGuardian.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setPauseGuardian(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setPauseGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setPauseGuardian.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setMintPaused(address a, bool b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setMintPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setMintPaused.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setBorrowPaused(address a, bool b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setBorrowPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setBorrowPaused.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setTransferPaused(bool a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setTransferPaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setTransferPaused.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setSeizePaused(bool a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setSeizePaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setSeizePaused.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_updateContributorRewards(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.updateContributorRewards.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.updateContributorRewards.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_claimComp(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.claimComp.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_claimComp(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.claimComp.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_getAllMarkets() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.getAllMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.getAllMarkets.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_isDeprecated(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.isDeprecated.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.isDeprecated.selector, a
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
    function Comptroller__setCompSpeeds(address[] memory a, uint256[] memory b, uint256[] memory c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setCompSpeeds.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setCompSpeed.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }


    /*** Tainted Variables ***/ 

    function Comptroller_admin() public {
        assert(ComptrollerV1.admin() == ComptrollerV2.admin());
    }

    function Comptroller_comptrollerImplementation() public {
        assert(ComptrollerV1.comptrollerImplementation() == ComptrollerV2.comptrollerImplementation());
    }

    function Comptroller_markets(address a) public {
        assert(ComptrollerV1.markets(a) == ComptrollerV2.markets(a));
    }

    function Comptroller_allMarkets(uint i) public {
        assert(ComptrollerV1.allMarkets[i] == ComptrollerV2.allMarkets[i]);
    }

    function Comptroller_compSpeeds(address a) public {
        assert(ComptrollerV1.compSpeeds(a) == ComptrollerV2.compSpeeds(a));
    }

    function Comptroller_compSupplyState(address a) public {
        assert(ComptrollerV1.compSupplyState(a) == ComptrollerV2.compSupplyState(a));
    }

    function Comptroller_compBorrowState(address a) public {
        assert(ComptrollerV1.compBorrowState(a) == ComptrollerV2.compBorrowState(a));
    }

    function Comptroller_compSupplierIndex(address a) public {
        assert(ComptrollerV1.compSupplierIndex(a) == ComptrollerV2.compSupplierIndex(a));
    }

    function Comptroller_compBorrowerIndex(address a) public {
        assert(ComptrollerV1.compBorrowerIndex(a) == ComptrollerV2.compBorrowerIndex(a));
    }

    function Comptroller_compAccrued(address a) public {
        assert(ComptrollerV1.compAccrued(a) == ComptrollerV2.compAccrued(a));
    }


    /*** Additional Targets ***/ 

    function CErc20_initialize(address a, address b, uint256 c, string memory d, string memory e, uint8 f) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.initialize.selector, a, b, c, d, e, f
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.initialize.selector, a, b, c, d, e, f
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_transfer(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.transfer.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.transfer.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_transferFrom(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.transferFrom.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.transferFrom.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_approve(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.approve.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.approve.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_allowance(address a, address b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.allowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.allowance.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_balanceOf(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.balanceOf.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_balanceOfUnderlying(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.balanceOfUnderlying.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.balanceOfUnderlying.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_getAccountSnapshot(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.getAccountSnapshot.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.getAccountSnapshot.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrowRatePerBlock() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.borrowRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.borrowRatePerBlock.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_supplyRatePerBlock() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.supplyRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.supplyRatePerBlock.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_totalBorrowsCurrent() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.totalBorrowsCurrent.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.totalBorrowsCurrent.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrowBalanceCurrent(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.borrowBalanceCurrent.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.borrowBalanceCurrent.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrowBalanceStored(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.borrowBalanceStored.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.borrowBalanceStored.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_exchangeRateCurrent() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.exchangeRateCurrent.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.exchangeRateCurrent.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_exchangeRateStored() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.exchangeRateStored.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.exchangeRateStored.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_getCash() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.getCash.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.getCash.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_accrueInterest() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.accrueInterest.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.accrueInterest.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_seize(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.seize.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.seize.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setPendingAdmin(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._setPendingAdmin.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._setPendingAdmin.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__acceptAdmin() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._acceptAdmin.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._acceptAdmin.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setComptroller(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._setComptroller.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._setComptroller.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setReserveFactor(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._setReserveFactor.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._setReserveFactor.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__reduceReserves(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._reduceReserves.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._reduceReserves.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__setInterestRateModel(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._setInterestRateModel.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._setInterestRateModel.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_initialize(address a, address b, address c, uint256 d, string memory e, string memory f, uint8 g) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.initialize.selector, a, b, c, d, e, f, g
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.initialize.selector, a, b, c, d, e, f, g
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_mint(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.mint.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.mint.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_redeem(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.redeem.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.redeem.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_redeemUnderlying(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.redeemUnderlying.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.redeemUnderlying.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_borrow(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.borrow.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.borrow.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_repayBorrow(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.repayBorrow.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.repayBorrow.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_repayBorrowBehalf(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.repayBorrowBehalf.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.repayBorrowBehalf.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_liquidateBorrow(address a, uint256 b, address c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.liquidateBorrow.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.liquidateBorrow.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_sweepToken(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2.sweepToken.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1.sweepToken.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__addReserves(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._addReserves.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._addReserves.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20__delegateCompLikeTo(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CErc20V2).call(
            abi.encodeWithSelector(
                CErc20V2._delegateCompLikeTo.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CErc20V1).call(
            abi.encodeWithSelector(
                CErc20V1._delegateCompLikeTo.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_allowance(address a, address b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.allowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.allowance.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_approve(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.approve.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.approve.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_balanceOf(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.balanceOf.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_transfer(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.transfer.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.transfer.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_transferFrom(address a, address b, uint256 c) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.transferFrom.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.transferFrom.selector, a, b, c
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_delegate(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.delegate.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.delegate.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_delegateBySig(address a, uint256 b, uint256 c, uint8 d, bytes32 e, bytes32 f) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.delegateBySig.selector, a, b, c, d, e, f
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.delegateBySig.selector, a, b, c, d, e, f
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_getCurrentVotes(address a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.getCurrentVotes.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.getCurrentVotes.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comp_getPriorVotes(address a, uint256 b) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CompV2).call(
            abi.encodeWithSelector(
                CompV2.getPriorVotes.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CompV1).call(
            abi.encodeWithSelector(
                CompV1.getPriorVotes.selector, a, b
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

}
