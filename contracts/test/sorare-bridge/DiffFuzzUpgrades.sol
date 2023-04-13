// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.6.12;

import { StarkExchange as StarkExchange_V1 } from "../../implementation/sorare-bridge/StarkExchangeV1.sol";
import { StarkExchange as StarkExchange_V2 } from "../../implementation/sorare-bridge/StarkExchangeV2.sol";
import { TransparentUpgradeableProxy } from "../../implementation/@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

interface IStarkExchangeV1 {
    struct GovernanceInfoStruct {
        mapping(address => bool) effectiveGovernors;
        address candidateGovernor;
        bool initialized;
    }
    function VERSION() external returns (string memory);
    function initialize(bytes calldata) external;
}

interface IStarkExchangeV2 {
    struct GovernanceInfoStruct {
        mapping(address => bool) effectiveGovernors;
        address candidateGovernor;
        bool initialized;
    }
    function VERSION() external returns (string memory);
    function initialize(bytes calldata) external;
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
    IStarkExchangeV1 starkExchangeV1;
    IStarkExchangeV2 starkExchangeV2;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV1;
    ITransparentUpgradeableProxy transparentUpgradeableProxyV2;

    constructor() public {
        starkExchangeV1 = IStarkExchangeV1(address(new StarkExchange_V1()));
        starkExchangeV2 = IStarkExchangeV2(address(new StarkExchange_V2()));
        transparentUpgradeableProxyV1 = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy()));
        transparentUpgradeableProxyV2 = ITransparentUpgradeableProxy(address(new TransparentUpgradeableProxy()));
        // Store the implementation addresses in the proxy.
        hevm.store(
            address(transparentUpgradeableProxyV1),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(starkExchangeV1))))
        );
        hevm.store(
            address(transparentUpgradeableProxyV2),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(starkExchangeV1))))
        );
    }

    /*** Upgrade Function ***/ 

    function upgradeV2() external virtual {
        hevm.store(
            address(transparentUpgradeableProxyV2),
            bytes32(uint(24440054405305269366569402256811496959409073762505157381672968839269610695612)),
            bytes32(uint256(uint160(address(starkExchangeV2))))
        );
    }


    /*** Modified Functions ***/ 


    /*** Tainted Functions ***/ 

    function StarkExchange_initialize(bytes calldata a) public virtual {
        hevm.prank(msg.sender);
        (bool successV2, bytes memory outputV2) = address(transparentUpgradeableProxyV2).call(
            abi.encodeWithSelector(
                starkExchangeV2.initialize.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool successV1, bytes memory outputV1) = address(transparentUpgradeableProxyV1).call(
            abi.encodeWithSelector(
                starkExchangeV1.initialize.selector, a
            )
        );
        assert(successV1 == successV2); 
        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));
    }


    /*** New Functions ***/ 


    /*** Tainted Variables ***/ 


    /*** Additional Targets ***/ 

}
