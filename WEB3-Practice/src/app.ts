import * as dotenv from "dotenv";
import deployAndSave from "./scripts/deploy";
dotenv.config({ path: ".env" });

// work with Web3
import Web3 from "web3";
import * as lib from "./utils/web3";

let web3: Web3;

const account = process.env.ADDRESS;
const privateKey = process.env.PRIVATE_KEY;
// const explorerURI = "https://goerli.etherscan.io/tx";
// web3 = lib.initWeb3(`https://goerli.infura.io/v3/${process.env.INFURA_KEY}`);
web3 = lib.initWeb3();
web3.eth.accounts.wallet.add(privateKey);

const app = async () => {
  // Deploy a Contract
  const deployedAddress = await deployAndSave("01_Intro.sol", "Intro");

  //   lib.getContractABI("01_Intro.sol", "Intro");
  console.log(await web3.eth.getBlockNumber());
  console.log(await lib.getAccounts());
};

// app();

//// -------------------------------------------- ////
import { Intro } from "../abis/Intro.json";
import { deployedAddress } from "../abis/address/Intro-contract-address.json";
const connect = async () => {
  const contract = lib.getContractInstance(Intro.abi, deployedAddress);

  const name = await contract.methods.name().call();
  console.log(name);
};

connect();
