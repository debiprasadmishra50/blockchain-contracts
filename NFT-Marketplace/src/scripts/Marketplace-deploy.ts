import { ethers } from "hardhat";
import saveFrontendFiles from "../utils/save-frontend-files";

async function main() {
  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();

  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(1); // 1% is the fee percentage

  await nft.deployed();
  await marketplace.deployed();

  console.log(`[+] Contract Deployed to ${nft.address} address.`);
  console.log(`[+] Contract Deployed to ${marketplace.address} address.`);

  saveFrontendFiles(nft, "NFT", "nft-marketplace");
  saveFrontendFiles(marketplace, "Marketplace", "nft-marketplace");
  // console.log(nft);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
