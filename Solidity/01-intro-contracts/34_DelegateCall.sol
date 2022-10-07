// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
Normal Call
    A calls B, sends 100 wei,
        B calls C, sends 50 wei,
A --> B --> C
    Inside C
        msg.sender = B
        msg.value = 50
        execute code on C's state variable
        use ETH in C


Delegate Call
    A calls B, sends 100 wei,
        B delegate call C
A --> B --> C
    Inside C
        msg.sender = A
        msg.value = 100
        execute code on B's state variable
        use ETH in B
 */

// NOTE: Deploy this contract first
contract TestDelegateCall {
    // NOTE: storage layout must be the same as contract A
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) external payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract DelegateCall {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(address _test, uint256 _num) external payable {
        // _test.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num)); // one way
        (bool success, bytes memory data) = _test.delegatecall(
            abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num)
        );

        data;
        require(success, "delegatecall failed");
    }
}

/* 
    we just executed the TestDelegateCall.setVars function and updated the DelegateCall state variables 

    using delegate call we can update the DelegateCall Contract
    state variables will be the same but the code that we are executing can be updated 
    which means we can update the DelegateCall contract even though this contract is deployed
    
 */
