// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import {ProtectionBase} from "../../src/ProtectionBase.sol";

/// @notice Harness contract that enables the testing of {ProtectionBase} internal functions.
contract ProtectionBaseHarness is ProtectionBase {

   function baseInitProtection(address router_, address admin_, bool connectionEstablished_) external {
      _baseInitProtection(router_, admin_, connectionEstablished_);
   }

   function assertShouldProceedWithCall(bytes calldata payload_) external {
    _assertShouldProceedWithCall(payload_);
   }

   function protectedStorage() external pure returns (ProtectedStorage memory cube3Storage) {
     return _protectedStorage();
   }

    // TODO: test payable + non payable
   function getMsgValue() external view returns (uint256) {
    return _getMsgValue();
   }
}