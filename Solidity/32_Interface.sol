// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// contract Counter {
//     int public data;

//     function inc() external {
//         data++;
//     }
    
//     function dec() external {
//         data--;
//     }
// }

// Imagine, you do not have access to the Counter Contract Code
// Interface allows you to call other contracts, withour having its code
interface ICounter {
    function count() external view returns (uint);
    function inc() external;
}

// If interface is inherited, then all the functions must be given body or contract must be declared abstract
// contract A is ICounter {
//     function count() external view returns (uint) {
        
//     }

//     function inc() external {
        
//     }
// }

contract CallInterface {
    uint public count;

    function examples(address _counter) external {
        ICounter(_counter).inc();
        count = ICounter(_counter).count();
    }
}