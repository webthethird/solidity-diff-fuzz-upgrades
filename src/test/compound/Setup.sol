pragma solidity ^0.8.9;

import "../../interface/compound/Comptroller.sol";
import {UNITROLLER_BEFORE_ADDR, UNITROLLER_AFTER_ADDR} from "../addresses.sol";
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
        // Set this contract as the Unitrollers' admin using the store cheat code
        CheatCodes(HEVM_ADDRESS).store(UNITROLLER_BEFORE_ADDR, 0, bytes32(bytes20(address(this))));
        CheatCodes(HEVM_ADDRESS).store(UNITROLLER_AFTER_ADDR, 0, bytes32(bytes20(address(this))));
    }
}
