import * as dotenv from "dotenv";
dotenv.config({ path: ".env" });

// work with Web3
import Web3 from "web3";
import * as lib from "../utils/web3";
import fs from "fs";
import * as path from "path";

let web3: Web3;

// const account = process.env.ADDRESS;
// const privateKey = process.env.PRIVATE_KEY;
web3 = lib.initWeb3();
// web3.eth.accounts.wallet.add(privateKey);

/**
 *
 * @param fileName filename to deploy inside the contracts folder
 * @param contractName Contract name that needs to be deployed
 */
async function deployAndSave(fileName: string, contractName: string) {
  const [deployer, acc1, acc2] = await web3.eth.getAccounts();
  const intro = lib.getContractABI(fileName, contractName);
  const bytecode = intro.evm.bytecode.object;

  const contract = lib.getContractInstance(intro.abi);
  const result = await contract.deploy({ data: bytecode }).send({ from: deployer, gas: 1500000 });

  const deployedAddress = result["_address"];
  console.log(`[+] Contract deployed to ${deployedAddress} address`);

  const outputPath = path.resolve(__dirname, "../../", "abis", "address");

  if (!fs.existsSync(outputPath)) fs.mkdirSync(outputPath);

  const filePath = path.join(outputPath, `${contractName}-contract-address.json`);

  fs.writeFileSync(filePath, JSON.stringify({ deployedAddress }));

  return deployedAddress;
}

deployAndSave("01_Intro.sol", "Intro");

export default deployAndSave;
