// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/* 
    - Why use Delegate Call
        If we use Multicall, the msg.sender will be Multicall Contract, instead of account address
    alice -> multi_call --- call ---> test(msg.sender = multi_call)
        to preserve the state of msg.sender, being an actual user, we need to use delegate call
    alice -> test --- delegatecall ---> test(msg.sender = alice)

    - 
*/

/* 
Deployment
    1. Deploy TestMultiDelegateCall and Helper contract
    2. Get the data for both functions from Helper
    3. pass those values in the multiDelegateCall() of TestMultiDelegateCall
    4. Look at the logs and find the caller, it should be same as the account that called them
*/
contract MultiDelegateCall {
    error DelegateCallFailed();

    function multiDelegateCall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);

        for (uint256 i = 0; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);

            if (!ok) revert DelegateCallFailed();

            results[i] = res;
        }
    }
}

contract TestMultiDelegateCall is MultiDelegateCall {
    event Log(address caller, string func, uint256 i);

    function func1(uint256 x, uint256 y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint256) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    mapping(address => uint256) public balanceOf;

    // BUG:
    // WARNING: unsafe code when used in combination with multi-delegatecall
    // use can mint multiple times for the price of msg.value
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint256 x, uint256 y)
        external
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(TestMultiDelegateCall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.func2.selector);
    }

    function getMintData() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegateCall.mint.selector);
    }
}
