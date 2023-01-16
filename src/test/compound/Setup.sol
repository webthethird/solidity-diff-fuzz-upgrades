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
    bool marketAdded;

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
        marketAdded = false;
        // Set this contract as the Unitrollers' admin using the store cheat code
        address adminBefore = comptrollerBefore.admin();
        CheatCodes(HEVM_ADDRESS).prank(adminBefore);
        (bool success1,) = address(comptrollerBefore).call(abi.encodeWithSignature("_setPendingAdmin(address)", address(this)));
        address adminAfter = comptrollerAfter.admin();
        CheatCodes(HEVM_ADDRESS).prank(adminAfter);
        (bool success2,) = address(comptrollerAfter).call(abi.encodeWithSignature("_setPendingAdmin(address)", address(this)));
        require(success1, "First _setPendingAdmin failed");
        require(success2, "Second _setPendingAdmin failed");
        (bool success3,) = address(comptrollerBefore).call(abi.encodeWithSignature("_acceptAdmin()"));
        (bool success4,) = address(comptrollerAfter).call(abi.encodeWithSignature("_acceptAdmin()"));
        require(success3, "First _acceptAdmin failed");
        require(success4, "Second _acceptAdmin failed");

        assert(comptrollerBefore.admin() == address(this));
        assert(comptrollerAfter.admin() == address(this));
    }

    function _between(uint val, uint low, uint high) internal pure returns (uint) {
        return low + (val % (high - low + 1));
    }
}
