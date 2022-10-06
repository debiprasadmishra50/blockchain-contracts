// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract PiggyBank {
    address payable public owner = payable(msg.sender);

    event Deposit(address depositedBy, uint256 amount);
    event Withdraw(address owner, uint256 amount);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        require(msg.sender == owner, "not owner");
        emit Withdraw(owner, address(this).balance);

        selfdestruct(payable(msg.sender));
    }
}
