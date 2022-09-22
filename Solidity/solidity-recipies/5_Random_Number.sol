// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Oracle {
    address owner;
    uint256 public rand;

    constructor() {
        owner = msg.sender;
    }

    function feedRandomness(uint256 _rand) external {
        require(msg.sender == owner);
        rand = _rand;
    }
}

contract RandomNumber {
    Oracle oracle;
    uint256 nonce;

    constructor(address _oracle) {
        oracle = Oracle(_oracle);
    }

    function random(uint256 _mod) external returns (uint256) {
        return _randModulus(_mod);
    }

    function _randModulus(uint256 mod) internal returns (uint256 rand) {
        rand =
            uint256(
                keccak256(
                    abi.encodePacked(
                        nonce,
                        oracle.rand(),
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) %
            mod;

        nonce++;
    }
}
