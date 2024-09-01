// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

import { Constants } from "../utils/Constants.sol";

/// @notice This contract is used to test calls to an incorrectly set router address.
contract MockNonRouter {
    fallback() external payable { }
}
