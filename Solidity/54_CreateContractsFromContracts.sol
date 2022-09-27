// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Car {
    string public model;
    address public owner;

    constructor(string memory _model, address _owner) payable {
        model = _model;
        owner = _owner;
    }
}

contract CarFactory {
    Car[] public cars;

    function create(address _owner, string memory _model) public {
        // Car car = new Car(_model, _owner);
        Car car = new Car(_model, address(this));
        cars.push(car);
    }

    function createAndSendEther(address _owner, string memory _model)
        public
        payable
    {
        Car car = (new Car){value: msg.value}(_model, _owner);
    }
}
