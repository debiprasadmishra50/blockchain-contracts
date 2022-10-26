import * as dotenv from "dotenv";
dotenv.config({ path: ".env" });

// work with Web3
import Web3 from "web3";
import * as lib from "./utils/web3";

let web3: Web3;

const account = process.env.ADDRESS;
const privateKey = process.env.PRIVATE_KEY;
const explorerURI = "https://goerli.etherscan.io/tx";
web3 = lib.initWeb3(`https://goerli.infura.io/v3/${process.env.INFURA_KEY}`);
web3.eth.accounts.wallet.add(privateKey);

const app = async () => {
  //
};

// app();
