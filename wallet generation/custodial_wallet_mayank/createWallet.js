// import getDb from "../../getDb";
const { ethers } = require("ethers");

function createWallet(mnemonic) {
  // const db = await getDb();

  // 1. fetch latest path index from DB.
  // 2. if path index is not found then pathIndex = 0;
  // 3. Derive the public private key pair.
  // 4. Update the latest path Index in the DB.

  // let pathIndex = await db.collection("eth-wallet").findOne({});

  // if (pathIndex) {
  //   pathIndex = pathIndex["pathIndex"];
  // } else {
  //   pathIndex = 1;
  // }

  let pathIndex = 2;
  let derivationPath = "m/44'/60'/0'/0/";
  pathIndex++;

  let mnemonicWallet = ethers.Wallet.fromMnemonic(
    mnemonic,
    `${derivationPath}${pathIndex}`
  );
  // const publicKey = mnemonicWallet.publicKey;
  const address = mnemonicWallet.address;

  let newAddress = {
    address: `0x${address.slice(2)}`,
    privateKey: mnemonicWallet.privateKey,
    // public: publicKey.slice(2),
    path: `${derivationPath}${pathIndex}`,
    pathIndex,
  };

  // await db.collection("eth-wallet").updateOne(
  //   { id: "latest" },
  //   {
  //     $set: {
  //       pathIndex: path,
  //     },
  //   },
  //   { upsert: true }
  // );

  return newAddress;
}

console.log(
  createWallet(
    "city shaft focus kit away canal abandon hope bachelor vendor survey icon"
  )
);
