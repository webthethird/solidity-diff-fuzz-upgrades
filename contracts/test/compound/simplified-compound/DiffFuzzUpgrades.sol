// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.10;

import { SimpleComptroller as SimpleComptroller_V1 } from "./SimpleComptrollerV1.sol";
import { SimpleComptrollerV2 as SimpleComptrollerV2_V2 } from "./SimpleComptrollerV2.sol";
import { SimpleUnitroller } from "./SimpleUnitroller.sol";
import { SimpleCErc20 } from "./SimpleCErc20.sol";
import { SimpleComp } from "./SimpleComp.sol";
import { SimpleCToken } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/contracts/test/compound/simplified-compound/SimpleCToken.sol";
import { PriceOracle } from "/home/webthethird/Ethereum/solidity-diff-fuzz-upgrades/contracts/test/compound/simplified-compound/PriceOracle.sol";

interface ISimpleComptrollerV1 {
    enum Error { NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY }
    enum FailureInfo { ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK }
    struct Exp {
        uint256 mantissa;
    }
    struct Double {
        uint256 mantissa;
    }
    struct Market {
        bool isListed;
        uint256 collateralFactorMantissa;
        mapping(address => bool) accountMembership;
        bool isComped;
    }
    struct CompMarketState {
        uint224 index;
        uint32 block;
    }
    function admin() external returns (address);
    function compAddress() external returns (address);
    function comptrollerImplementation() external returns (address);
    function pendingComptrollerImplementation() external returns (address);
    function oracle() external returns (address);
    function maxAssets() external returns (uint256);
    function accountAssets(address,uint256) external returns (address);
    // function markets(address) external returns (Market memory);
    function allMarkets(uint256) external returns (address);
    function compRate() external returns (uint256);
    function compSpeeds(address) external returns (uint256);
    function compSupplyState(address) external returns (CompMarketState memory);
    function compSupplierIndex(address,address) external returns (uint256);
    function compAccrued(address) external returns (uint256);
    function isComptroller() external returns (bool);
    function compInitialIndex() external returns (uint224);
    function getAssetsIn(address) external view returns (address[] memory);
    function checkMembership(address,address) external view returns (bool);
    function enterMarkets(address[] memory) external returns (uint256[] memory);
    function mintAllowed(address,address,uint256) external returns (uint256);
    function redeemAllowed(address,address,uint256) external returns (uint256);
    function redeemVerify(address,address,uint256,uint256) external;
    function _setPriceOracle(address) external returns (uint256);
    function _setCollateralFactor(address,uint256) external returns (uint256);
    function _supportMarket(address) external returns (uint256);
    function _become(address) external;
    function claimComp() external;
    function _grantComp(address,uint256) external;
    function _setCompSpeed(address,uint256) external;
    function getAllMarkets() external view returns (address[] memory);
    function isDeprecated(address) external view returns (bool);
    function getBlockNumber() external view returns (uint256);
    function getCompAddress() external view returns (address);
}

interface ISimpleComptrollerV2V2 {
    enum Error { NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY }
    enum FailureInfo { ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK }
    struct Exp {
        uint256 mantissa;
    }
    struct Double {
        uint256 mantissa;
    }
    struct Market {
        bool isListed;
        uint256 collateralFactorMantissa;
        mapping(address => bool) accountMembership;
        bool isComped;
    }
    struct CompMarketState {
        uint224 index;
        uint32 block;
    }
    function admin() external returns (address);
    function compAddress() external returns (address);
    function comptrollerImplementation() external returns (address);
    function pendingComptrollerImplementation() external returns (address);
    function oracle() external returns (address);
    function maxAssets() external returns (uint256);
    function accountAssets(address,uint256) external returns (address);
    // function markets(address) external returns (Market memory);
    function allMarkets(uint256) external returns (address);
    function compRate() external returns (uint256);
    function compSpeeds(address) external returns (uint256);
    function compSupplyState(address) external returns (CompMarketState memory);
    function compSupplierIndex(address,address) external returns (uint256);
    function compAccrued(address) external returns (uint256);
    function isComptroller() external returns (bool);
    function compInitialIndex() external returns (uint224);
    function getAssetsIn(address) external view returns (address[] memory);
    function checkMembership(address,address) external view returns (bool);
    function enterMarkets(address[] memory) external returns (uint256[] memory);
    function mintAllowed(address,address,uint256) external returns (uint256);
    function redeemAllowed(address,address,uint256) external returns (uint256);
    function redeemVerify(address,address,uint256,uint256) external;
    function _setPriceOracle(address) external returns (uint256);
    function _setCollateralFactor(address,uint256) external returns (uint256);
    function _supportMarket(address) external returns (uint256);
    function _become(address) external;
    function _upgradeSplitCompRewards() external;
    function claimComp() external;
    function _grantComp(address,uint256) external;
    function _setCompSpeed(address,uint256) external;
    function getAllMarkets() external view returns (address[] memory);
    function isDeprecated(address) external view returns (bool);
    function getBlockNumber() external view returns (uint256);
    function getCompAddress() external view returns (address);
}

