// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.11;

import { Safemoon as Safemoon_V1 } from "./SafemoonV2.sol";
import { Safemoon as Safemoon_V2 } from "./SafemoonV3.sol";
import { TransparentUpgradeableProxy } from "./TransparentUpgradeableProxy.sol";

interface ISafemoonV1 {
    struct FeeTier {
        uint256 ecoSystemFee;
        uint256 liquidityFee;
        uint256 taxFee;
        uint256 ownerFee;
        uint256 burnFee;
        address ecoSystem;
        address owner;
    }
    struct FeeValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tEchoSystem;
        uint256 tLiquidity;
        uint256 tFee;
        uint256 tOwner;
        uint256 tBurn;
    }
    struct tFeeValues {
        uint256 tTransferAmount;
        uint256 tEchoSystem;
        uint256 tLiquidity;
        uint256 tFee;
        uint256 tOwner;
        uint256 tBurn;
    }
    function _defaultFees() external returns (FeeTier memory);
    function uniswapV2Router() external returns (address);
    function uniswapV2Pair() external returns (address);
    function WBNB() external returns (address);
    function _burnAddress() external returns (address);
    function swapAndLiquifyEnabled() external returns (bool);
    function _maxTxAmount() external returns (uint256);
    function numTokensToCollectBNB() external returns (uint256);
    function numOfBnbToSwapAndEvolve() external returns (uint256);
    function swapAndEvolveEnabled() external returns (bool);
    function listIgnoreCollectBNBAddresses(address) external returns (bool);
    function bridgeBurnAddress() external returns (address);
    function whitelistMint(address) external returns (bool);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function transferOwnership(address) external;
    function initialize() external;
    function initRouterAndPair(address) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address,uint256) external returns (bool);
    function allowance(address,address) external view returns (uint256);
    function approve(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function increaseAllowance(address,uint256) external returns (bool);
    function decreaseAllowance(address,uint256) external returns (bool);
    function isExcludedFromReward(address) external view returns (bool);
    function totalFees() external view returns (uint256);
    function reflectionFromTokenInTiers(uint256,uint256,bool) external view returns (uint256);
    function reflectionFromToken(uint256,bool) external view returns (uint256);
    function tokenFromReflection(uint256) external view returns (uint256);
    function excludeFromReward(address) external;
    function includeInReward(address) external;
    function excludeFromFee(address) external;
    function includeInFee(address) external;
    function whitelistAddress(address,uint256) external;
    function excludeWhitelistedAddress(address) external;
    function accountTier(address) external view returns (FeeTier memory);
    function isWhitelisted(address) external view returns (bool);
    function setEcoSystemFeePercent(uint256,uint256) external;
    function setLiquidityFeePercent(uint256,uint256) external;
    function setTaxFeePercent(uint256,uint256) external;
    function setOwnerFeePercent(uint256,uint256) external;
    function setBurnFeePercent(uint256,uint256) external;
    function setEcoSystemFeeAddress(uint256,address) external;
    function setOwnerFeeAddress(uint256,address) external;
    function addTier(uint256,uint256,uint256,uint256,uint256,address,address) external;
    function feeTier(uint256) external view returns (FeeTier memory);
    function blacklistAddress(address) external;
    function unBlacklistAddress(address) external;
    function updateRouterAndPair(address,address) external;
    function setDefaultSettings() external;
    function setMaxTxPercent(uint256) external;
    function setSwapAndEvolveEnabled(bool) external;
    function isExcludedFromFee(address) external view returns (bool);
    function isBlacklisted(address) external view returns (bool);
    function setRouter(address) external;
    function swapAndEvolve() external;
    function setMigrationAddress(address) external;
    function isMigrationStarted() external view returns (bool);
    function migrate(address,uint256) external;
    function feeTiersLength() external view returns (uint256);
    function updateBurnAddress(address) external;
    function withdrawToken(address,uint256) external;
    function setNumberOfTokenToCollectBNB(uint256) external;
    function setNumOfBnbToSwapAndEvolve(uint256) external;
    function getContractBalance() external view returns (uint256);
    function getBNBBalance() external view returns (uint256);
    function withdrawBnb(uint256) external;
    function addListIgnoreCollectBNBOnTransferAddresses(address[] calldata) external;
    function removeListIgnoreCollectBNBOnTransferAddresses(address[] calldata) external;
    function setBridgeBurnAddress(address) external;
    function setWhitelistBurn(address) external;
    function mint(address,uint256) external;
    function burn(uint256) external;
}

