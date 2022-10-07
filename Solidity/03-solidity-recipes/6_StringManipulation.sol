// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract StringManipulation {
    function length(string calldata str) external pure returns (uint256) {
        return bytes(str).length;
    }

    function concat(string calldata str1, string calldata str2)
        external
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(str1, str2));
    }

    function reverse(string calldata _str)
        external
        pure
        returns (string memory)
    {
        bytes memory str = bytes(_str);
        string memory temp = new string(str.length);
        bytes memory _reverse = bytes(temp);

        for (uint256 i = 0; i < str.length; i++) {
            _reverse[str.length - i - 1] = str[i];
        }

        return string(_reverse);
    }

    function compare(string calldata str1, string calldata str2)
        external
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2));
    }
}
