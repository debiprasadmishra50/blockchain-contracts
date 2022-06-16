/////////////////// Testing with Mocha//////////////////
class Car {
    park() {
        return "stopped";
    }

    drive() {
        return "vroom";
    }
}

let car;
beforeEach("Car setup", () => {
    car = new Car();
});

describe("Car", () => {
    it("car parking", () => {
        // const car = new Car();

        assert.equal(car.park(), "stopped");
        // assert.equal(car.park(), "stoppedd");
    });

    it("car drive", () => {
        // const car = new Car();

        assert.equal(car.drive(), "vroom");
    });
});
