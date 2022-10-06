// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract SafeMath {
    function testUnderflow() public pure returns (uint256) {
        uint256 x = 0;

        x--;
        return x; // will cause error
    }

    // if we want to overflow or underflow without any errors
    function testUncheckedUnderflow() public pure returns (uint256) {
        uint256 x = 0;

        unchecked {
            x--;
        }
        return x; // will NOT cause error
    }
}

// can be declared outside of contract and can be imported by another contract
error Unauthorized(address caller);

function helper(uint256 x) pure returns (uint256) {
    return x * 2;
}

contract CustomError {
    address payable public owner = payable(msg.sender);

    error UnauthorizedCaller(address caller);

    function withdraw() public {
        if (msg.sender != owner)
            // revert("error"); // amount of gas depends on length of string
            revert Unauthorized(msg.sender); // cheap gas

        owner.transfer(address(this).balance);
    }
}

import {Unauthorized, helper} from "./47_NewFeatures.sol"; // list ES6 import statement

contract Import {}
