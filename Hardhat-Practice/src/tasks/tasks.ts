import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";
import * as temp from "hardhat/config";
import * as temps from "hardhat";

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
