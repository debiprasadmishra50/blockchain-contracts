const { BigNumber, ethers, utils } = require("ethers");
const axios = require("axios");
const Web3 = require("web3");
const Big = require("big.js");

const isProd = process.env.NODE_ENV === "production";
const API_TOKEN = "7bff5a61-359f-454f-833e-b40ddaa7db20";
const API_URL = `https://bsc.getblock.io/${isProd ? "mainnet" : "testnet"}/`;
const web3 = new Web3(`${API_URL}?api_key=${API_TOKEN}`);

async function getTransaction(hash) {
  const result = await axios.post(`${API_URL}?api_key=${API_TOKEN}`, {
    id: 0,
    jsonrpc: "2.0",
    method: "eth_getTransactionByHash",
    params: [hash],
  });

  const { data } = result;
  const transaction = data.result;

  // @ts-ignore
  transaction.value = Big(BigNumber.from(transaction.value)).toString();
  // @ts-ignore
  transaction.gasPrice = Big(BigNumber.from(transaction.gasPrice)).toString();
  // @ts-ignore
  transaction.nonce = Big(BigNumber.from(transaction.nonce)).toString();
  // @ts-ignore
  transaction.gas = Big(BigNumber.from(transaction.gas)).toString();
  transaction.fees = Big(transaction.gas * transaction.gasPrice).toString();

  return transaction;
}

function getSigner(pathindex) {
  // NOTE: This path is for Ethereum
  // change this depending on the network
  let derivationPath = `m/44'/60'/0'/0/`;
  let mnemonic = process.env.MNEMONIC || "";
  const wallet = ethers.Wallet.fromMnemonic(
    mnemonic,
    `${derivationPath}${pathindex}`
  );

  const signer = wallet.privateKey.slice(2);
  return signer;
}

async function signTransaction(txObject, pathindex) {
  const signer = new ethers.Wallet(getSigner(pathindex));

  const signedTx = await signer.signTransaction(txObject);

  return signedTx;
}

async function getGasPrice() {
  const rpc_data = {
    jsonrpc: "2.0",
    method: "eth_gasPrice",
    params: [],
    id: 53,
  };
  const result = await axios.post(`${API_URL}?api_key=${API_TOKEN}`, rpc_data);

  const { data } = result;
  const gasPrice = web3.utils.hexToNumber(data.result).toString();

  return gasPrice;
}

async function sendTransaction(from, to, amount, pathindex) {
  const nonce = await web3.eth.getTransactionCount(from);
  const gasPrice = await getGasPrice();

  const txObject = {
    nonce: web3.utils.toHex(nonce),
    chainId: 1, // to be set based on the chain
    from,
    to,
    value: utils.hexlify(BigNumber.from(amount)),
    gasLimit: utils.hexlify(21000),
    gasPrice: utils.hexlify(BigNumber.from(gasPrice)),
  };

  const signedTx = await signTransaction(txObject, pathindex);

  const result = await axios.post(`${API_URL}?api_key=${API_TOKEN}`, {
    jsonrpc: "2.0",
    method: "eth_sendRawTransaction",
    params: [signedTx],
    id: 1,
  });

  const { data } = result;
  console.log("🚀 ~ file: sendBnb.ts ~ line 67 ~ sendTransaction ~ data", data);

  return data.result;
}

async function sendCrypto(props) {
  // const from = ethers.Wallet.fromMnemonic(
  //   process.env.WITHDRAW_MNEMONIC || "",
  //   "m/44'/60'/0'/1/0"
  // ).address;

  const txnHash = await sendTransaction(
    props.from,
    props.to,
    props.amount.toString(),
    props.pathIndex
  );
  console.log("🚀 ~ file: sendBnb.ts ~ line 124 ~ txnHash", txnHash);

  const txn = await getTransaction(txnHash);
  console.log("🚀 ~ file: sendBnb.ts ~ line 126 ~ txn", txn);
}
