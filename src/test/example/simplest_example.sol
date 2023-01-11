// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract C {
  address public owner;

  constructor() { // Constructor
    owner = msg.sender;
  }
}