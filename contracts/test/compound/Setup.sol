pragma solidity ^0.8.9;

import "../../implementation/compound/master-contracts/Comptroller.sol";
import "../addresses.sol";
import "../helpers.sol";

contract Users {
    function proxy(address target, bytes memory data) public returns (bool success, bytes memory retData) {
        return target.call(data);
    }
}

contract Setup {
    Comp compTokenBefore;
    Comp compTokenAfter;
    CToken[] marketsBefore;
    CToken[] marketsAfter;
    Comptroller comptrollerBefore;
    Comptroller comptrollerAfter;
    Users user;
    bool upgradeDone;

    /**
     * Must run build.sh first to create both Compound protocol deployments
     * and populate addresses.sol with the addresses of the Unitrollers once
     * they have been deployed and upgraded to the before/after implementations
     */
    constructor() public {
        comptrollerBefore = Comptroller(address(UNITROLLER_BEFORE_ADDR));
        comptrollerAfter = Comptroller(address(UNITROLLER_AFTER_ADDR));
        compTokenBefore = Comp(comptrollerBefore.getCompAddress());
        compTokenAfter = Comp(comptrollerAfter.getCompAddress());
        marketsBefore = comptrollerBefore.getAllMarkets();
        marketsAfter = comptrollerAfter.getAllMarkets();
        upgradeDone = false;
        // Set this contract as the Unitrollers' admin using the store cheat code
        CheatCodes(HEVM_ADDRESS).store(
            address(comptrollerBefore),
            bytes32(0),
            bytes32(uint256(uint160(address(this))))
        );
        CheatCodes(HEVM_ADDRESS).store(
            address(comptrollerAfter),
            bytes32(0),
            bytes32(uint256(uint160(address(this))))
        );
        assert(comptrollerBefore.admin() == address(this));
        assert(comptrollerAfter.admin() == address(this));
    }

    function _between(uint val, uint low, uint high) internal pure returns (uint) {
        return low + (val % (high - low + 1));
    }
}
