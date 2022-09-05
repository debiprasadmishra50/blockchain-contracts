// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// storage, memory, calldata
contract DataLocation {
    struct MyStruct {
        uint256 foo;
        string text;
    }

    mapping(address => MyStruct) public myStructs;

    constructor() {}

    // function example(uint[] memory y, string[] memory s) external returns (MyStruct memory){
    function example(uint256[] calldata y, string[] calldata s)
        external
        returns (uint256[] memory)
    {
        myStructs[msg.sender] = MyStruct(123, "demo");

        MyStruct storage myStruct = myStructs[msg.sender]; // update the data
        myStruct.text = "foo";

        MyStruct memory readOnly = myStructs[msg.sender]; // read the data
        readOnly.foo = 978;

        // return readOnly;

        _internal(y);
        s;

        uint256[] memory memArr = new uint256[](3);
        memArr[0] = 10;
        memArr[1] = 20;
        memArr[2] = 30;

        return memArr;
    }

    function _internal(uint256[] calldata y) private pure {
        uint256 x = y[0];
        x;
    }
}
