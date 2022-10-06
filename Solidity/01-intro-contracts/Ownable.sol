// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setOwner(address _newOwner) external {
        require(_newOwner != address(0), "Invalid Address");
        owner = _newOwner;
    }

    function onlyOwnerCanCall() external onlyOwner {}

    function anyonwCanCall() external {}
}
