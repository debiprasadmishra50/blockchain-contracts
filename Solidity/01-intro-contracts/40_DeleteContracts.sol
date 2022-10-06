// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
    selfdestruct
    delete contract
    force send ether to any address
*/
contract DeleteContract {
    constructor() payable {}

    function kill() external {
        selfdestruct(payable(msg.sender));
    }

    function testCall() external pure returns (uint256) {
        return 123;
    }
}

contract Helper {
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function kill(DeleteContract _kill) external {
        _kill.kill();
    }
}