interface ISimpleCErc20 {
    struct Exp {
        uint256 mantissa;
    }
    struct Double {
        uint256 mantissa;
    }
    function NO_ERROR() external returns (uint256);
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);
    function admin() external returns (address);
    function comptroller() external returns (address);
    function interestRateModel() external returns (address);
    function reserveFactorMantissa() external returns (uint256);
    function accrualBlockNumber() external returns (uint256);
    function borrowIndex() external returns (uint256);
    function totalBorrows() external returns (uint256);
    function totalReserves() external returns (uint256);
    function totalSupply() external returns (uint256);
    function isCToken() external returns (bool);
    function underlying() external returns (address);
    // function initialize(address,address,uint256,string memory,string memory,uint8) external;
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function approve(address,uint256) external returns (bool);
    function allowance(address,address) external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function balanceOfUnderlying(address) external returns (uint256);
    function supplyRatePerBlock() external view returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function getCash() external view returns (uint256);
    function accrueInterest() external returns (uint256);
    function _setAdmin(address) external returns (uint256);
    function _setComptroller(address) external returns (uint256);
    function _setReserveFactor(uint256) external returns (uint256);
    function initialize(address,address,address,uint256,string memory,string memory,uint8) external;
    function mint(uint256) external returns (uint256);
    function redeem(uint256) external returns (uint256);
    function redeemUnderlying(uint256) external returns (uint256);
}

interface ISimpleComp {
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);
    function totalSupply() external returns (uint256);
    function allowance(address,address) external view returns (uint256);
    function approve(address,uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
}

interface ISimpleCToken {
    struct Exp {
        uint256 mantissa;
    }
    struct Double {
        uint256 mantissa;
    }
    function NO_ERROR() external returns (uint256);
    function name() external returns (string memory);
    function symbol() external returns (string memory);
    function decimals() external returns (uint8);
    function admin() external returns (address);
    function comptroller() external returns (address);
    function interestRateModel() external returns (address);
    function reserveFactorMantissa() external returns (uint256);
    function accrualBlockNumber() external returns (uint256);
    function borrowIndex() external returns (uint256);
    function totalBorrows() external returns (uint256);
    function totalReserves() external returns (uint256);
    function totalSupply() external returns (uint256);
    function isCToken() external returns (bool);
    function initialize(address,address,uint256,string memory,string memory,uint8) external;
    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function approve(address,uint256) external returns (bool);
    function allowance(address,address) external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function balanceOfUnderlying(address) external returns (uint256);
    function supplyRatePerBlock() external view returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function getCash() external view returns (uint256);
    function accrueInterest() external returns (uint256);
    function _setAdmin(address) external returns (uint256);
    function _setComptroller(address) external returns (uint256);
    function _setReserveFactor(uint256) external returns (uint256);
}

interface IPriceOracle {
    function isPriceOracle() external returns (bool);
    function getUnderlyingPrice(address) external view returns (uint256);
}

