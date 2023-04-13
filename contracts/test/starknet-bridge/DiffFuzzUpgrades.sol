// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.6.12;

import { StarknetEthBridge as StarknetEthBridge_V1 } from "../../implementation/starknet-bridge/before/StarknetEthBridge/StarknetEthBridge.sol";
import { StarknetEthBridge as StarknetEthBridge_V2 } from "../../implementation/starknet-bridge/after/StarknetEthBridge/StarknetEthBridge.sol";
import { TransparentUpgradeableProxy } from "../../implementation/@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

interface IStarknetEthBridgeV1 {
    function setL2TokenBridge(uint256) external;
    function setMaxTotalBalance(uint256) external;
    function setMaxDeposit(uint256) external;
    function withdraw(uint256) external;
    function depositCancelRequest(uint256,uint256,uint256) external;
    function depositReclaim(uint256,uint256,uint256) external;
    function isFrozen() external view returns (bool);
    function initialize(bytes calldata) external;
    function isGovernor(address) external view returns (bool);
    function nominateNewGovernor(address) external;
    function removeGovernor(address) external;
    function acceptGovernance() external;
    function cancelNomination() external;
    function maxDeposit() external view returns (uint256);
    function maxTotalBalance() external view returns (uint256);
    function deposit(uint256) external payable;
    function withdraw(uint256,address) external;
}

interface IStarknetEthBridgeV2 {
    function setL2TokenBridge(uint256) external;
    function setMaxTotalBalance(uint256) external;
    function setMaxDeposit(uint256) external;
    function withdraw(uint256,address) external;
    function withdraw(uint256) external;
    function depositCancelRequest(uint256,uint256,uint256) external;
    function depositReclaim(uint256,uint256,uint256) external;
    function isFrozen() external view returns (bool);
    function initialize(bytes calldata) external;
    function isGovernor(address) external view returns (bool);
    function nominateNewGovernor(address) external;
    function removeGovernor(address) external;
    function acceptGovernance() external;
    function cancelNomination() external;
    function maxDeposit() external view returns (uint256);
    function maxTotalBalance() external view returns (uint256);
    function isActive() external view returns (bool);
    function deposit(uint256,uint256) external payable;
    function deposit(uint256) external payable;
    function identify() external pure returns (string memory);
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
}

contract DiffFuzzUpgrades {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // TODO: Deploy the contracts and put their addresses below
    IStarknetEthBridgeV1 starknetEthBridgeV1;
    IStarknetEthBridgeV2 starknetEthBridgeV2;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV1;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV2;

    constructor() public {
        starknetEthBridgeV1 = IStarknetEthBridgeV1(address(new StarknetEthBridge_V1()));
        starknetEthBridgeV2 = IStarknetEthBridgeV2(address(new StarknetEthBridge_V2()));
        transparentUpgradeableProxyV1 = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy()));
        transparentUpgradeableProxyV2 = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy()));
        // Store the implementation addresses in the proxy.
        hevm.store(
            address(transparentUpgradeableProxyV1),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(starknetEthBridgeV1))))
        );
        hevm.store(
            address(transparentUpgradeableProxyV2),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(starknetEthBridgeV2))))
        );
    }


    /*** Modified Functions ***/ 

    function StarknetEthBridge_setL2TokenBridge(uint256 a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.setL2TokenBridge.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.setL2TokenBridge.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_withdraw(uint256 a, address b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.withdraw.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.withdraw.selector, a, b
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_depositCancelRequest(uint256 a, uint256 b, uint256 c) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.depositCancelRequest.selector, a, b, c
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.depositCancelRequest.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_depositReclaim(uint256 a, uint256 b, uint256 c) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.depositReclaim.selector, a, b, c
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.depositReclaim.selector, a, b, c
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_deposit(uint256 a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.deposit.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.deposit.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Tainted Functions ***/ 

    function StarknetEthBridge_withdraw(uint256 a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.withdraw.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.withdraw.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_initialize(bytes calldata a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.initialize.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.initialize.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_nominateNewGovernor(address a) public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.nominateNewGovernor.selector, a
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.nominateNewGovernor.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_acceptGovernance() public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.acceptGovernance.selector
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.acceptGovernance.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    function StarknetEthBridge_cancelNomination() public virtual {
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.cancelNomination.selector
            )
        );
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.cancelNomination.selector
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** New Functions ***/ 

    // TODO: Double-check this function for correctness
    // StarknetEthBridge.deposit(uint256,uint256)
    // is a new function, which appears to replace a function with a similar name,
    // StarknetEthBridge.deposit(uint256).
    // If these functions have different arguments, this function may be incorrect.
    function StarknetEthBridge_deposit(uint256 a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.deposit.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.deposit.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }

    // TODO: Double-check this function for correctness
    // StarknetEthBridge.deposit(uint256,uint256)
    // is a new function, which appears to replace a function with a similar name,
    // StarknetEthBridge.deposit(uint256).
    // If these functions have different arguments, this function may be incorrect.
    function StarknetEthBridge_deposit(uint256 a, uint256 b) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starknetEthBridgeV2.deposit.selector, a, b
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starknetEthBridgeV1.deposit.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** Tainted Variables ***/ 


    /*** Additional Targets ***/ 

}
