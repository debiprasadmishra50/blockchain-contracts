pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";

contract DaiTokenMock is ERC20Mintable {
    string name;
    string symbol;
    uint256 decimals;

    constructor () public {
        name = "DAI StableCoin (DAI)";
        symbol = "DAI"; 
        decimals = 18;
    }

// ./node_modules/.bin/truffle compile
}









