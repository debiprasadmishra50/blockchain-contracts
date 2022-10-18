// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
    1. Deploy the Factory contract
    2. execute getBytecode: arguments are owner adderss and a random value as salt
    3. execute getAddress: paste the bytecode and random no as salt
    4. execute deploy: paste the bytecode and same random from getAddress no as salt
    5. The event Deployed from logs and the address from getAddress must be same
*/

contract Factory {
    event Deployed(address addr, uint256 salt);

    // 1. get bytecode of contract to be deployed
    /* 
    Types of ByteCode:
        creationCode: the bytecode that is used to deploy the contract
        runtimeCode: the bytecode that is executed when you call function on contract
    */
    function getBytecode(address _owner, uint256 _foo)
        public
        pure
        returns (bytes memory)
    {
        bytes memory bytecode = type(TestContract).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner, _foo));
    }

    // 2. Compute the address of the contract to be deployed
    // keccak256(0xff + sender address + salt + keccak256(cretion code))
    // take last 20 bytes
    function getAddress(bytes memory bytecode, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    // 3. Deploy the contract
    function deploy(bytes memory bytecode, uint256 _salt) public payable {
        address addr;

        /* 
            How to call create2
            create2(v, p, n, s)
            v - amount of ETH to send
            p - pointer to start of code in memory
            n - size of code
            s - salt
        */

        assembly {
            addr := create2(
                callvalue(), // msg.value inside assembly, wei sent with current call
                // actual code starts after skipping the first 32 bytes
                add(bytecode, 0x20),
                mload(bytecode), // load the size of the code contained in the first 32 bytes
                _salt // Salt from function args
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        emit Deployed(addr, _salt);
    }
}

contract TestContract {
    address public owner;
    uint256 public foo;

    constructor(address _owner, uint256 _foo) payable {
        owner = _owner;
        foo = _foo;
    }

    function getbalance() public view returns (uint256) {
        return address(this).balance;
    }
}
