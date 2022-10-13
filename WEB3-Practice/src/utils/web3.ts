import Web3 from "web3";
import solc from "solc";
import * as path from "path";
import fs from "fs";

let web3: Web3;
type ABI = {
  contractName: { abi: []; devdoc: {}; evm: {}; ewasm: {}; metadata: ""; storageLayout: {}; userdoc: {} };
};

export function initWeb3(uri?: string) {
  const URI = uri || "http://127.0.0.1:8545";
  const provider = new Web3.providers.HttpProvider(URI);
  web3 = new Web3(provider);

  return web3;
}

export async function getAccounts() {
  if (!web3) initWeb3();

  const accounts = await web3.eth.getAccounts();

  //   console.log(accounts);
  return accounts;
}

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
    },
  };

  const data = JSON.parse(solc.compile(JSON.stringify(input)));
  /* 
    {
        contracts: { contractName: { Intro: [Object] } },
        sources: { contractName: { id: 0 } }
    }
  */
  //   console.log(data.contracts[contractName]);
  const abi = data.contracts[fileName];
  const outputFileName = Object.keys(abi)[0] + ".json";
  const outputPath = path.resolve(__dirname, "../../", "abis", outputFileName);

  if (fs.existsSync(outputPath)) fs.rmSync(outputPath); // If output file exists, remove the file first

  fs.writeFileSync(outputPath, JSON.stringify(abi)); // write a new ABI

  //   const abiPath = path.resolve(__dirname, "../", "abis", `${contractName}.json`);
  //   const abi: ABI = JSON.parse(fs.readFileSync(abiPath, { encoding: "utf-8" }));

  //   console.log(abi[contractName].abi);

  return abi[contractName].abi;
}

export function getContractInstance(contractABI: Array<any>, contractAddress: string) {
  if (!web3) initWeb3();

  return new web3.eth.Contract(contractABI, contractAddress);
}
