// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dai is ERC20 {
    constructor() ERC20("Dai Stablecoin", "Dai") {
        // _mint(msg.sender, 100 * 10**decimals());
    }

    function faucet(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}

contract MyDeFIProject {
    IERC20 dai;

    constructor(address _dai) {
        dai = IERC20(_dai);
    }

    function transferDai() external {
        // do some stuff
        dai.transfer(msg.sender, 100);
    }
}
