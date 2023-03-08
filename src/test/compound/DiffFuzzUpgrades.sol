// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.0;

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
    function claimComp(address,address[] memory) external;
    function claimComp(address[] memory,address[] memory,bool,bool) external;
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
}

struct CompMarketState {
    uint224 index;
    uint32 block;
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
    function claimComp(address,address[] memory) external;
    function claimComp(address[] memory,address[] memory,bool,bool) external;
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

    IComptrollerV1 ComptrollerV1 = IComptrollerV1(V1_ADDRESS_HERE);
    IComptrollerV2 ComptrollerV2 = IComptrollerV2(V2_ADDRESS_HERE);
    constructor() {
        // TODO: Add any necessary initialization logic to the constructor here.    }

    function Comptroller__supportMarket(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._supportMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._supportMarket.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__become(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._become.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._become.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_checkMembership(address a, address b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.checkMembership.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.checkMembership.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_exitMarket(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.exitMarket.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.exitMarket.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_mintAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.mintAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.mintAllowed.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_redeemAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.redeemAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.redeemAllowed.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_borrowAllowed(address a, address b, uint256 c) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.borrowAllowed.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.borrowAllowed.selector, a, b, c
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_repayBorrowAllowed(address a, address b, address c, uint256 d) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.repayBorrowAllowed.selector, a, b, c, d
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_liquidateBorrowAllowed(address a, address b, address c, address d, uint256 e) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.liquidateBorrowAllowed.selector, a, b, c, d, e
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_seizeAllowed(address a, address b, address c, address d, uint256 e) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.seizeAllowed.selector, a, b, c, d, e
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.seizeAllowed.selector, a, b, c, d, e
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_transferAllowed(address a, address b, address c, uint256 d) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.transferAllowed.selector, a, b, c, d
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.transferAllowed.selector, a, b, c, d
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setPriceOracle(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setPriceOracle.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setPriceOracle.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setCloseFactor(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setCloseFactor.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setCloseFactor.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setCollateralFactor(address a, uint256 b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setCollateralFactor.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setCollateralFactor.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setLiquidationIncentive(uint256 a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setLiquidationIncentive.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setLiquidationIncentive.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setMarketBorrowCaps(address[] calldata a, uint256[] calldata b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setMarketBorrowCaps.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setMarketBorrowCaps.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setBorrowCapGuardian(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setBorrowCapGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setBorrowCapGuardian.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setPauseGuardian(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setPauseGuardian.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setPauseGuardian.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setMintPaused(address a, bool b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setMintPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setMintPaused.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setBorrowPaused(address a, bool b) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setBorrowPaused.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setBorrowPaused.selector, a, b
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setTransferPaused(bool a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setTransferPaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setTransferPaused.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller__setSeizePaused(bool a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1._setSeizePaused.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2._setSeizePaused.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_updateContributorRewards(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.updateContributorRewards.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.updateContributorRewards.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_claimComp(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.claimComp.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_claimComp(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.claimComp.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.claimComp.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_getAllMarkets() public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.getAllMarkets.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.getAllMarkets.selector
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_isDeprecated(address a) public returns (bool) {
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(ComptrollerV1).call(
            abi.encodeWithSelector(
                ComptrollerV1.isDeprecated.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(ComptrollerV2).call(
            abi.encodeWithSelector(
                ComptrollerV2.isDeprecated.selector, a
            )
        );
        return success1 == success2 && ((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function Comptroller_admin() public returns (bool) {
        return ComptrollerV1.admin() == ComptrollerV2.admin();
    }

    function Comptroller_comptrollerImplementation() public returns (bool) {
        return ComptrollerV1.comptrollerImplementation() == ComptrollerV2.comptrollerImplementation();
    }

    function Comptroller_markets(address a) public returns (bool) {
        return ComptrollerV1.markets(a) == ComptrollerV2.markets(a);
    }

    function Comptroller_allMarkets(uint i) public returns (bool) {
        return ComptrollerV1.allMarkets[i] == ComptrollerV2.allMarkets[i];
    }

    function Comptroller_compSpeeds(address a) public returns (bool) {
        return ComptrollerV1.compSpeeds(a) == ComptrollerV2.compSpeeds(a);
    }

    function Comptroller_compSupplyState(address a) public returns (bool) {
        return ComptrollerV1.compSupplyState(a) == ComptrollerV2.compSupplyState(a);
    }

    function Comptroller_compBorrowState(address a) public returns (bool) {
        return ComptrollerV1.compBorrowState(a) == ComptrollerV2.compBorrowState(a);
    }

    function Comptroller_compSupplierIndex(address a) public returns (bool) {
        return ComptrollerV1.compSupplierIndex(a) == ComptrollerV2.compSupplierIndex(a);
    }

    function Comptroller_compBorrowerIndex(address a) public returns (bool) {
        return ComptrollerV1.compBorrowerIndex(a) == ComptrollerV2.compBorrowerIndex(a);
    }

    function Comptroller_compAccrued(address a) public returns (bool) {
        return ComptrollerV1.compAccrued(a) == ComptrollerV2.compAccrued(a);
    }

}
