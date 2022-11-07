import * as web3 from "./utils/web3";

const app = async () => {
  web3.initWeb3();

  const addresses = await web3.getAccounts();
  const defaultAddress = addresses[0];

  const intro = web3.getContractABI("01_intro.sol", "Intro");
  const CONTRACT_ADDRESS = "0x1C98637420554C7F97268B5D7bB6D954273eC0d4";

  const contract = web3.getContractInstance(intro.abi, CONTRACT_ADDRESS);

  // Interact with contract
  const name = await contract.methods.name().call();
  const owner = await contract.methods.owner().call();

  console.log("[+] Name: ", name);
  console.log("[+] Owner: ", owner);

  const updateNameTo = "Debi Mishra";
  await contract.methods.setName(updateNameTo).send({ from: defaultAddress });

  const updatedName = await contract.methods.name().call();
  console.log("[+] Updated Name: " + updatedName);
};

app();
