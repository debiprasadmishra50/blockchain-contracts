// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// in error, gas gets refunded
contract ErrorDemo {
    function testRequire(uint _i) public pure {
        require(_i <= 10, "_i > 10");

        // code
    }

    function testRevert(uint _i) public pure {
        if (_i > 10) {
            revert("_i > 10");
        }

        // code
    }

    uint public num = 123;
    function testAssert() public view {
        assert(num == 123); // check if the condition is true or not
    }

    // custom Error
    error MyError(address caller, uint i);
    function testCustom(uint _i) public view {
        if (_i > 10) {
            revert MyError(msg.sender, _i);
        }
    }
}