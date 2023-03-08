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

    constructor() {
        // TODO: Add any necessary initialization logic to the constructor here.
    }

    function ComptrollerHarness__supportMarket(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._supportMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._supportMarket.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__become(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._become.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._become.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessRefreshCompSpeeds() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessRefreshCompSpeeds.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessRefreshCompSpeeds.selector
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessAddCompMarkets(address[] memory a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessAddCompMarkets.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessAddCompMarkets.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_getCompMarkets() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.getCompMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.getCompMarkets.selector
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_checkMembership(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.checkMembership.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.checkMembership.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_exitMarket(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.exitMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.exitMarket.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_mintAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.mintAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.mintAllowed.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_redeemAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.redeemAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.redeemAllowed.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_borrowAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.borrowAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.borrowAllowed.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_repayBorrowAllowed(address a, address b, address c, uint256 d) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_liquidateBorrowAllowed(address a, address b, address c, address d, uint256 e) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_seizeAllowed(address a, address b, address c, address d, uint256 e) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.seizeAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.seizeAllowed.selector, a, b, c, d, e
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_transferAllowed(address a, address b, address c, uint256 d) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.transferAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.transferAllowed.selector, a, b, c, d
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_liquidateCalculateSeizeTokens(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.liquidateCalculateSeizeTokens.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.liquidateCalculateSeizeTokens.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setPriceOracle(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setPriceOracle.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setPriceOracle.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setCloseFactor(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setCloseFactor.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setCloseFactor.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setCollateralFactor(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setCollateralFactor.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setCollateralFactor.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setLiquidationIncentive(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setLiquidationIncentive.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setLiquidationIncentive.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setMarketBorrowCaps(address[] calldata a, uint256[] calldata b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setMarketBorrowCaps.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setMarketBorrowCaps.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setBorrowCapGuardian(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setBorrowCapGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setBorrowCapGuardian.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setPauseGuardian(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setPauseGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setPauseGuardian.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setMintPaused(address a, bool b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setMintPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setMintPaused.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setBorrowPaused(address a, bool b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setBorrowPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setBorrowPaused.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setTransferPaused(bool a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setTransferPaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setTransferPaused.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness__setSeizePaused(bool a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1._setSeizePaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2._setSeizePaused.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_updateContributorRewards(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.updateContributorRewards.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.updateContributorRewards.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_claimComp(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.claimComp.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_claimComp(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.claimComp.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_getAllMarkets() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.getAllMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.getAllMarkets.selector
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_isDeprecated(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.isDeprecated.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.isDeprecated.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_setCompSupplyState(address a, uint224 b, uint32 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompSupplyState.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompSupplyState.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_setCompBorrowState(address a, uint224 b, uint32 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompBorrowState.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompBorrowState.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_setCompAccrued(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompAccrued.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompAccrued.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessSetCompRate(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessSetCompRate.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessSetCompRate.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_setCompBorrowerIndex(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompBorrowerIndex.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompBorrowerIndex.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_setCompSupplierIndex(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.setCompSupplierIndex.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.setCompSupplierIndex.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessDistributeAllBorrowerComp(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeAllBorrowerComp.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeAllBorrowerComp.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessDistributeAllSupplierComp(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeAllSupplierComp.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeAllSupplierComp.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessUpdateCompBorrowIndex(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessUpdateCompBorrowIndex.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessUpdateCompBorrowIndex.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessUpdateCompSupplyIndex(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessUpdateCompSupplyIndex.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessUpdateCompSupplyIndex.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessDistributeBorrowerComp(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeBorrowerComp.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeBorrowerComp.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function ComptrollerHarness_harnessDistributeSupplierComp(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerHarnessV1).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV1.harnessDistributeSupplierComp.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerHarnessV2).call(
            abi.encodeWithSelector(
                ComptrollerHarnessV2.harnessDistributeSupplierComp.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
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

}
