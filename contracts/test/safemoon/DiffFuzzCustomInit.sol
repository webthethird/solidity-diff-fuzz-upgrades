// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.11;

import "./DiffFuzzUpgrades.sol";

contract DiffFuzzInit is DiffFuzzUpgrades {
    // constructor() DiffFuzzUpgrades() {
    //     // Initialize contracts
    //     hevm.prank(msg.sender);
    //     ISafemoonV1(address(transparentUpgradeableProxyV1)).initialize();
    //     hevm.prank(msg.sender);
    //     ISafemoonV2(address(transparentUpgradeableProxyV2)).initialize();

    //     // Distribute some tokens to other accounts
    //     hevm.prank(msg.sender);
    //     uint myBalance = ISafemoonV1(address(transparentUpgradeableProxyV1)).balanceOf(address(msg.sender));
    //     hevm.prank(msg.sender);
    //     ISafemoonV1(address(transparentUpgradeableProxyV1)).transfer(address(0x2000), myBalance / 10);
    //     hevm.prank(msg.sender);
    //     ISafemoonV2(address(transparentUpgradeableProxyV2)).transfer(address(0x2000), myBalance / 10);
    //     hevm.prank(msg.sender);
    //     ISafemoonV1(address(transparentUpgradeableProxyV1)).transfer(address(0x3000), myBalance / 10);
    //     hevm.prank(msg.sender);
    //     ISafemoonV2(address(transparentUpgradeableProxyV2)).transfer(address(0x3000), myBalance / 10);
    // }

    function Safemoon_transfer(address a, uint256 b) public override {
        require(a != address(transparentUpgradeableProxyV1) && a != address(transparentUpgradeableProxyV2));
        super.Safemoon_transfer(a, b);
    }

    function Safemoon_transferFrom(address a, address b, uint256 c) public override {
        require(a != address(transparentUpgradeableProxyV1) && a != address(transparentUpgradeableProxyV2));
        require(b != address(transparentUpgradeableProxyV1) && b != address(transparentUpgradeableProxyV2));
        super.Safemoon_transferFrom(a, b, c);
    }
}