interface ISafemoonV2 {
    struct FeeTier {
        uint256 ecoSystemFee;
        uint256 liquidityFee;
        uint256 taxFee;
        uint256 ownerFee;
        uint256 burnFee;
        address ecoSystem;
        address owner;
    }
    struct FeeValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tEchoSystem;
        uint256 tLiquidity;
        uint256 tFee;
        uint256 tOwner;
        uint256 tBurn;
    }
    struct tFeeValues {
        uint256 tTransferAmount;
        uint256 tEchoSystem;
        uint256 tLiquidity;
        uint256 tFee;
        uint256 tOwner;
        uint256 tBurn;
    }
    function _defaultFees() external returns (FeeTier memory);
    function uniswapV2Router() external returns (address);
    function uniswapV2Pair() external returns (address);
    function WBNB() external returns (address);
    function _burnAddress() external returns (address);
    function swapAndLiquifyEnabled() external returns (bool);
    function _maxTxAmount() external returns (uint256);
    function numTokensToCollectBNB() external returns (uint256);
    function numOfBnbToSwapAndEvolve() external returns (uint256);
    function swapAndEvolveEnabled() external returns (bool);
    function listIgnoreCollectBNBAddresses(address) external returns (bool);
    function bridgeBurnAddress() external returns (address);
    function whitelistMint(address) external returns (bool);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function transferOwnership(address) external;
    function initialize() external;
    function initRouterAndPair(address) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address,uint256) external returns (bool);
    function allowance(address,address) external view returns (uint256);
    function approve(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function increaseAllowance(address,uint256) external returns (bool);
    function decreaseAllowance(address,uint256) external returns (bool);
    function isExcludedFromReward(address) external view returns (bool);
    function totalFees() external view returns (uint256);
    function reflectionFromTokenInTiers(uint256,uint256,bool) external view returns (uint256);
    function reflectionFromToken(uint256,bool) external view returns (uint256);
    function tokenFromReflection(uint256) external view returns (uint256);
    function excludeFromReward(address) external;
    function includeInReward(address) external;
    function excludeFromFee(address) external;
    function includeInFee(address) external;
    function whitelistAddress(address,uint256) external;
    function excludeWhitelistedAddress(address) external;
    function accountTier(address) external view returns (FeeTier memory);
    function isWhitelisted(address) external view returns (bool);
    function setEcoSystemFeePercent(uint256,uint256) external;
    function setLiquidityFeePercent(uint256,uint256) external;
    function setTaxFeePercent(uint256,uint256) external;
    function setOwnerFeePercent(uint256,uint256) external;
    function setBurnFeePercent(uint256,uint256) external;
    function setEcoSystemFeeAddress(uint256,address) external;
    function setOwnerFeeAddress(uint256,address) external;
    function addTier(uint256,uint256,uint256,uint256,uint256,address,address) external;
    function feeTier(uint256) external view returns (FeeTier memory);
    function blacklistAddress(address) external;
    function unBlacklistAddress(address) external;
    function updateRouterAndPair(address,address) external;
    function setDefaultSettings() external;
    function setMaxTxPercent(uint256) external;
    function setSwapAndEvolveEnabled(bool) external;
    function isExcludedFromFee(address) external view returns (bool);
    function isBlacklisted(address) external view returns (bool);
    function setRouter(address) external;
    function swapAndEvolve() external;
    function setMigrationAddress(address) external;
    function isMigrationStarted() external view returns (bool);
    function migrate(address,uint256) external;
    function feeTiersLength() external view returns (uint256);
    function updateBurnAddress(address) external;
    function withdrawToken(address,uint256) external;
    function setNumberOfTokenToCollectBNB(uint256) external;
    function setNumOfBnbToSwapAndEvolve(uint256) external;
    function getContractBalance() external view returns (uint256);
    function getBNBBalance() external view returns (uint256);
    function withdrawBnb(uint256) external;
    function addListIgnoreCollectBNBOnTransferAddresses(address[] calldata) external;
    function removeListIgnoreCollectBNBOnTransferAddresses(address[] calldata) external;
    function setBridgeBurnAddress(address) external;
    function setWhitelistMint(address) external;
    function mint(address,uint256) external;
    function burn(address,uint256) external;
}

interface ITransparentUpgradeableProxy {
    function admin() external returns (address);
    function implementation() external returns (address);
    function changeAdmin(address) external;
    function upgradeTo(address) external;
    function upgradeToAndCall(address,bytes calldata) external payable;
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
    ISafemoonV1 safemoonV1;
    ISafemoonV2 safemoonV2;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV1;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV2;

