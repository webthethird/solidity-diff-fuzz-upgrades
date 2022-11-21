// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IMintable {
    function balances(address addr) external returns (uint);

    function transfer(address to, uint value) external;

    function mint(uint value) external;
}