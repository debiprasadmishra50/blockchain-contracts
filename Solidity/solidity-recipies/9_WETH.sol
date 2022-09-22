// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH") {}

    function mint() external payable {
        _mint(msg.sender, msg.value);
    }

    function burn(uint256 _amount) external {
        payable(msg.sender).transfer(_amount);
        _burn(msg.sender, _amount);
    }
}
