import express, { Request, Response } from "express";
import morgan from "morgan";
import { Blockchain } from "./blockchain";
import PubSub from "./app/pubsub";
import axios from "axios";

const app = express();
const blockchain = new Blockchain();
const pubSub = new PubSub({ blockchain });

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

const syncChains = async () => {
  const res = await axios.get(`${ROOT_NODE_ADDRESS}/api/blocks`);

  if (res && res.status === 200) {
    const rootChain = res.data;

    console.log("replace chain on a sync with", rootChain);
    blockchain.replaceChain(rootChain);
  }
};
let PEER_PORT;

if (process.env.GENERATE_PEER_PORT === "true") {
  PEER_PORT = DEFAULT_PORT + Math.ceil(Math.random() * 1000);
}

const PORT = PEER_PORT || DEFAULT_PORT;
app.listen(PORT, () => {
  console.log(`[+] Listening at localhost:${PORT}`);

  if (PORT !== DEFAULT_PORT) syncChains();
});
