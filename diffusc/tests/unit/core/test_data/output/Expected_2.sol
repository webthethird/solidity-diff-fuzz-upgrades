// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.2;

import { ContractV1 as ContractV1_V1 } from "../ContractV1.sol";
import { ContractV2 as ContractV2_V2 } from "../ContractV2.sol";
import { MarketToken } from "../token/MarketToken.sol";
import { SimplePriceOracle } from "../SimplePriceOracle.sol";

interface IContractV1 {
    function stateA() external returns (uint256);
    function stateB() external returns (uint256);
    function f(uint256) external;
    function g(uint256) external;
    function h() external;
}

interface IContractV2 {
    function stateA() external returns (uint256);
    function stateB() external returns (uint256);
    function stateC() external returns (uint256);
    function f(uint256) external;
    function g(uint256) external;
    function h() external;
    function i() external;
}

interface IMarketToken {
    function underlying() external returns (address);
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
    function mint(uint256) external;
    function redeem(uint256) external;
    function borrow(uint256) external;
    function underlyingBalance(address) external returns (uint256);
}

interface ISimplePriceOracle {
    function getUnderlyingPrice(address) external view returns (uint256);
    function setUnderlyingPrice(address,uint256) external;
    function setDirectPrice(address,uint256) external;
    function assetPrices(address) external view returns (uint256);
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

    IContractV1 contractV1V1;
    IContractV2 contractV2V2;
    IMarketToken marketTokenV1;
    IMarketToken marketTokenV2;
    ISimplePriceOracle simplePriceOracleV1;
    ISimplePriceOracle simplePriceOracleV2;

    constructor() public {
        contractV1 = IContractV1(address(new ContractV1_V1()));
        contractV2 = IContractV2(address(new ContractV2_V2()));
        marketToken = IMarketToken(address(new MarketToken()));
        marketToken = IMarketToken(address(new MarketToken()));
        simplePriceOracle = ISimplePriceOracle(address(new SimplePriceOracle()));
        simplePriceOracle = ISimplePriceOracle(address(new SimplePriceOracle()));
    }


    /*** Modified Functions ***/

    function ContractV2_g(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(contractV1).call(
            abi.encodeWithSelector(
                contractV1.g.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(contractV2).call(
            abi.encodeWithSelector(
                contractV2.g.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }


    /*** Tainted Functions ***/

    function ContractV2_h() public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(contractV1).call(
            abi.encodeWithSelector(
                contractV1.h.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(contractV2).call(
            abi.encodeWithSelector(
                contractV2.h.selector
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }


    /*** New Functions ***/


    /*** Tainted Variables ***/

    function ContractV1_stateB() public returns (uint256) {
        assert(contractV1.stateB() == contractV2.stateB());
        return contractV1.stateB();
    }


    /*** Additional Targets ***/

    function MarketToken_name() public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.name.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.name.selector
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_symbol() public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.symbol.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.symbol.selector
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_decimals() public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.decimals.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.decimals.selector
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_totalSupply() public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.totalSupply.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.totalSupply.selector
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_balanceOf(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.balanceOf.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.balanceOf.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_transfer(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.transfer.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.transfer.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_allowance(address a, address b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.allowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.allowance.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_approve(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.approve.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.approve.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_transferFrom(address a, address b, uint256 c) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.transferFrom.selector, a, b, c
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.transferFrom.selector, a, b, c
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_increaseAllowance(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.increaseAllowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.increaseAllowance.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_decreaseAllowance(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.decreaseAllowance.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.decreaseAllowance.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_mint(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.mint.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.mint.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_redeem(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.redeem.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.redeem.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_borrow(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.borrow.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.borrow.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function MarketToken_underlyingBalance(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.underlyingBalance.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(marketToken).call(
            abi.encodeWithSelector(
                marketToken.underlyingBalance.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function SimplePriceOracle_getUnderlyingPrice(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.getUnderlyingPrice.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.getUnderlyingPrice.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function SimplePriceOracle_setUnderlyingPrice(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.setUnderlyingPrice.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.setUnderlyingPrice.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function SimplePriceOracle_setDirectPrice(address a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.setDirectPrice.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.setDirectPrice.selector, a, b
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function SimplePriceOracle_assetPrices(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.assetPrices.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(simplePriceOracle).call(
            abi.encodeWithSelector(
                simplePriceOracle.assetPrices.selector, a
            )
        );
        assert(successV1 == successV2);
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

}
