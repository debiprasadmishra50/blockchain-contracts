// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// Transfers ownership
contract Ownable {
    address public owner;

    constructor () {
        owner  = msg.sender;    
    }    

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // only current owner will set a new owner
    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        
        owner = _newOwner;
    }

    function onlyOwnerCanCall() external onlyOwner {
        
    }

    function anyoneCanCall() external {
        
    }
}