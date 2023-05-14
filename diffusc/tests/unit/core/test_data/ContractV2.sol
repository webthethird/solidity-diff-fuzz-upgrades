pragma solidity ^0.8.2;

import "./SimplePriceOracle.sol";
import "./token/MarketToken.sol";

contract ContractV2 {
    address admin;
    MarketToken mToken;
    SimplePriceOracle oracle;
    uint public stateA = 0;
    uint public stateB = 0;
    uint constant CONST = 32;
    bool bug = false;
    uint public stateC = 0;

    function f(uint x) public {
        if (msg.sender == admin) {
            stateA = x;
        }
    }

    function g(uint y) public {
        if (checkA()) {
            stateB = y + 10;
        }
    }

    function h() public {
        if (checkB()) {
            bug = true;
        }
    }

    function i() public {
        stateC = stateC + 1;
    }

    function totalValue() public returns (uint256) {
        return balance(address(this)) * underlyingPrice();
    }

    function balance(address holder) public returns (uint256) {
        return mToken.balanceOf(holder);
    }

    function checkA() internal returns (bool) {
        return stateA % CONST == 1;
    }

    function checkB() internal returns (bool) {
        return stateB == 32;
    }

    function price() internal returns (uint256) {
        return oracle.assetPrices(address(mToken));
    }

    function underlyingPrice() internal returns (uint256) {
        return oracle.getUnderlyingPrice(mToken);
    }
}
