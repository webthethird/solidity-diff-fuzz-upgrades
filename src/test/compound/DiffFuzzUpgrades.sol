// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.0;

interface IComptrollerHarnessV1 {
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
    function claimComp(address,address[] memory) external;
    function claimComp(address[] memory,address[] memory,bool,bool) external;
    function _grantComp(address,uint256) external;
    function _setCompSpeed(address,uint256) external;
    function _setContributorCompSpeed(address,uint256) external;
    function getAllMarkets() external returns (address[] memory);
    function isDeprecated(address) external returns (bool);
    function setPauseGuardian(address) external;
    function setCompSupplyState(address,uint224,uint32) external;
    function setCompBorrowState(address,uint224,uint32) external;
    function setCompAccrued(address,uint256) external;
    function setCompAddress(address) external;
    function getCompAddress() external returns (address);
    function harnessSetCompRate(uint256) external;
    function harnessRefreshCompSpeeds() external;
    function setCompBorrowerIndex(address,address,uint256) external;
    function setCompSupplierIndex(address,address,uint256) external;
    function harnessDistributeAllBorrowerComp(address,address,uint256) external;
    function harnessDistributeAllSupplierComp(address,address) external;
    function harnessUpdateCompBorrowIndex(address,uint256) external;
    function harnessUpdateCompSupplyIndex(address) external;
    function harnessDistributeBorrowerComp(address,address,uint256) external;
    function harnessDistributeSupplierComp(address,address) external;
    function harnessTransferComp(address,uint256,uint256) external returns (uint256);
    function harnessAddCompMarkets(address[] memory) external;
    function harnessFastForward(uint256) external returns (uint256);
    function setBlockNumber(uint256) external;
    function getBlockNumber() external returns (uint256);
    function getCompMarkets() external returns (address[] memory);
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
    function blockNumber() external returns (uint256);
}

struct CompMarketState {
    uint224 index;
    uint32 block;
}

interface IComptrollerHarnessV2 {
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
    function claimComp(address,address[] memory) external;
    function claimComp(address[] memory,address[] memory,bool,bool) external;
    function _grantComp(address,uint256) external;
    function _setCompSpeeds(address[] memory,uint256[] memory,uint256[] memory) external;
    function _setContributorCompSpeed(address,uint256) external;
    function getAllMarkets() external returns (address[] memory);
    function isDeprecated(address) external returns (bool);
    function setPauseGuardian(address) external;
    function setCompSupplyState(address,uint224,uint32) external;
    function setCompBorrowState(address,uint224,uint32) external;
    function setCompAccrued(address,uint256) external;
    function setCompAddress(address) external;
    function getCompAddress() external returns (address);
    function harnessSetCompRate(uint256) external;
    function harnessRefreshCompSpeeds() external;
    function setCompBorrowerIndex(address,address,uint256) external;
    function setCompSupplierIndex(address,address,uint256) external;
    function harnessDistributeAllBorrowerComp(address,address,uint256) external;
    function harnessDistributeAllSupplierComp(address,address) external;
    function harnessUpdateCompBorrowIndex(address,uint256) external;
    function harnessUpdateCompSupplyIndex(address) external;
    function harnessDistributeBorrowerComp(address,address,uint256) external;
    function harnessDistributeSupplierComp(address,address) external;
    function harnessTransferComp(address,uint256,uint256) external returns (uint256);
    function harnessAddCompMarkets(address[] memory) external;
    function harnessFastForward(uint256) external returns (uint256);
    function setBlockNumber(uint256) external;
    function getBlockNumber() external returns (uint256);
    function getCompMarkets() external returns (address[] memory);
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
    function blockNumber() external returns (uint256);
}

struct CompMarketState {
    uint224 index;
    uint32 block;
}

interface ICToken {
    function initialize(address,address,uint256,string memory,string memory,uint8) external;
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
    function isCToken() external returns (bool);
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
    IComptrollerHarnessV1 ComptrollerHarnessV1 = IComptrollerHarnessV1(V1_ADDRESS_HERE);
    IComptrollerHarnessV2 ComptrollerHarnessV2 = IComptrollerHarnessV2(V2_ADDRESS_HERE);
    ICToken CTokenV1 = ICToken(CToken_V1_ADDRESS_HERE);
    ICToken CTokenV2 = ICToken(CToken_V2_ADDRESS_HERE);
    IComp CompV1 = IComp(Comp_V1_ADDRESS_HERE);
    IComp CompV2 = IComp(Comp_V2_ADDRESS_HERE);

    constructor() {
        // TODO: Add any necessary initialization logic to the constructor here.
    }

