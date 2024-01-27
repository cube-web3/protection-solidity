// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {ProtectionBaseHarness} from "./harnesses/ProtectionBaseHarness.sol";

import {Utils} from "./utils/Utils.sol";

abstract contract BaseTest is Test, Utils {
 
 ProtectionBaseHarness internal protectionBaseHarness;

 function setUp() public virtual {

  _deployContracts();

  _labelAccounts();
 }

 function _deployContracts() internal {
   protectionBaseHarness = new ProtectionBaseHarness();
 }

 function _labelAccounts() internal {
  vm.label({ account: address(protectionBaseHarness), newLabel: "Protection Base Harness" });
 }
}

