// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

import { BaseTest } from "../../Base.t.sol";

contract ProtectionBase_Fuzz_Unit_Test is BaseTest {
    function setUp() public virtual override {
        BaseTest.setUp();
    }

    //////////////////////////////////////////////////////////////////////////
    //                             cube3Protected                           //
    //////////////////////////////////////////////////////////////////////////


    //////////////////////////////////////////////////////////////////////////
    //                     _assertShouldProceedAndCall                     //
    //////////////////////////////////////////////////////////////////////////

    // should receive the correct msg.sender, msg.value, and msg.data when the router is set
    function testFuzz_SucceedsWhen_MsgContextCorrectlyForwarded(uint256 msgValue) public {
        protectionBaseHarness.baseInitProtection(address(mockRouter), users.integrationAdmin, true);

        // create an account and give it the right value
        address msgSender = _randomAddress();
        vm.deal(msgSender, msgValue);

        bytes32 msgDataSeed = keccak256(abi.encode(msgValue));
        vm.startPrank(msgSender);
        protectionBaseHarness.assertShouldProceedAndCall{ value: msgValue }(msgDataSeed);
        vm.stopPrank();

        assertEq(mockRouter.msgValue(), msgValue, "value not matching");
        assertEq(mockRouter.msgSender(), msgSender, "sender not matching");
        assertEq(
            mockRouter.msgData(),
            abi.encodeWithSignature("assertShouldProceedAndCall(bytes32)", msgDataSeed),
            "msg.data not matching"
        );
    }

    /////////////////////////////////////////////////////////////////////////
    //                             _getMsgValue                            //
    /////////////////////////////////////////////////////////////////////////

    function testFuzz_PayableMsgValue_IsCorrect(uint256 ethValue) public {
        vm.deal(users.randomUser, ethValue);
        vm.startPrank(users.randomUser);
        uint256 result = protectionBaseHarness.getMsgValuePayable{ value: ethValue }();
        assertEq(result, ethValue, "values not matching");
        vm.stopPrank();
    }

    /////////////////////////////////////////////////////////////////////////
    //                        _updateShouldUseProtocol                     //
    /////////////////////////////////////////////////////////////////////////

    function testFuzz_ShouldUseProtocol_IsSet(uint256 flagValue) public {
        bool flag = flagValue % 2 == 0;

        vm.expectEmit(true, true, true, true);
        emit Cube3ProtocolConnectionUpdated(flag);
        protectionBaseHarness.updateShouldUseProtocol(flag);
        assertEq(protectionBaseHarness.protectedStorage().shouldCheckFnProtection, flag, "connection not set");
    }
}
