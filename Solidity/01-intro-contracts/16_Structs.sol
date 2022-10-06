// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Structs {
    struct Car {
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping(address => Car[]) public carsByOwner;

    constructor ( ) {

    }

    function create() external {
        Car memory toyota = Car("Toyota", 1990, msg.sender);
        
        Car memory lambo = Car({
            model: "Lambo", year: 1990, owner: msg.sender
        });

        Car memory tesla;
        tesla.model = "Tesla";
        tesla.year = 2010;
        tesla.owner = msg.sender;

        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);

        cars.push(Car("Ferrari", 2020, msg.sender));

        Car memory _car = cars[0]; // load to stack / RAM
        _car.model;
        _car.year;
        _car.owner;

        Car storage _car2 = cars[0]; // change in HEAP / hard drive
        _car2.year = 2021;
        delete _car2.owner;

        delete cars[1]; // that index struct will reset to default values

    }

}