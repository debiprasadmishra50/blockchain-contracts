// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
    Everyone can send ether to this contract
    Only owner can send out the ether from this contract
 */
contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withDraw(uint256 _amount) external {
        require(msg.sender == owner, "caller is not owner");

        // owner.transfer(_amount); // to save gas, do this
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
