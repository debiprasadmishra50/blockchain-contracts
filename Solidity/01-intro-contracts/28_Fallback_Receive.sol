// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
    Fallback is executed when
        - a function does not exist
        - directly send ETH

        ETHer is send to this contract
                    |
            is msg.data empty?
                /     \
              yes     no
              /        \
receive() exists?      fallback()
        /     \
      yes     no
      /        \
  receive()   fallback()

*/
contract Fallback_Receive {
    event Log(string func, address sender, uint256 value, bytes data);

    // fallback() external {}
    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    } // to send ether

    // receive is executed when the data that was sent is empty
    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }
}
