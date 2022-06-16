import Web3 from "web3";

// use the metamask provider as the provide stores the account info and private key and other resources
// const web3 = new Web3(window.web3.currentProvider);
const web3 = new Web3(window.ethereum);

(async () => {
    await window.ethereum.enable();
})();

export default web3;