interface ISimpleUnitroller {
    enum Error { NO_ERROR, UNAUTHORIZED, COMPTROLLER_MISMATCH, INSUFFICIENT_SHORTFALL, INSUFFICIENT_LIQUIDITY, INVALID_CLOSE_FACTOR, INVALID_COLLATERAL_FACTOR, INVALID_LIQUIDATION_INCENTIVE, MARKET_NOT_ENTERED, MARKET_NOT_LISTED, MARKET_ALREADY_LISTED, MATH_ERROR, NONZERO_BORROW_BALANCE, PRICE_ERROR, REJECTION, SNAPSHOT_ERROR, TOO_MANY_ASSETS, TOO_MUCH_REPAY }
    enum FailureInfo { ACCEPT_ADMIN_PENDING_ADMIN_CHECK, ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, EXIT_MARKET_BALANCE_OWED, EXIT_MARKET_REJECTION, SET_CLOSE_FACTOR_OWNER_CHECK, SET_CLOSE_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_OWNER_CHECK, SET_COLLATERAL_FACTOR_NO_EXISTS, SET_COLLATERAL_FACTOR_VALIDATION, SET_COLLATERAL_FACTOR_WITHOUT_PRICE, SET_IMPLEMENTATION_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_OWNER_CHECK, SET_LIQUIDATION_INCENTIVE_VALIDATION, SET_MAX_ASSETS_OWNER_CHECK, SET_PENDING_ADMIN_OWNER_CHECK, SET_PENDING_IMPLEMENTATION_OWNER_CHECK, SET_PRICE_ORACLE_OWNER_CHECK, SUPPORT_MARKET_EXISTS, SUPPORT_MARKET_OWNER_CHECK, SET_PAUSE_GUARDIAN_OWNER_CHECK }
    function admin() external returns (address);
    function compAddress() external returns (address);
    function comptrollerImplementation() external returns (address);
    function pendingComptrollerImplementation() external returns (address);
    function _setPendingImplementation(address) external returns (uint256);
    function _acceptImplementation() external returns (uint256);
    function _setAdmin(address) external returns (uint256);
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
    ISimpleComptrollerV1 simpleComptrollerV1;
    ISimpleComptrollerV2V2 simpleComptrollerV2V2;
    ISimpleUnitroller simpleUnitrollerV1;
    ISimpleUnitroller simpleUnitrollerV2;
    ISimpleCErc20 simpleCErc20V1;
    ISimpleCErc20 simpleCErc20V2;
    ISimpleComp simpleCompV1;
    ISimpleComp simpleCompV2;
    ISimpleCToken simpleCTokenV1;
    ISimpleCToken simpleCTokenV2;
    IPriceOracle priceOracleV1;
    IPriceOracle priceOracleV2;

