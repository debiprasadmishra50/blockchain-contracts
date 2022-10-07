// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract CallTestContracts {
    // function setX(address _test, uint _x) external {
    //     TestContract(_test).setX(_x);
    function setX(TestContract _test, uint256 _x) external {
        _test.setX(_x);
    }

    function getX(TestContract _test) external view returns (uint256) {
        return _test.getX();
    }

    function setXandSendEther(TestContract _test, uint256 _x) external payable {
        _test.setXandReceiveEther{value: msg.value}(_x);
    }

    function getXandValue(TestContract _test)
        external
        view
        returns (uint256, uint256)
    {
        (uint256 x, uint256 value) = _test.getXandValue();

        return (x, value);
    }
}

contract TestContract {
    uint256 public x;
    uint256 public value = 123;

    function setX(uint256 _x) external {
        x = _x;
    }

    function getX() external view returns (uint256) {
        return x;
    }

    function setXandReceiveEther(uint256 _x) external payable {
        x = _x;
        value = msg.value;
    }

    function getXandValue() external view returns (uint256, uint256) {
        return (x, value);
    }
}
