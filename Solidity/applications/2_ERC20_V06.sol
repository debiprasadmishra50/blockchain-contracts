// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/* 
ERC20
    transfer
    approve, allowance, transferFrom
    https://www.youtube.com/watch?v=xtDkat5f6Hs&list=PLO5VPQH6OWdVfvNOaEhBtA53XHyHo_oJo&index=12
 */

interface IERC20 {
    /*
        returns the total amount of the tokens
     */
    function totalSupply() external view returns (uint256);

    /*
        returns the amount of the tokens that an address holds
     */
    function balanceOf(address account) external view returns (uint256);

    /*
        A Token Holder could call this function to giveaway some of his token to another address

        Alice -> Bob : Directly send tokens/coins
    */
    function transfer(address recipient, uint256 amount)
        external
        view
        returns (bool);

    /*
        allowance, approve and transferFrom are used to allow others to transfer token on behalf of the token holder

        this function returns the amount of tokens that a Spender can spend from a token holder
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /*
        Token Holder calls this function to set the amount of tokens that a spender can spend

        Alice approve Bob to spend X no of coins/tokens
     */
    function approve(address spender, uint256 amount)
        external
        view
        returns (bool);

    /*
        Spender can call this function to send tokens from the token holder to anyone as long as the amount doesn't exceed the approved amount

        Bob is allowed to spend X no of coins/tokens approved by Alice in approve function
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external view returns (bool);

    event Transfer(address indexed from, addres indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

////////////////////////////////////////////////////////////////////////////////

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(tring memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
        // 1 Ether = 10**18 Wei (18 decimals)
        _mint(msg.sender, 100 * 10**uint256(decimals()));
    }
}
