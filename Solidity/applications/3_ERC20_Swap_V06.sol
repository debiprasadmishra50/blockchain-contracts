// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/* 
BeforeSwap
    AliceCoin                       BobCoin
    Alice: 100                      Alice: 0
    Bob: 0                          Bob: 100

AfterSwap
    AliceCoin                       BobCoin
    Alice: 90                      Alice: 20
    Bob: 10                        Bob: 80

    Require another TokenSwap contract to handle the both transactions simultaneously

    1. Alice approves Swap to spend 10 tokens
    2. Bob approves Swap to spend 20 tokens
    3. Now Swap has allowance of 10 from Alice and 20 from Bob
    4. Swap will call swap()
    5. it will transferFrom(Alice, Bob, 10)
    6. it will transferFrom(Bob, Alice, 20)
    7. Make the allowance of each of them with Swap 0
    
*/

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Swap {
    IERC20 public token1;
    address public owner1;
    IERC20 public token2;
    address public owner2;

    constructor(
        address _token1,
        address _owner1,
        address _token2,
        address _owner2
    ) {
        token1 = IERC20(_token1);
        owner1 = _owner1;
        token2 = IERC20(_token2);
        owner2 = _owner2;
    }

    /* 
        _amount1: owner1's token1 amount to owner2
        _amount2: owner2's token2 amount to owner1
    */
    function swap(uint256 _amount1, uint256 _amount2) public {
        require(msg.sender == owner1 || msg.sender == owner2, "Not Authorized");
        // check amount from owner1 to be sent to owner2
        require(
            token1.allowance(owner1, address(this)) >= _amount1,
            "Token 1 allowance too low"
        );
        // check amount from owner2 to be sent to owner1
        require(
            token2.allowance(owner2, address(this)) >= _amount2,
            "Token 2 allowance too low"
        );

        // transfer tokens
        // token1, owner1, amount1 -> owner2 : amount1 of token1 from owner1 to owner2
        _safeTransferFrom(token1, owner1, owner2, _amount1);
        // token2, owner2, amount2 -> owner1 : amount2 of token2 from owner2 to owner1
        _safeTransferFrom(token2, owner2, owner1, _amount2);
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}

/* 
    token1: 0xd9145CCE52D386f254917e481eB44e9943F39138
    owner1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 : Alice

    token2: 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95
    owner2: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 : Bob

    Swap: 0x652c9ACcC53e765e1d96e2455E618dAaB79bA595

    100000000000000000000 ; 100 tokens in all
    swap of 10 and 20 tokens
    10000000000000000000
    20000000000000000000

 */
