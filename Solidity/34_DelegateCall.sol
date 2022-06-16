// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
Normal Call
    A calls B, sends 100 wei,
        B calls C, sends 50 wei,
A --> B --> C
        msg.sender = B
        msg.value = 50
        execute code on C's state variable
        use ETH in C


Delegate Call
    A calls B, sends 100 wei,
        B delegate call C
A --> B --> C
        msg.sender = A
        msg.value = 100
        execute code on B's state variable
        use ETH in B
 */

// NOTE: Deploy this contract first
contract TestDelegateCall {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) external payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract DelegateCall {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _test, uint _num) external payable {
        // _test.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
        (bool success, bytes memory data) = _test.delegatecall(abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num));

        data;
        require(success, "delegatecall failed");
    }
}

