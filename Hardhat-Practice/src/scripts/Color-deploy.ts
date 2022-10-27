import { artifacts, ethers } from "hardhat";
import * as path from "path";
import * as fs from "fs";

async function main() {
  const Color = await ethers.getContractFactory("Color");
  const color = await Color.deploy("My Nft Token", "MNT");

  await color.deployed();

  console.log(`[+] Contract Deployed to ${color.address} address.`);

  saveFrontendFiles(color);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

function saveFrontendFiles(token: any) {
  const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "contract-address.json"),
    JSON.stringify({ Token: token.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("Color");

  fs.writeFileSync(path.join(contractsDir, "Color.json"), JSON.stringify(TokenArtifact, null, 2));
}
