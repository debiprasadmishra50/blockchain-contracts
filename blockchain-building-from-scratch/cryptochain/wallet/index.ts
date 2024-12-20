import { STARTING_BALANCE } from "../config";
import ec, { KeyPair, sha256 } from "../utils";
import Transaction from "./transaction";

type TransactionParameterType = {
  recipient: string;
  amount: number;
};

class Wallet {
  readonly balance: number;
  readonly publicKey: string;
  keyPair: KeyPair;

  constructor() {
    this.balance = STARTING_BALANCE;

    this.keyPair = ec.genKeyPair();
    this.publicKey = this.keyPair.getPublic().encode("hex", true);
  }

  sign(data: any) {
    return this.keyPair.sign(sha256(data));
  }

  createTransaction({ recipient, amount }: TransactionParameterType) {
    if (amount > this.balance) {
      throw new Error("Amount exceeds balance");
    }

    return new Transaction({ senderWallet: this, recipient, amount });
  }
}

export default Wallet;
