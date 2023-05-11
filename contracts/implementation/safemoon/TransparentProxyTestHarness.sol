// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.11;

import "./TransparentUpgradeableProxy.sol";

contract TransparentProxyTestHarness is TransparentUpgradeableProxy {
    constructor() TransparentUpgradeableProxy(msg.sender, msg.sender, "") {}
}
