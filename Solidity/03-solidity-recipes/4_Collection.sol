// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;
pragma experimental ABIEncoderV2;

contract Collections {
    // struct User {
    //     uint256 id;
    //     string name;
    // }
    struct User {
        address userAddress;
        uint256 balance;
    }
    User[] users;

    mapping(uint256 => User) usersMap;

    uint256 nextUserId;

    function getUsers1()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        address[] memory userAddresses = new address[](users.length);
        uint256[] memory userBalances = new uint256[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            userAddresses[i] = users[i].userAddress;
            userBalances[i] = users[i].balance;
        }

        return (userAddresses, userBalances);
    }

    /* Use this to return struct array */
    function getUsers2() external view returns (User[] memory) {
        return users;
    }
}
