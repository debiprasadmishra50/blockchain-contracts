const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require("web3");
const { interface, bytecode } = require("./compile");

const provider = new HDWalletProvider(
    "item lift prize fork connect curve obscure fantasy trash casino stool bounce",
    "https://rinkeby.infura.io/v3/4279d3142bcf4543bd4e27b2fe31738c"
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log(accounts);
    console.log("Attempting to deploy from account", accounts[0]);

    const result = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: "0x" + bytecode, arguments: ["Hi There!"] })
        .send({ from: accounts[0] });

    console.log("Contract deployed to", result.options.address);
};

deploy();

/* 
    https://rinkeby.etherscan.io/
    
    search for deployed to address: 0xb8B8CB776cf529AcA5dFc93d33282f66e2051B5B

    OR

    Go to remix, set up the environment to Injected web3 and put the addresses in respective position

    
*/
