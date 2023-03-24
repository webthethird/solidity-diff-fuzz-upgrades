// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.2;

import { ContractV1 as ContractV1_V1 } from "./ContractV1.sol";
import { ContractV2 as ContractV2_V2 } from "./ContractV2.sol";

interface IContractV1V1 {
    function f(uint256) external;
    function g(uint256) external;
    function h() external;
    function bug() external returns (bool);
}

interface IContractV2V2 {
    function f(uint256) external;
    function g(uint256) external;
    function h() external;
    function i() external;
    function bug() external returns (bool);
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
    IContractV1V1 contractV1V1;
    IContractV2V2 contractV2V2;

    constructor() public {
        contractV1V1 = IContractV1V1(address(new ContractV1_V1()));
        contractV2V2 = IContractV2V2(address(new ContractV2_V2()));
    }


    /*** Modified Functions ***/ 

    function ContractV2_h() public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(contractV2V2).call(
            abi.encodeWithSelector(
                contractV2V2.h.selector
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(contractV1V1).call(
            abi.encodeWithSelector(
                contractV1V1.h.selector
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }


    /*** Tainted Functions ***/ 

    function ContractV2_g(uint256 a) public {
        hevm.prank(msg.sender);
        (bool success2, bytes memory output2) = address(contractV2V2).call(
            abi.encodeWithSelector(
                contractV2V2.g.selector, a
            )
        );
        hevm.prank(msg.sender);
        (bool success1, bytes memory output1) = address(contractV1V1).call(
            abi.encodeWithSelector(
                contractV1V1.g.selector, a
            )
        );
        assert(success1 == success2); 
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }


    /*** New Functions ***/ 


    /*** Tainted Variables ***/ 

    function ContractV1_bug() public {
        assert(contractV1V1.bug() == contractV2V2.bug());
    }

}
