import Web3 from "web3";

let web3;

if (typeof window !== "undefined" && window.ethereum != "undefined") {
    // we are in browser
    web3 = new Web3(window.ethereum);
    (async () => {
        await window.ethereum.enable();
    })();
} else {
    // we are on the server OR user is not running metamask
    const provider = new Web3.providers.HttpProvider(
        "https://rinkeby.infura.io/v3/4279d3142bcf4543bd4e27b2fe31738c"
    );
    web3 = new Web3(provider);
}

export default web3;
