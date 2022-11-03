import * as path from "path";
import * as fs from "fs";
import { artifacts } from "hardhat";

/**
 * Save frontend files like ABI, deployed addredd for frontend integration
 * @param token deployed token
 * @param contractName Contract Name to save
 * @param directoyName path where to save
 * @default directory ""
 */
function saveFrontendFiles(token: any, contractName: string, directoyName: string = "") {
  const contractsDir = path.join(__dirname, "..", "frontend", "src", "contracts", directoyName);

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, `${contractName}-contract-address.json`),
    JSON.stringify({ deployedAddress: token.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync(contractName);

  fs.writeFileSync(path.join(contractsDir, `${contractName}.json`), JSON.stringify(TokenArtifact, null, 2));
}

export default saveFrontendFiles;
