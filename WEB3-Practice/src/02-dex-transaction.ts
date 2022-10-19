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

const DAI_TOKEN = "0xf2edF1c091f683E3fb452497d9a98A49cBA84666";
import { DAI as DAI_ABI } from "../abis/DAI.json";
const daiContract = lib.getContractInstance(DAI_ABI, DAI_TOKEN);
/* 
  In Uniswap exchange ETH with DAI and have some on them to make successful transaction
*/
const app = async () => {
  const latestBlockNumber = await web3.eth.getBlockNumber();
  console.log(latestBlockNumber);

  // check ether balance
  let bal = await web3.eth.getBalance(account);
  console.log(`[+] ${account} has`, lib.fromWei(bal), "ether");

  // check DAI balance
  let daiBalance = await daiContract.methods.balanceOf(account).call();
  console.log(`[+] ${account} has`, daiBalance, "DAI");

  const to = "0x62af1bf552347b7baac5ce78790e75e19f2d77a0";
  const amount = lib.toWei("1");
  try {
    const result = await daiContract.methods.transfer(to, amount).send({
      from: account,
      gasLimit: 6000000,
      gasPrice: lib.toWei("1", "Gwei"),
    });
    console.log("[+] successful transaction:", `${explorerURI}/${result.transactionHash}`);
  } catch (err) {
    console.log(err);
  }

  // check ether balance
  bal = await web3.eth.getBalance(account);
  console.log(`[+] ${account} has`, lib.fromWei(bal), "ether");

  // check DAI balance
  daiBalance = await daiContract.methods.balanceOf(account).call();
  console.log(`[+] ${account} has`, daiBalance, "DAI");
};
// freshdesk
// e-shops

app();
