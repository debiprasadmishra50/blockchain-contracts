pragma solidity ^0.5.11;

/* 
Multi Sig Wallet
    - A Multi Sig Wallet is a multi-signature wallet which has multiple owners.
    - To spend from this wallet an owner will need to get permission/approval from other owners 
    Owners:
    ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]

    Receiver: 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,1000000000000000000

 */
contract MultiSigWallet {
    // Emitted when ETH is deposited in the contract
    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    address[] public owners; // store the owners
    mapping(address => bool) public isOwner; // check for duplicate owners
    uint256 public noOfConfirmationsRequired; // number of owner confirmations required to proceed with the transaction
    struct Transaction {
        address to; // recipient
        uint256 value; // amount of ETH
        bytes data; // Tx data that to be send to that contract
        bool executed; // whether the transaction is executed or not
        mapping(address => bool) isConfirmed; // when owner approved a transaction, they go inside the mapping
        uint256 noOfConfirmations; // number of approvals
    }
    Transaction[] public transactions;

    constructor(address[] memory _owners, uint256 _noOfconfirmationsRequired)
        public
    {
        require(_owners.length > 0, "owners required");
        require(
            _noOfconfirmationsRequired > 0 &&
                _noOfconfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        noOfConfirmationsRequired = _noOfconfirmationsRequired;
    }

    function() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /* helper function to easily deposit in Remix */
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }
    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }
    modifier notConfirmed(uint256 _txIndex) {
        require(
            !transactions[_txIndex].isConfirmed[msg.sender],
            "tx already confirmed"
        );
        _;
    }

    /* 
        The owner will have to propose a transaction that has to be approved by other owners
     */
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes memory _data
    ) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                noOfConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    /* 
        The owners can confirm the transaction by calling confirmTransaction
     */
    function confirmTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        transaction.isConfirmed[msg.sender] = true;
        transaction.noOfConfirmations += 1;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    /* 
        If enough owners approve the transaction, they can call executeTransaction 
     */
    function executeTransaction(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.noOfConfirmations >= noOfConfirmationsRequired,
            "can't execute transaction"
        );

        transaction.executed = true;
        (bool success, ) = transaction.to.call.value(transaction.value)(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    /* 
        if the owner decides to cancel the confirmation, he can call this function
     */
    function revokeConfirmation(uint256 _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(transaction.isConfirmed[msg.sender], "tx not confirmed");

        transaction.isConfirmed[msg.sender] = false;
        transaction.noOfConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }
}

/* 
    1. Deploy the contract
    2. Execute getData method
    3. pass the deployed address, 0, data from getData to submitTransaction method and execute
 */
contract TestContract {
    uint256 public i;

    /* 
        Multi sig wallet will call this function and update the state variable
    */
    function callMe(uint256 j) public {
        i += j;
    }

    function getData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("callMe(uint256)", 123);
    }
}
