// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.11;

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

interface IIUniswapV2Router02 {
    function factory() external pure returns (address);
    function routerTrade() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address,uint256,uint256,uint256,address,uint256) external payable returns (uint256,uint256,uint256);
}

interface IISafeSwapTradeRouter {
    struct Trade {
        uint256 amountIn;
        uint256 amountOut;
        address[] path;
        address to;
        uint256 deadline;
    }
    function setRouter(address) external;
    function setFeePercent(uint256) external;
    function sePercent(uint256) external;
    function addFfsWhitelist(address) external;
    function removeFfsWhitelist(address) external;
    function setFeeJar(address) external;
    function swapExactTokensForETHAndFeeAmount(Trade memory) external payable;
    function swapTokensForExactETHAndFeeAmount(Trade memory) external payable;
    function swapExactETHForTokensWithFeeAmount(Trade memory,uint256) external payable;
    function swapETHForExactTokensWithFeeAmount(Trade memory,uint256) external payable;
    function swapExactTokensForTokensWithFeeAmount(Trade memory) external payable;
    function swapTokensForExactTokensWithFeeAmount(Trade memory) external payable;
    function getSwapFee(uint256,uint256,address,address) external view returns (uint256);
    function getSwapFees(uint256,address[] memory) external view returns (uint256);
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
    function createFork() external returns (uint256 forkId);
    function selectFork(uint256 forkId) external;
}

