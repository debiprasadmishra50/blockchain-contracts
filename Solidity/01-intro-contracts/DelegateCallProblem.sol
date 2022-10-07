// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IC {
    function drive() external;
}

contract A {
    address public addr;

    function demo(address _test)
        external
        returns (bool success, bytes memory data)
    {
        (success, data) = _test.delegatecall(abi.encodeWithSignature("show()"));
    }
}

contract B {
    address public addr;
    address public cAddr;

    function show() external {
        IC(cAddr).drive();
    }

    function setAddr(address _test) external {
        cAddr = _test;
    }
}

contract C {
    address public addr;

    function drive() external {
        addr = msg.sender;
    }
}
