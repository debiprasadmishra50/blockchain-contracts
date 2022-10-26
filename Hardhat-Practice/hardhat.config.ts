import { extendEnvironment, HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import * as _ from "dotenv";
_.config({ path: "./.env" });

task("accounts", "Log accounts in use", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  console.log("\n[+] Addresses In Use for current provider: \n");
  for (const account of accounts) {
    console.log(account.address);
  }
  console.log();
});

task("balance", "get account's balance")
  .addParam("account", "Account address")
  .setAction(async (args, hre) => {
    const ethers = hre.ethers;
    const bal = await ethers.provider.getBalance(args.account);

    console.log(`${args.account}: ${ethers.utils.formatEther(bal)} ETH\n`);
  });

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      gas: 10000000000,
      blockGasLimit: 100000000000000,
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      gasPrice: 20000000000,
      chainId: 1337,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA}`,
    },
    bsc: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [
        "6b035689fda3a0e26b29b0c4ace7ae9fe4834e2866d01300c985915b97dc8705",
        "ac9fec8e87a0c546472404443852a548330ac507622aee71ee86b9c8f4efe699",
      ],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN,
  },
  mocha: {
    timeout: 1000000000, // Increased timeout or else run.ts will fail
  },
};

export default config;
