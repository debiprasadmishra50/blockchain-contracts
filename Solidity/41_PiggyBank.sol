// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract PiggyBank {
    address public owner = msg.sender;

    event Deposit(uint amount);
    event Withdraw(uint amount);

    receive() external payable {
        emit Deposit(msg.value);
    }


    function withdraw() external {
        require(msg.sender == owner, "not owner");

        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}