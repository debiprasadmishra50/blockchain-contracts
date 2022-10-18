// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Token {
    function transfer(uint256 _amount, address _to) external {
        // transfer tokens
    }
}

contract A {
    // Token token;
    Registry registry;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // function updateToken(address _tokenAddress) external {
    //     require(msg.sender == owner);
    //     token = Token(_tokenAddress);
    // }
    function updateRegistry(address _registryAddress) external {
        require(msg.sender == owner);
        registry = Registry(_registryAddress);
    }

    function foo() external {
        Token token = Token(registry.tokens("ABC"));
        token.transfer(100, msg.sender);
    }
}

contract B {
    // Token token;
    Registry registry;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // function updateToken(address _tokenAddress) external {
    //     require(msg.sender == owner);
    //     token = Token(_tokenAddress);
    // }
    function updateRegistry(address _registryAddress) external {
        require(msg.sender == owner);
        registry = Registry(_registryAddress);
    }

    function foo() external {
        Token token = Token(registry.tokens("ABC"));
        token.transfer(100, msg.sender);
    }
}

/* Centralized management of contract addresses */
contract Registry {
    // identify smart contract => updated smart contract address
    mapping(string => address) public tokens;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function updateToken(string calldata _id, address _tokenAddress) external {
        require(msg.sender == owner);
        tokens[_id] = _tokenAddress;
    }
}
