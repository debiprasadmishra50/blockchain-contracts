import Web3 from "web3";
import solc from "solc";
import smtchecker from "solc/smtchecker";
import smtsolver from "solc/smtsolver";
import * as path from "path";
import fs from "fs";

let web3: Web3;

type Unit =
  | "noether"
  | "wei"
  | "kwei"
  | "Kwei"
  | "babbage"
  | "femtoether"
  | "mwei"
  | "Mwei"
  | "lovelace"
  | "picoether"
  | "gwei"
  | "Gwei"
  | "shannon"
  | "nanoether"
  | "nano"
  | "szabo"
  | "microether"
  | "micro"
  | "finney"
  | "milliether"
  | "milli"
  | "ether"
  | "kether"
  | "grand"
  | "mether"
  | "gether"
  | "tether";

/**
 * Initialize web3 and return {@link Web3} instance
 * @param uri RPC url to connect to
 * @default "http://127.0.0.1:8545"
 * @returns web3 instance with given provider
 */
export function initWeb3(uri: string = "http://127.0.0.1:8545") {
  // const URI = uri || "http://127.0.0.1:8545";
  const provider = new Web3.providers.HttpProvider(uri);
  web3 = new Web3(provider);

  return web3;
}

export async function getAccounts() {
  if (!web3) initWeb3();

  const accounts = await web3.eth.getAccounts();

  //   console.log(accounts);
  return accounts;
}

/**
 * Generate ABI and save it in abis file
 * @param fileName contract file name whose abi you want
 * @param contractName Contract Name
 * @returns abi of the contractName
 */
export function getContractABI(fileName: string, contractName: string) {
  const filePath = path.resolve(__dirname, "../../", "contracts", fileName);
  const content = fs.readFileSync(filePath, { encoding: "utf-8" });

  const input = {
    language: "Solidity",
    sources: {
      [fileName]: { content },
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["*"],
        },
      },
      modelChecker: {
        engine: "chc",
        solvers: ["smtlib2"],
      },
    },
  };

  const data = JSON.parse(
    solc.compile(JSON.stringify(input), {
      smtSolver: smtchecker.smtCallback(smtsolver.smtSolver, smtsolver.availableSolvers[0]),
    })
  );
  /* 
    {
        contracts: { contractName: { Intro: [Object] } },
        sources: { contractName: { id: 0 } }
    }
  */
  // console.log(data);

  //   console.log(data.contracts[contractName]);
  const abi = data.contracts[fileName];
  // const outputFileName = Object.keys(abi)[0] + ".json";
  const outputPath = path.resolve(__dirname, "../../", "abis", `${contractName}.json`);

  if (fs.existsSync(outputPath)) fs.rmSync(outputPath); // If output file exists, remove the file first

  fs.writeFileSync(outputPath, JSON.stringify(abi)); // write a new ABI

  //   const abiPath = path.resolve(__dirname, "../", "abis", `${contractName}.json`);
  //   const abi: ABI = JSON.parse(fs.readFileSync(abiPath, { encoding: "utf-8" }));

  //   console.log(abi[contractName].abi);

  return abi[contractName];
}

export function getContractInstance(contractABI: Array<any>, contractAddress?: string) {
  if (!web3) initWeb3();

  return new web3.eth.Contract(contractABI, contractAddress);
}

export function fromWei(value: string, unit?: Unit) {
  return web3.utils.fromWei(value, unit ? unit : "ether");
}

export function toWei(value: string, unit?: Unit) {
  return web3.utils.toWei(value, unit ? unit : "wei");
}
