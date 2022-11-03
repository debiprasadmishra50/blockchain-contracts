import { ethers } from "hardhat";
import saveFrontendFiles from "../utils/save-frontend-files";

async function main() {
  const Color = await ethers.getContractFactory("Color");
  const color = await Color.deploy("My Nft Token", "MNT");

  await color.deployed();

  console.log(`[+] Contract Deployed to ${color.address} address.`);

  saveFrontendFiles(color, "Color");
  // console.log(color);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
