import Transaction from "./transaction";

class TransactionPool {
  transactionMap: {
    [id: string]: Transaction;
  };

  constructor() {
    this.transactionMap = {};
  }

  setTransaction(transaction: any) {
    // console.log(transaction);

    this.transactionMap[transaction.id] = transaction;
  }

  setMap(rootTransactionPoolMap: any) {
    this.transactionMap = rootTransactionPoolMap;
  }

  existingTransaction({ inputAddress }: { inputAddress: string }): Transaction | undefined {
    const transactions = Object.values(this.transactionMap);

    const transaction = transactions.find((transaction) => transaction.input.address === inputAddress);

    return transaction;
  }
}

export default TransactionPool;
