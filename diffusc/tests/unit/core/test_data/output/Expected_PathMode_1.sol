// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.2;

import { ContractV1 as ContractV1_V1 } from "../ContractV1.sol";
import { ContractV2 as ContractV2_V2 } from "../ContractV2.sol";
import { TransparentUpgradeableProxy } from "../TransparentUpgradeableProxy.sol";

interface IContractV1 {
    function stateA() external returns (uint256);
    function stateB() external returns (uint256);
    function f(uint256) external;
    function g(uint256) external;
    function h() external;
    function totalValue() external returns (uint256);
    function balance() external returns (uint256);
}

interface IContractV2 {
    function stateA() external returns (uint256);
    function stateB() external returns (uint256);
    function stateC() external returns (uint256);
    function f(uint256) external;
    function g(uint256) external;
    function h() external;
    function i() external;
    function totalValue() external returns (uint256);
    function balance(address) external returns (uint256);
}

interface ITransparentUpgradeableProxy {
    function admin() external returns (address);
    function implementation() external returns (address);
    function changeAdmin(address) external;
    function upgradeTo(address) external;
    function upgradeToAndCall(address,bytes calldata) external payable;
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
    ITransparentUpgradeableProxy transparentUpgradeableProxyV1;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV2;

    constructor() public {
        contractV1 = IContractV1(address(new ContractV1_V1()));
        contractV2 = IContractV2(address(new ContractV2_V2()));
        transparentUpgradeableProxy = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy()));
        transparentUpgradeableProxy = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy()));
        // Store the implementation addresses in the proxy.
        hevm.store(
            address(transparentUpgradeableProxy),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(contractV1))))
        );
        hevm.store(
            address(transparentUpgradeableProxy),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(contractV1))))
        );
    }

    /*** Upgrade Function ***/ 

    // TODO: Consider replacing this with the actual upgrade method
    function upgradeV2() external virtual {
        hevm.store(
            address(transparentUpgradeableProxy),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(contractV2))))
        );
    }


    /*** Modified Functions ***/ 

    function ContractV2_g(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                contractV1.g.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                contractV2.g.selector, a
            )
        );
        assert(successV1 == successV2); 
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }

    function ContractV2_totalValue() public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                contractV1.totalValue.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                contractV2.totalValue.selector
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
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                contractV1.h.selector
            )
        );
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxy).call(
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

    // TODO: Double-check this function for correctness
    // ContractV2.balance(address)
    // is a new function, which appears to replace a function with a similar name,
    // ContractV1.balance().
    // If these functions have different arguments, this function may be incorrect.
    function ContractV2_balance(address a) public virtual {
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxy).call(
            abi.encodeWithSelector(
                contractV1.balance.selector
            )
        );
        address impl = address(uint160(uint256(
            hevm.load(address(transparentUpgradeableProxy),0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        )));
        hevm.prank(msg.sender);
        bool successV2;
        bytes memory outputV2;
        if(impl == address(contractV2)) {
            (successV2, outputV2) = address(transparentUpgradeableProxy).call(
                abi.encodeWithSelector(
                        contractV2.balance.selector, a
                )
            );
        } else {
            (successV2, outputV2) = address(transparentUpgradeableProxy).call(
                abi.encodeWithSelector(
                        contractV1.balance.selector
                )
            );
        }
        assert(successV1 == successV2); 
        if(successV1 && successV2) {
            assert(keccak256(outputV1) == keccak256(outputV2));
        }
    }


    /*** Tainted Variables ***/ 

    function ContractV1_stateB() public returns (uint256) {
        assert(IContractV1(address(transparentUpgradeableProxy)).stateB() == IContractV2(address(transparentUpgradeableProxy)).stateB());
        return IContractV1(address(transparentUpgradeableProxy)).stateB();
    }


    /*** Additional Targets ***/ 

}
