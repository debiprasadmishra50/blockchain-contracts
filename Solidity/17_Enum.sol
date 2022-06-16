// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Enum {
    enum Status { None, Pending, Shipped, Completed, Rejected, Cancelled }

    Status public status;

    struct Order {
        address buyer;
        Status status;
    }

    Order[] public orders;

    constructor ( ) {
    }

    function get() external view returns (Status) {
        return status;
    }

    function set(Status _status) external {
        status = _status;
    }

    function ship() external {
        status = Status.Shipped;
    }

    function reset() external {
        delete status; // default value is the first Enum value: None
    }

}