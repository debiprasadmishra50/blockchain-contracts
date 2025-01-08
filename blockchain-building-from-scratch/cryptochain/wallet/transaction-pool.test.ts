import TransactionPool from "./transaction-pool";
import Transaction from "./transaction";
import Wallet from "./index";

describe("TransactionPool", () => {
  let transactionPool: TransactionPool, transaction: Transaction, senderWallet: Wallet;

  beforeEach(() => {
    transactionPool = new TransactionPool();
    senderWallet = new Wallet();
    transaction = new Transaction({
      senderWallet,
      recipient: "fake-recipient",
      amount: 50,
    });
  });

  describe("setTransaction()", () => {
    it("adds a transaction", () => {
      transactionPool.setTransaction(transaction);

      expect(transactionPool.transactionMap[transaction.id]).toBe(transaction);
    });
  });

  describe("existingTransaction", () => {
    it("returns an exusting transaction given an input address", () => {
      transactionPool.setTransaction(transaction);

      expect(transactionPool.existingTransaction({ inputAddress: senderWallet.publicKey })).toBe(transaction);
    });
  });
});
