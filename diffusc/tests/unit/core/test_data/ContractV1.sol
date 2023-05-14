pragma solidity ^0.8.2;

import "./SimplePriceOracle.sol";
import "./token/MarketToken.sol";

contract ContractV1 {
    address admin;
    MarketToken mToken;
    SimplePriceOracle oracle;
    uint public stateA = 0;
    uint public stateB = 0;
    uint constant CONST = 32;
    bool bug = false;

    function f(uint x) public {
        if (msg.sender == admin) {
            stateA = x;
        }
    }

    function g(uint y) public {
        if (checkA()) {
            stateB = y - 10;
        }
    }

    function h() public {
        if (checkB()) {
            bug = true;
        }
    }

    function totalValue() public returns (uint256) {
        return balance() * underlyingPrice();
    }

    function balance() public returns (uint256) {
        return mToken.balanceOf(address(this));
    }

    function checkA() internal returns (bool) {
        return stateA % CONST == 1;
    }

    function checkB() internal returns (bool) {
        return stateB == 62;
    }

    function price() internal returns (uint256) {
        return oracle.assetPrices(address(mToken));
    }

    function underlyingPrice() internal returns (uint256) {
        return oracle.getUnderlyingPrice(mToken);
    }
}
