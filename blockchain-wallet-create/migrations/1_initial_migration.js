const Migrations = artifacts.require("Migrations");
const DaiTokenMock = artifacts.require("DaiTokenMock");

module.exports = async function(deployer) {
  await deployer.deploy(Migrations);
  await deployer.deploy(DaiTokenMock);
  const tokenMock = await DaiTokenMock.deployed();

  // Mint 1000 tokens from deployer
  await tokenMock.mint(
    "0x87e80e0874fa2665844840fa4b2f1ea3319b0574",
    "1000".padEnd(22, "0")
  );
};
