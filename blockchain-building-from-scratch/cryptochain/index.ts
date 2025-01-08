import express, { Request, Response } from "express";
import morgan from "morgan";
import { Blockchain } from "./blockchain";
import PubSub from "./app/pubsub";
import axios from "axios";
import TransactionPool from "./wallet/transaction-pool";
import Wallet from "./wallet";

const app = express();
const blockchain = new Blockchain();
const transactionPool = new TransactionPool();
const wallet = new Wallet();
const pubSub = new PubSub({ blockchain, transactionPool });

const DEFAULT_PORT = 3000;
const ROOT_NODE_ADDRESS = `http://localhost:${DEFAULT_PORT}`;

// setTimeout(() => {
//   pubSub.broadcastChain();
// }, 1000);

app.use(morgan("dev"));
app.use(express.urlencoded({ extended: true, limit: "10kb" }));
app.use(express.json({ limit: "10kb" }));

app.get("/api/blocks", (req: Request, res: Response) => {
  res.json(blockchain.chain);
});

app.post("/api/mine", (req: Request, res: Response) => {
  const { data } = req.body;

  blockchain.addBlock({ data });

  pubSub.broadcastChain();

  res.redirect("/api/blocks");
});

app.post("/api/transact", (req, res) => {
  const { amount, recipient } = req.body;

  let transaction = transactionPool.existingTransaction({ inputAddress: wallet.publicKey });

  try {
    if (transaction) {
      transaction.update({ senderWallet: wallet, recipient, amount });
    } else {
      transaction = wallet.createTransaction({ recipient, amount });
    }
  } catch (err: any) {
    res.status(400).json({ type: "error", message: err.message });
  }

  transactionPool.setTransaction(transaction);

  // console.log("transactionPool", transactionPool);

  pubSub.broadcastTransaction(transaction);

  res.json({ type: "success", transaction });
});

app.get("/api/transaction-pool-map", (req, res) => {
  res.json(transactionPool.transactionMap);
});

const syncWithRoots = async () => {
  const res = await axios.get(`${ROOT_NODE_ADDRESS}/api/blocks`);

  if (res && res.status === 200) {
    const rootChain = res.data;

    console.log("\nreplace chain on a sync with", rootChain);
    blockchain.replaceChain(rootChain);
  }

  const rootTransactionPoolMap = (await axios.get(`${ROOT_NODE_ADDRESS}/api/transaction-pool-map`)).data;

  console.log("\nreplacing transaction pool on a sync with", rootTransactionPoolMap);
  transactionPool.setMap(rootTransactionPoolMap);
};

let PEER_PORT;

if (process.env.GENERATE_PEER_PORT === "true") {
  PEER_PORT = DEFAULT_PORT + Math.ceil(Math.random() * 1000);
}

const PORT = PEER_PORT || DEFAULT_PORT;
app.listen(PORT, () => {
  console.log(`[+] Listening at localhost:${PORT}`);

  if (PORT !== DEFAULT_PORT) syncWithRoots();
});