    function ComptrollerHarness__supportMarket(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._supportMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._supportMarket.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__become(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._become.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._become.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessRefreshCompSpeeds() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessRefreshCompSpeeds.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessRefreshCompSpeeds.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessAddCompMarkets(address[] memory a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessAddCompMarkets.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessAddCompMarkets.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_getCompMarkets() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.getCompMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.getCompMarkets.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_checkMembership(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.checkMembership.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.checkMembership.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_exitMarket(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.exitMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.exitMarket.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_mintAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.mintAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.mintAllowed.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_redeemAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.redeemAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.redeemAllowed.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_borrowAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.borrowAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.borrowAllowed.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_repayBorrowAllowed(address a, address b, address c, uint256 d) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_liquidateBorrowAllowed(address a, address b, address c, address d, uint256 e) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_seizeAllowed(address a, address b, address c, address d, uint256 e) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.seizeAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.seizeAllowed.selector, a, b, c, d, e
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_transferAllowed(address a, address b, address c, uint256 d) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.transferAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.transferAllowed.selector, a, b, c, d
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_liquidateCalculateSeizeTokens(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.liquidateCalculateSeizeTokens.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.liquidateCalculateSeizeTokens.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setPriceOracle(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setPriceOracle.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setPriceOracle.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setCloseFactor(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setCloseFactor.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setCloseFactor.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setCollateralFactor(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setCollateralFactor.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setCollateralFactor.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setLiquidationIncentive(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setLiquidationIncentive.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setLiquidationIncentive.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setMarketBorrowCaps(address[] calldata a, uint256[] calldata b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setMarketBorrowCaps.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setMarketBorrowCaps.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setBorrowCapGuardian(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setBorrowCapGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setBorrowCapGuardian.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setPauseGuardian(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setPauseGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setPauseGuardian.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setMintPaused(address a, bool b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setMintPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setMintPaused.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setBorrowPaused(address a, bool b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setBorrowPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setBorrowPaused.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setTransferPaused(bool a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setTransferPaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setTransferPaused.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness__setSeizePaused(bool a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setSeizePaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setSeizePaused.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_updateContributorRewards(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.updateContributorRewards.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.updateContributorRewards.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_claimComp(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.claimComp.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_claimComp(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.claimComp.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_getAllMarkets() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.getAllMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.getAllMarkets.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_isDeprecated(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.isDeprecated.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.isDeprecated.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_setCompSupplyState(address a, uint224 b, uint32 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompSupplyState.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompSupplyState.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_setCompBorrowState(address a, uint224 b, uint32 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompBorrowState.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompBorrowState.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_setCompAccrued(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompAccrued.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompAccrued.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessSetCompRate(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessSetCompRate.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessSetCompRate.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_setCompBorrowerIndex(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompBorrowerIndex.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompBorrowerIndex.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_setCompSupplierIndex(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompSupplierIndex.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompSupplierIndex.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessDistributeAllBorrowerComp(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeAllBorrowerComp.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeAllBorrowerComp.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessDistributeAllSupplierComp(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeAllSupplierComp.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeAllSupplierComp.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessUpdateCompBorrowIndex(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessUpdateCompBorrowIndex.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessUpdateCompBorrowIndex.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessUpdateCompSupplyIndex(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessUpdateCompSupplyIndex.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessUpdateCompSupplyIndex.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessDistributeBorrowerComp(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeBorrowerComp.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeBorrowerComp.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_harnessDistributeSupplierComp(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeSupplierComp.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeSupplierComp.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    // TODO: Double-check this function for correctness
    // Comptroller._setCompSpeeds(CToken[],uint256[],uint256[])
    // is a new function, which appears to replace a function with a similar name,
    // Comptroller._setCompSpeed(CToken,uint256).
    // If these functions have different arguments, this function may be incorrect.
    function ComptrollerHarness__setCompSpeeds(address[] memory a, uint256[] memory b, uint256[] memory c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setCompSpeeds.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setCompSpeed.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function ComptrollerHarness_admin() public returns (bool) {
        return ComptrollerHarnessV1.admin() == ComptrollerHarnessV2.admin();
    }

    function ComptrollerHarness_comptrollerImplementation() public returns (bool) {
        return ComptrollerHarnessV1.comptrollerImplementation() == ComptrollerHarnessV2.comptrollerImplementation();
    }

    function ComptrollerHarness_oracle() public returns (bool) {
        return ComptrollerHarnessV1.oracle() == ComptrollerHarnessV2.oracle();
    }

    function ComptrollerHarness_markets(address a) public returns (bool) {
        return ComptrollerHarnessV1.markets(a) == ComptrollerHarnessV2.markets(a);
    }

    function ComptrollerHarness_allMarkets(uint i) public returns (bool) {
        return ComptrollerHarnessV1.allMarkets[i] == ComptrollerHarnessV2.allMarkets[i];
    }

    function ComptrollerHarness_compRate() public returns (bool) {
        return ComptrollerHarnessV1.compRate() == ComptrollerHarnessV2.compRate();
    }

    function ComptrollerHarness_compSpeeds(address a) public returns (bool) {
        return ComptrollerHarnessV1.compSpeeds(a) == ComptrollerHarnessV2.compSpeeds(a);
    }

    function ComptrollerHarness_compSupplyState(address a) public returns (bool) {
        return ComptrollerHarnessV1.compSupplyState(a) == ComptrollerHarnessV2.compSupplyState(a);
    }

    function ComptrollerHarness_compBorrowState(address a) public returns (bool) {
        return ComptrollerHarnessV1.compBorrowState(a) == ComptrollerHarnessV2.compBorrowState(a);
    }

    function ComptrollerHarness_compSupplierIndex(address a) public returns (bool) {
        return ComptrollerHarnessV1.compSupplierIndex(a) == ComptrollerHarnessV2.compSupplierIndex(a);
    }

    function ComptrollerHarness_compBorrowerIndex(address a) public returns (bool) {
        return ComptrollerHarnessV1.compBorrowerIndex(a) == ComptrollerHarnessV2.compBorrowerIndex(a);
    }

    function ComptrollerHarness_compAccrued(address a) public returns (bool) {
        return ComptrollerHarnessV1.compAccrued(a) == ComptrollerHarnessV2.compAccrued(a);
    }

    function ComptrollerHarness_compBorrowSpeeds(address a) public returns (bool) {
        return ComptrollerHarnessV1.compBorrowSpeeds(a) == ComptrollerHarnessV2.compBorrowSpeeds(a);
    }

    function ComptrollerHarness_compSupplySpeeds(address a) public returns (bool) {
        return ComptrollerHarnessV1.compSupplySpeeds(a) == ComptrollerHarnessV2.compSupplySpeeds(a);
    }

    function CToken_initialize(address a, address b, uint256 c, string memory d, string memory e, uint8 f) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.initialize.selector, a, b, c, d, e, f
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.initialize.selector, a, b, c, d, e, f
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_transfer(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.transfer.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.transfer.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_transferFrom(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.transferFrom.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.transferFrom.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_approve(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.approve.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.approve.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_allowance(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.allowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.allowance.selector, a, b
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_balanceOf(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.balanceOf.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_balanceOfUnderlying(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.balanceOfUnderlying.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.balanceOfUnderlying.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_getAccountSnapshot(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.getAccountSnapshot.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.getAccountSnapshot.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_borrowRatePerBlock() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.borrowRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.borrowRatePerBlock.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_supplyRatePerBlock() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.supplyRatePerBlock.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.supplyRatePerBlock.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_totalBorrowsCurrent() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.totalBorrowsCurrent.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.totalBorrowsCurrent.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_borrowBalanceCurrent(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.borrowBalanceCurrent.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.borrowBalanceCurrent.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_borrowBalanceStored(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.borrowBalanceStored.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.borrowBalanceStored.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_exchangeRateCurrent() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.exchangeRateCurrent.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.exchangeRateCurrent.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_exchangeRateStored() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.exchangeRateStored.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.exchangeRateStored.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_getCash() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.getCash.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.getCash.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_accrueInterest() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.accrueInterest.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.accrueInterest.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken_seize(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2.seize.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1.seize.selector, a, b, c
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken__setPendingAdmin(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2._setPendingAdmin.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1._setPendingAdmin.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken__acceptAdmin() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2._acceptAdmin.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1._acceptAdmin.selector
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken__setComptroller(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2._setComptroller.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1._setComptroller.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken__setReserveFactor(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2._setReserveFactor.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1._setReserveFactor.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken__reduceReserves(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2._reduceReserves.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1._reduceReserves.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function CToken__setInterestRateModel(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(CTokenV2).call(
            abi.encodeWithSelector(
                CTokenV2._setInterestRateModel.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(CTokenV1).call(
            abi.encodeWithSelector(
                CTokenV1._setInterestRateModel.selector, a
            )
        );
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_allowance(address a, address b) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_approve(address a, uint256 b) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_balanceOf(address a) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_transfer(address a, uint256 b) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_transferFrom(address a, address b, uint256 c) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_delegate(address a) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_delegateBySig(address a, uint256 b, uint256 c, uint8 d, bytes32 e, bytes32 f) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_getCurrentVotes(address a) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

    function Comp_getPriorVotes(address a, uint256 b) public returns (bool) {
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
        return (success1 == success2 && 
                ((!success1 && !success2) || keccak256(output1) == keccak256(output2))
               );
    }

}