contract DiffFuzzUpgrades {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // TODO: Deploy the contracts and put their addresses below
    ISafemoonV1 safemoonV1;
    ISafemoonV2 safemoonV2;
    ITransparentUpgradeableProxy transparentUpgradeableProxy;
    IIUniswapV2Router02 iUniswapV2Router02;
    IISafeSwapTradeRouter iSafeSwapTradeRouter;
    uint256 fork1;
    uint256 fork2;

    constructor() public {
        hevm.roll(26857448);
        fork1 = hevm.createFork();
        fork2 = hevm.createFork();
        fork1 = 1;
        fork2 = 2;
        safemoonV1 = ISafemoonV1(0x0296201BfDfB410C29EF30BCaE1b395537aeEB31);
        safemoonV2 = ISafemoonV2(0xEb11a0a0beF1AC028B8C2d4CD64138DD5938cA7A);
        transparentUpgradeableProxy = ITransparentUpgradeableProxy(0x42981d0bfbAf196529376EE702F2a9Eb9092fcB5);
        // TODO: Set proxy implementations (proxy implementation slot not found).
        address owner = ISafemoonV1(address(transparentUpgradeableProxy)).owner();
        hevm.selectFork(fork1);
        hevm.store(
            address(transparentUpgradeableProxy),
            bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc),
            bytes32(uint256(uint160(address(safemoonV1))))
        );
        hevm.prank(owner);
        ISafemoonV1(address(transparentUpgradeableProxy)).transferOwnership(address(this));
        assert(ISafemoonV1(address(transparentUpgradeableProxy)).owner() == address(this));
        hevm.selectFork(fork2);
        hevm.store(
            address(transparentUpgradeableProxy),
            bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc),
            bytes32(uint256(uint160(address(safemoonV2))))
        );
        hevm.prank(owner);
        ISafemoonV1(address(transparentUpgradeableProxy)).transferOwnership(address(this));

        // TODO: Fill in target address below (address not found automatically)
        iUniswapV2Router02 = IIUniswapV2Router02(address(0x006ac68913d8fccd52d196b09e6bc0205735a4be5f));
        // TODO: Fill in target address below (address not found automatically)
        iSafeSwapTradeRouter = IISafeSwapTradeRouter(address(0x00524bc73fcb4fb70e2e84dc08efe255252a3b026e));
    }

    /*** Upgrade Function ***/ 

    // TODO: Consider replacing this with the actual upgrade method
    // function upgradeV2() external virtual {
    //     // TODO: add upgrade logic here (implementation slot could not be found automatically)
    // }


    /*** Modified Functions ***/ 


    /*** Tainted Functions ***/ 

    function Safemoon_initialize() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.initialize.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.initialize.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_balanceOf(address a) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.balanceOf.selector, a
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.balanceOf.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_transfer(address a, uint256 b) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.transfer.selector, a, b
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.transfer.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_transferFrom(address a, address b, uint256 c) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.transferFrom.selector, a, b, c
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.transferFrom.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_totalFees() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.totalFees.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.totalFees.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_reflectionFromTokenInTiers(uint256 a, uint256 b, bool c) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.reflectionFromTokenInTiers.selector, a, b, c
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.reflectionFromTokenInTiers.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_reflectionFromToken(uint256 a, bool b) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.reflectionFromToken.selector, a, b
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.reflectionFromToken.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_tokenFromReflection(uint256 a) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.tokenFromReflection.selector, a
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.tokenFromReflection.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_accountTier(address a) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.accountTier.selector, a
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.accountTier.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_feeTier(uint256 a) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.feeTier.selector, a
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.feeTier.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_migrate(address a, uint256 b) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.migrate.selector, a, b
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.migrate.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_feeTiersLength() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.feeTiersLength.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.feeTiersLength.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_getContractBalance() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.getContractBalance.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.getContractBalance.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function Safemoon_mint(address a, uint256 b) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.mint.selector, a, b
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
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
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV2.burn.selector, a, b
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                safemoonV1.burn.selector, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Tainted Variables ***/ 

    // function Safemoon__defaultFees() public {
    //     hevm.selectFork(fork1);
    //     Safemoon.FeeTier a1 = ISafemoonV1(address(transparentUpgradeableProxy))._defaultFees();
    //     hevm.selectFork(fork2);
    //     Safemoon.FeeTier a2 = ISafemoonV2(address(transparentUpgradeableProxy))._defaultFees();
    //     assert(a1 == a2);
    // }

    function Safemoon__burnAddress() public {
        hevm.selectFork(fork1);
        address a1 = ISafemoonV1(address(transparentUpgradeableProxy))._burnAddress();
        hevm.selectFork(fork2);
        address a2 = ISafemoonV2(address(transparentUpgradeableProxy))._burnAddress();
        assert(a1 == a2);
    }

    function Safemoon__maxTxAmount() public {
        hevm.selectFork(fork1);
        uint256 a1 = ISafemoonV1(address(transparentUpgradeableProxy))._maxTxAmount();
        hevm.selectFork(fork2);
        uint256 a2 = ISafemoonV2(address(transparentUpgradeableProxy))._maxTxAmount();
        assert(a1 == a2);
    }

    function Safemoon_numTokensToCollectBNB() public {
        hevm.selectFork(fork1);
        uint256 a1 = ISafemoonV1(address(transparentUpgradeableProxy)).numTokensToCollectBNB();
        hevm.selectFork(fork2);
        uint256 a2 = ISafemoonV2(address(transparentUpgradeableProxy)).numTokensToCollectBNB();
        assert(a1 == a2);
    }

    function Safemoon_swapAndEvolveEnabled() public {
        hevm.selectFork(fork1);
        bool a1 = ISafemoonV1(address(transparentUpgradeableProxy)).swapAndEvolveEnabled();
        hevm.selectFork(fork2);
        bool a2 = ISafemoonV2(address(transparentUpgradeableProxy)).swapAndEvolveEnabled();
        assert(a1 == a2);
    }

    function Safemoon_bridgeBurnAddress() public {
        hevm.selectFork(fork1);
        address a1 = ISafemoonV1(address(transparentUpgradeableProxy)).bridgeBurnAddress();
        hevm.selectFork(fork2);
        address a2 = ISafemoonV2(address(transparentUpgradeableProxy)).bridgeBurnAddress();
        assert(a1 == a2);
    }

    function Safemoon_whitelistMint(address a) public {
        hevm.selectFork(fork1);
        bool a1 = ISafemoonV1(address(transparentUpgradeableProxy)).whitelistMint(a);
        hevm.selectFork(fork2);
        bool a2 = ISafemoonV2(address(transparentUpgradeableProxy)).whitelistMint(a);
        assert(a1 == a2);
    }


    /*** Tainted External Contracts ***/ 

    function IUniswapV2Router02_factory() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(iUniswapV2Router02).call(
            abi.encodeWithSelector(
                iUniswapV2Router02.factory.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(iUniswapV2Router02).call(
            abi.encodeWithSelector(
                iUniswapV2Router02.factory.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function IUniswapV2Router02_WETH() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(iUniswapV2Router02).call(
            abi.encodeWithSelector(
                iUniswapV2Router02.WETH.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(iUniswapV2Router02).call(
            abi.encodeWithSelector(
                iUniswapV2Router02.WETH.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function IUniswapV2Router02_routerTrade() public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(iUniswapV2Router02).call(
            abi.encodeWithSelector(
                iUniswapV2Router02.routerTrade.selector
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(iUniswapV2Router02).call(
            abi.encodeWithSelector(
                iUniswapV2Router02.routerTrade.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function ISafeSwapTradeRouter_swapExactTokensForETHAndFeeAmount(IISafeSwapTradeRouter.Trade calldata a) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(iSafeSwapTradeRouter).call(
            abi.encodeWithSelector(
                iSafeSwapTradeRouter.swapExactTokensForETHAndFeeAmount.selector, a
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(iSafeSwapTradeRouter).call(
            abi.encodeWithSelector(
                iSafeSwapTradeRouter.swapExactTokensForETHAndFeeAmount.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function ISafeSwapTradeRouter_getSwapFees(uint256 a, address[] memory b) public virtual {
        hevm.selectFork(fork2);
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(iSafeSwapTradeRouter).call(
            abi.encodeWithSelector(
                iSafeSwapTradeRouter.getSwapFees.selector, a, b
            )
        );
        hevm.selectFork(fork1);
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(iSafeSwapTradeRouter).call(
            abi.encodeWithSelector(
                iSafeSwapTradeRouter.getSwapFees.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Additional Targets ***/ 

}
