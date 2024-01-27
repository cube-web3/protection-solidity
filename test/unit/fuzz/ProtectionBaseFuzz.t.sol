// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseTest} from "../../Base.t.sol";


contract ProtectionBase_Unit_Fuzz_Test is BaseTest {

  function setUp() public virtual override {
    BaseTest.setUp();
  }

  function testFuzz_PayableMsgValue_IsCorrect(uint256 ethValue) public {
    vm.deal(users.randomUser, ethValue);
    vm.startPrank(users.randomUser);
    uint256 result = protectionBaseHarness.getMsgValuePayable{value: ethValue}();
    assertEq(result, ethValue, "values not matching");
    vm.stopPrank();
  }
}