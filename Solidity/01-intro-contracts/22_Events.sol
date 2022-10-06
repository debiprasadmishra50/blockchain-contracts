// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// events allow you to write data into blockchain, can not be retrieved by smart contracts
contract Events {
    event Log(string message, uint256 val);

    // upto 3 indexed params
    event IndexedLog(address indexed sender, uint256 val);

    constructor() {}

    function example() external {
        emit Log("Foo", 1234);

        emit IndexedLog(msg.sender, 1241);
    }

    // Send Message
    event Message(address indexed _from, address indexed _to, string message);

    function sendMessage(address _to, string calldata _message) external {
        emit Message(msg.sender, _to, _message);
    }
}
