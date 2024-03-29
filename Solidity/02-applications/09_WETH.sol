// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/* 
    A single contract to support both ETH and ERC20
*/

/* 
    1. Deploy WETH
    2. execute deposit and send 1 ether
    3. check balanceOf and check with the owner address
    4. execute withdraw and check again
*/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH") {}

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);

        emit Withdraw(msg.sender, _amount);
    }
}
