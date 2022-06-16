// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
public - any contract and account can call
private - only inside the contract that defines the function
internal- only inside contract that inherits an internal function
external - only other contracts and accounts can call

State variables can be declared as public, private, or internal but not external.

 */
contract Visibility {
    uint private x = 0;
    uint internal y = 0;
    uint public z = 0;
    // uint external a = 0; // not possible

    function pri() private pure returns (string memory) {
        return "private called";
    }
    function inter() internal pure returns (string memory) {
        return "internal called";
    }
    function extern() external pure returns (string memory) {
        return "external called";
    }
    function pub() public pure returns (string memory) {
        return "public called";
    }

    function example() external view {
        x + y + z;

        pri();
        inter();
        pub();
        
        // extern(); not possible
        // this.extern(); // possible but gas in-efficient, not recommended


    }

}

contract Child is Visibility {
    constructor () {
        super.pub();
        super.inter();

        // super.pri();
        // super.extern();
    }

    function example2() external view {
        y + z;

        inter();
        pub();
    }
}