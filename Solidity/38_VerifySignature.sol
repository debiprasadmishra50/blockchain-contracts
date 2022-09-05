// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
Steps to 
    0. message to sign
    1. hash(message)
    2. sign(hasn(message), private key) | offchain
    3. ecrecover(hasn(message), signature) == signer
*/
contract VerifySignature {
    // prettier-ignore
    /*
        _signer: who will sign the message
        _message: the message to sign
        _sig: signature
    */
    function verify(address _signer, string calldata _message, bytes calldata _sig) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);

        bytes32 ethSignedMessageHash = getEthSignedMessage(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    // prettier-ignore
    function getMessageHash(string calldata _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    // prettier-ignore
    function getEthSignedMessage(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    // prettier-ignore
    function recover(bytes32 _ethSignedMessageHash, bytes calldata _sig) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // prettier-ignore
    // uint8 is 8bits
    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) { 
        // check if _sig length is 65 because 32 + 32 + 1
        require(_sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(_sig, 32)) // skip the first 32 bytes because it holds length of array
            s := mload(add(_sig, 64)) // skip the first 64 bytes because it holds length and r value
            v := byte(0, mload(add(_sig, 96))) // get first byte i.e., 8 bits
        }

        // return (r, s, v);
    }
}
