// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract HelloWorld {
    string public myString = "Hello World";

    // Data types: values and reference
    bool public b = true;
    uint public num = 10; // number can be >= 0
    int public integer = 101; // number can be -ve or +ve

    int public minInt = type(int).min;
    int public maxInt = type(int).max;

    ufixed public no = 1.1;
    fixed public nof = 1.1;

    address public addr = 0x46AE8ae37D9953487b47b9cda4D5A17B2CD5143B;

    // like final variable in java
    address public constant MY_ADDRESS = 0x46AE8ae37D9953487b47b9cda4D5A17B2CD5143B;
    uint public constant MY_UINT = 123;

    // exactly like final variable in java, immutable but value can be set inside constructor
    address public immutable ADDR; 
    uint public immutable NUM;

    constructor(uint _myUint) {
        ADDR = msg.sender;
        NUM = _myUint;
    }

    bytes32 public b32 = 0x7191562705627056272609612792cabab749817213953281562783937752589a; // 64 bit no
    // used in keccak cryptographic functions

    // Default values
    // Unassigned variables have a default value
    bool public defaultBoo; // false
    uint public defaultUint; // 0
    int public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000
    // one ether is equal to 10^18 wei.
}
