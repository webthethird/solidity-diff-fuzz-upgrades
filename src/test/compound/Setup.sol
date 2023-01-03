pragma solidity ^0.5.16;

import "../../implementation/compound/Comptroller-before/contracts/CToken.sol";
import "../../implementation/compound/Comptroller-before/contracts/ErrorReporter.sol";
import "../../implementation/compound/Comptroller-before/contracts/PriceOracle.sol";
import "../../implementation/compound/Comptroller-before/contracts/ComptrollerInterface.sol";
import "../../implementation/compound/Comptroller-before/contracts/ComptrollerStorage.sol";
import "../../implementation/compound/Comptroller-before/contracts/Unitroller.sol";
import "../../implementation/compound/Comptroller-before/contracts/Governance/Comp.sol";
import {ComptrollerBefore} from "./ComptrollerBefore.sol";
import {ComptrollerAfter} from "./ComptrollerAfter.sol";

contract Users {
    function proxy(address target, bytes memory data) public returns (bool success, bytes memory retData) {
        return target.call(data);
    }
}

contract Setup {
    Comp compToken;
    ComptrollerBefore comptrollerBefore;
    ComptrollerAfter comptrollerAfter;
    Users user;

    constructor() public {
        compToken = new Comp(address(this));
        comptrollerBefore = new ComptrollerBefore(address(compToken));
        comptrollerAfter = new ComptrollerAfter(address(compToken));
    }
}
