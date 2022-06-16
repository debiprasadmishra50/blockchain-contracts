// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
    3 ways to send ether
        1. transfer (2300 gas), reverts
        2. send (2300 gas), returns bool
        3. call (all gas), returns bool and data

*/

contract SendETH {
    constructor ( ) payable {

    }

    // fallback() external payable {}
    receive() external payable {}

    function sendEtherViaTranfser(address payable _to) external payable {
        _to.transfer(123);
    }

    function sendEtherViaSend(address payable _to) external payable {
        bool sent = _to.send(123);

        require (sent, "send failed");
    }

    function sendEtherViaCall(address payable _to) external payable {
        (bool success, bytes memory data) = _to.call{value: 123}("");

        data;
        require(success, "call failed");
    }

}

contract EthReceiver {
    event Log(uint amount, uint gas);

    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}