console.clear();
const bip39 = require("bip39");

// Generate 12 word mnemonic
const mnemonics = {
  DEPOSIT_MNEMONIC: bip39.generateMnemonic(),
  WITHDRAW_MNEMONIC: bip39.generateMnemonic(),
};
console.log(mnemonics);