    constructor() public {
        safemoonV1 = ISafemoonV1(address(new Safemoon_V1()));
        safemoonV2 = ISafemoonV2(address(new Safemoon_V2()));
        transparentUpgradeableProxyV1 = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy(
            address(safemoonV1), address(this), ""
        )));
        transparentUpgradeableProxyV2 = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy(
            address(safemoonV1), address(this), ""
        )));
        // Store the implementation addresses in the proxy.
        // hevm.store(
        //     address(transparentUpgradeableProxyV1),
        //     bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
        //     bytes32(uint256(uint160(address(safemoonV1))))
        // );
        // hevm.store(
        //     address(transparentUpgradeableProxyV2),
        //     bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
        //     bytes32(uint256(uint160(address(safemoonV1))))
        // );
    }

    /*** Upgrade Function ***/ 

    function upgradeV2() external virtual {
        hevm.store(
            address(transparentUpgradeableProxyV2),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(safemoonV2))))
        );
    }


    /*** Modified Functions ***/ 


    /*** Tainted Functions ***/ 

    function Safemoon_initialize() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.initialize.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.initialize.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_balanceOf(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.balanceOf.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_transfer(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.transfer.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.transfer.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_transferFrom(address a, address b, uint256 c) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.transferFrom.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.transferFrom.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_totalFees() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.totalFees.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.totalFees.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_reflectionFromTokenInTiers(uint256 a, uint256 b, bool c) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.reflectionFromTokenInTiers.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.reflectionFromTokenInTiers.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_reflectionFromToken(uint256 a, bool b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.reflectionFromToken.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.reflectionFromToken.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_tokenFromReflection(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.tokenFromReflection.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.tokenFromReflection.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_excludeFromReward(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.excludeFromReward.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.excludeFromReward.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_includeInReward(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.includeInReward.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.includeInReward.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_whitelistAddress(address a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.whitelistAddress.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.whitelistAddress.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_accountTier(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.accountTier.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.accountTier.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setEcoSystemFeePercent(uint256 a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setEcoSystemFeePercent.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setEcoSystemFeePercent.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setLiquidityFeePercent(uint256 a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setLiquidityFeePercent.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setLiquidityFeePercent.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setTaxFeePercent(uint256 a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setTaxFeePercent.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setTaxFeePercent.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setOwnerFeePercent(uint256 a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setOwnerFeePercent.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setOwnerFeePercent.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setBurnFeePercent(uint256 a, uint256 b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setBurnFeePercent.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setBurnFeePercent.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setEcoSystemFeeAddress(uint256 a, address b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setEcoSystemFeeAddress.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setEcoSystemFeeAddress.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_setOwnerFeeAddress(uint256 a, address b) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.setOwnerFeeAddress.selector, a, b
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.setOwnerFeeAddress.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_addTier(uint256 a, uint256 b, uint256 c, uint256 d, uint256 e, address f, address g) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.addTier.selector, a, b, c, d, e, f, g
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.addTier.selector, a, b, c, d, e, f, g
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_feeTier(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.feeTier.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.feeTier.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_migrate(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.migrate.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.migrate.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_feeTiersLength() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.feeTiersLength.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.feeTiersLength.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_updateBurnAddress(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.updateBurnAddress.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.updateBurnAddress.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_getContractBalance() public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.getContractBalance.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.getContractBalance.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_mint(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                safemoonV2.mint.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.mint.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** New Functions ***/ 

    // TODO: Double-check this function for correctness
    // Safemoon.burn(address,uint256)
    // is a new function, which appears to replace a function with a similar name,
    // Safemoon.burn(uint256).
    // If these functions have different arguments, this function may be incorrect.
    function Safemoon_burn(address a, uint256 b) public virtual {
        bool successV2;
        bytes memory outputV2;
        if(transparentUpgradeableProxyV2.implementation() == address(safemoonV2)) {
            hevm.prank(msg.sender);
            (successV2, outputV2) = address(transparentUpgradeableProxyV2).call(
                abi.encodeWithSelector(
                    safemoonV2.burn.selector, a, b
                )
            );
        } else {
            hevm.prank(msg.sender);
            (successV2, outputV2) = address(transparentUpgradeableProxyV2).call(
                abi.encodeWithSelector(
                    safemoonV1.burn.selector, b
                )
            );
        }
        
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                safemoonV1.burn.selector, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Tainted Variables ***/ 

    // function Safemoon__defaultFees() public {
    //     assert(ISafemoonV1(address(transparentUpgradeableProxyV1))._defaultFees() == ISafemoonV2(address(transparentUpgradeableProxyV2))._defaultFees());
    // }

    function Safemoon__burnAddress() public {
        assert(ISafemoonV1(address(transparentUpgradeableProxyV1))._burnAddress() == ISafemoonV2(address(transparentUpgradeableProxyV2))._burnAddress());
    }

    function Safemoon__maxTxAmount() public {
        assert(ISafemoonV1(address(transparentUpgradeableProxyV1))._maxTxAmount() == ISafemoonV2(address(transparentUpgradeableProxyV2))._maxTxAmount());
    }

    function Safemoon_numTokensToCollectBNB() public {
        assert(ISafemoonV1(address(transparentUpgradeableProxyV1)).numTokensToCollectBNB() == ISafemoonV2(address(transparentUpgradeableProxyV2)).numTokensToCollectBNB());
    }

    function Safemoon_swapAndEvolveEnabled() public {
        assert(ISafemoonV1(address(transparentUpgradeableProxyV1)).swapAndEvolveEnabled() == ISafemoonV2(address(transparentUpgradeableProxyV2)).swapAndEvolveEnabled());
    }

    function Safemoon_bridgeBurnAddress() public {
        assert(ISafemoonV1(address(transparentUpgradeableProxyV1)).bridgeBurnAddress() == ISafemoonV2(address(transparentUpgradeableProxyV2)).bridgeBurnAddress());
    }

    function Safemoon_whitelistMint(address a) public {
        assert(ISafemoonV1(address(transparentUpgradeableProxyV1)).whitelistMint(a) == ISafemoonV2(address(transparentUpgradeableProxyV2)).whitelistMint(a));
    }


    /*** Additional Targets ***/ 

}