    constructor() public {
        simpleComptrollerV1 = ISimpleComptrollerV1(address(new SimpleComptroller_V1()));
        simpleComptrollerV2V2 = ISimpleComptrollerV2V2(address(new SimpleComptrollerV2_V2()));
        simpleUnitrollerV1 = ISimpleUnitroller(address(new SimpleUnitroller()));
        simpleUnitrollerV2 = ISimpleUnitroller(address(new SimpleUnitroller()));
        // Store the implementation addresses in the proxy.
        hevm.store(
            address(simpleUnitrollerV1),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(simpleComptrollerV1))))
        );
        hevm.store(
            address(simpleUnitrollerV2),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(simpleComptrollerV1))))
        );
        simpleCErc20V1 = ISimpleCErc20(address(new SimpleCErc20()));
        simpleCErc20V2 = ISimpleCErc20(address(new SimpleCErc20()));
        // simpleCompV1 = ISimpleComp(address(new SimpleComp()));
        // simpleCompV2 = ISimpleComp(address(new SimpleComp()));
        // simpleCTokenV1 = ISimpleCToken(address(new SimpleCToken()));
        // simpleCTokenV2 = ISimpleCToken(address(new SimpleCToken()));
        // priceOracleV1 = IPriceOracle(address(new PriceOracle()));
        // priceOracleV2 = IPriceOracle(address(new PriceOracle()));
    }

    /*** Upgrade Function ***/ 

    function upgradeV2() external virtual {
        hevm.store(
            address(simpleUnitrollerV2),
            bytes32(uint(2)),
            bytes32(uint256(uint160(address(simpleComptrollerV2V2))))
        );
    }


    /*** Modified Functions ***/ 

    function SimpleComptrollerV2__supportMarket(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2._supportMarket.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1._supportMarket.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2__become(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2._become.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1._become.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Tainted Functions ***/ 

    function SimpleComptrollerV2_checkMembership(address a, address b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2.checkMembership.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1.checkMembership.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2_mintAllowed(address a, address b, uint256 c) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2.mintAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1.mintAllowed.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2_redeemAllowed(address a, address b, uint256 c) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2.redeemAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1.redeemAllowed.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2__setPriceOracle(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2._setPriceOracle.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1._setPriceOracle.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2__setCollateralFactor(address a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2._setCollateralFactor.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1._setCollateralFactor.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2_claimComp() public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2.claimComp.selector
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1.claimComp.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2_getAllMarkets() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2.getAllMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1.getAllMarkets.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComptrollerV2_isDeprecated(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleComptrollerV2V2.isDeprecated.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleComptrollerV1.isDeprecated.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** New Functions ***/ 


    /*** Tainted Variables ***/ 

    function SimpleComptroller_admin() public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).admin() == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).admin());
    }

    function SimpleComptroller_comptrollerImplementation() public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).comptrollerImplementation() == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).comptrollerImplementation());
    }

    function SimpleComptroller_oracle() public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).oracle() == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).oracle());
    }

    // function SimpleComptroller_accountAssets(address a) public {
    //     assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).accountAssets(a) == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).accountAssets(a));
    // }

    // function SimpleComptroller_markets(address a) public {
    //     assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).markets(a) == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).markets(a));
    // }

    function SimpleComptroller_allMarkets(uint i) public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).allMarkets(i) == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).allMarkets(i));
    }

    function SimpleComptroller_compSpeeds(address a) public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).compSpeeds(a) == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).compSpeeds(a));
    }

    function SimpleComptroller_compSupplyState(address a) public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).compSupplyState(a).index == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).compSupplyState(a).index);
    }

    function SimpleComptroller_compSupplierIndex(address a) public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).compSupplierIndex(a, msg.sender) == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).compSupplierIndex(a, msg.sender));
    }

    function SimpleComptroller_compAccrued(address a) public {
        assert(ISimpleComptrollerV1(address(simpleUnitrollerV1)).compAccrued(a) == ISimpleComptrollerV2V2(address(simpleUnitrollerV2)).compAccrued(a));
    }


    /*** Tainted External Contracts ***/ 

    function SimpleCToken_balanceOf(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCTokenV2).call(
            abi.encodeWithSelector(
                simpleCTokenV2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCTokenV1).call(
            abi.encodeWithSelector(
                simpleCTokenV1.balanceOf.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCToken_accrueInterest() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCTokenV2).call(
            abi.encodeWithSelector(
                simpleCTokenV2.accrueInterest.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCTokenV1).call(
            abi.encodeWithSelector(
                simpleCTokenV1.accrueInterest.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCToken_initialize(address a, address b, uint256 c, string memory d, string memory e, uint8 f) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleCTokenV2).call(
            abi.encodeWithSelector(
                simpleCTokenV2.initialize.selector, a, b, c, d, e, f
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleCTokenV1).call(
            abi.encodeWithSelector(
                simpleCTokenV1.initialize.selector, a, b, c, d, e, f
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCToken_supplyRatePerBlock() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCTokenV2).call(
            abi.encodeWithSelector(
                simpleCTokenV2.supplyRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCTokenV1).call(
            abi.encodeWithSelector(
                simpleCTokenV1.supplyRatePerBlock.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleUnitroller__acceptImplementation() public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleUnitrollerV2._acceptImplementation.selector
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleUnitrollerV1._acceptImplementation.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleUnitroller__setPendingImplementation(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleUnitrollerV2._setPendingImplementation.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleUnitrollerV1._setPendingImplementation.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleUnitroller__setAdmin(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleUnitrollerV2).call(
            abi.encodeWithSelector(
                simpleUnitrollerV2._setAdmin.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleUnitrollerV1).call(
            abi.encodeWithSelector(
                simpleUnitrollerV1._setAdmin.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function PriceOracle_getUnderlyingPrice(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(priceOracleV2).call(
            abi.encodeWithSelector(
                priceOracleV2.getUnderlyingPrice.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(priceOracleV1).call(
            abi.encodeWithSelector(
                priceOracleV1.getUnderlyingPrice.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComp_transfer(address a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleCompV2).call(
            abi.encodeWithSelector(
                simpleCompV2.transfer.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleCompV1).call(
            abi.encodeWithSelector(
                simpleCompV1.transfer.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleComp_balanceOf(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCompV2).call(
            abi.encodeWithSelector(
                simpleCompV2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCompV1).call(
            abi.encodeWithSelector(
                simpleCompV1.balanceOf.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Additional Targets ***/ 

    // function SimpleCErc20_initialize(address a, address b, uint256 c, string memory d, string memory e, uint8 f) public virtual {
    //     (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
    //         abi.encodeWithSelector(
    //             simpleCErc20V2.initialize.selector, a, b, c, d, e, f
    //         )
    //     );
    //     (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
    //         abi.encodeWithSelector(
    //             simpleCErc20V1.initialize.selector, a, b, c, d, e, f
    //         )
    //     );
    //     assert(successV1 == successV2); 
    //     assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    // }

    function SimpleCErc20_transfer(address a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.transfer.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.transfer.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_balanceOf(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.balanceOf.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_supplyRatePerBlock() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.supplyRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.supplyRatePerBlock.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_accrueInterest() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.accrueInterest.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.accrueInterest.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20__setAdmin(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2._setAdmin.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1._setAdmin.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_initialize(address a, address b, address c, uint256 d, string memory e, string memory f, uint8 g) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.initialize.selector, a, b, c, d, e, f, g
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.initialize.selector, a, b, c, d, e, f, g
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_mint(uint256 a) public virtual {
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.mint.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.mint.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_redeem(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.redeem.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.redeem.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function SimpleCErc20_redeemUnderlying(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simpleCErc20V2).call(
            abi.encodeWithSelector(
                simpleCErc20V2.redeemUnderlying.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simpleCErc20V1).call(
            abi.encodeWithSelector(
                simpleCErc20V1.redeemUnderlying.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

}
