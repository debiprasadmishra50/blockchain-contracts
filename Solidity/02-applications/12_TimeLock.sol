// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/* 
    - This is commonly used in DeFI and Dapp
    - Purpose of this contract is to delay a transaction
    - you'll broadcast the transaction you are going to execute and this is done queue()
    - once the transaction is queued, you'll have to wait a certain amount of time defined in a timelock contract, usually from 24 hours to several days
    -  once the time has passed then the function execute() can be called to execute the transaction 
*/

/* 
Deployment
    1. Deploy TimeLock then TestTimeLock and provide the deployed address of TimeLock
    2. queue(), pass the TestTimeLock address, eth to send, func name: test(), and timestamp
    3. execute() with the same parameters
*/
contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint256 blockTimestamp, uint256 timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint256 blockTimestamp, uint256 timestamp);
    error TimeStampExpiredError(uint256 blockTimestamp, uint256 expiresAt);
    error TxFailedError();

    event Queue(
        bytes32 indexed txId,
        address indexed _target,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed _target,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );
    event Cancel(bytes32 indexed txId);

    uint256 public constant MIN_DELAY = 10; // 10 secs
    uint256 public constant MAX_DELAY = 1000; // 1000 secs
    uint256 public constant GRACE_PERIOD = 1000; // 1000 secs

    address public owner;
    mapping(bytes32 => bool) queued;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    function getTxId(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _timestamp
    ) public pure returns (bytes32 txId) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    /* 
        _target: target contract to call
        _value: amount of ether to send
        _func: function to call
        _data: data to pass to the function
        _timestamp: timestamp after which the function/transaction will be executed
    */
    function queue(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _timestamp
    ) external onlyOwner {
        // create a tx ID
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        // check tx is is unique
        if (queued[txId]) {
            revert AlreadyQueuedError(txId);
        }

        // check timestamp >= minimun delay from current time
        // ----|---------------|----------------|--------------
        //    block        block + min      block + max
        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        // queue the tx
        queued[txId] = true;

        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(
        address _target,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _timestamp
    ) external payable onlyOwner returns (bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        // check tx is queued
        if (!queued[txId]) {
            revert NotQueuedError(txId);
        }
        // check current block time > timestamp passed from i/p
        if (block.timestamp < _timestamp) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        // -------|-------------------------------|------------------
        //    timestamp                 timestamp + grace period
        if (block.timestamp > _timestamp + GRACE_PERIOD) {
            revert TimeStampExpiredError(
                block.timestamp,
                _timestamp + GRACE_PERIOD
            );
        }
        //  delete tx from queue
        queued[txId] = false;
        // execute the tx
        bytes memory data;
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            data = _data;
        }

        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if (!ok) revert TxFailedError();

        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        if (!queued[_txId]) revert NotQueuedError(_txId);

        queued[_txId] = false;
        emit Cancel(_txId);
    }
}

contract TestTimeLock {
    address public timelock;

    constructor(address _timelock) {
        timelock = _timelock;
    }

    function test() external view {
        require(msg.sender == timelock);
        // more code here like
        // - upgrade the contract
        // - transfer funds
        // - switch price oracle
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp + 100;
    }
}
