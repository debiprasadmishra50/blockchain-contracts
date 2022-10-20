import * as dotenv from "dotenv";
dotenv.config({ path: ".env" });

import Web3 from "web3";
import * as lib from "./utils/web3";

let web3: Web3;

const account = process.env.ADDRESS;
const privateKey = process.env.PRIVATE_KEY;
const explorerURI = "https://goerli.etherscan.io/tx";
web3 = lib.initWeb3(`https://goerli.infura.io/v3/${process.env.INFURA_KEY}`);
web3.eth.accounts.wallet.add(privateKey);

const factoryAddress = "0x6Ce570d02D73d4c384b46135E87f8C592A8c86dA";
import { factoryABI, exchangeABI, tokenABI } from "../abis/UniSwapV1.json";
import { AbiItem } from "web3-utils";

const app = async () => {
  const factoryContract = new web3.eth.Contract(factoryABI as AbiItem[], factoryAddress);

  let tokenAddress = "0x0986e16d2dA070F40584a311C19a359b03d8e30F";
  const exchangeAddress = await factoryContract.methods.getExchange(tokenAddress).call();
  console.log(exchangeAddress); // 0x0000000000000000000000000000000000000000 means there is not exchange assigned

  const exchangeContract = new web3.eth.Contract(exchangeABI as AbiItem[], exchangeAddress);

  tokenAddress = factoryContract.methods.getToken(exchangeAddress);
};
// freshdesk
// e-shops

// app();
