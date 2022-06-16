const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require("web3");
const compiledFactory = require("./build/CampaignFactory.json");

const provider = new HDWalletProvider(
    "item lift prize fork connect curve obscure fantasy trash casino stool bounce",
    "https://rinkeby.infura.io/v3/4279d3142bcf4543bd4e27b2fe31738c"
);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    console.log(accounts);
    console.log("Attempting to deploy from account", accounts[0]);

    const result = await new web3.eth.Contract(
        JSON.parse(compiledFactory.interface)
    )
        .deploy({ data: "0x" + compiledFactory.bytecode })
        .send({ from: accounts[0], gas: "10000000" });

    // console.log(interface);
    console.log("Contract deployed to", result.options.address);
};

deploy();

/* 
    https://rinkeby.etherscan.io/
    
    search for deployed to address: 0xf91533E34b2d814d23797BdE697409bCe69dD8DF
    
    OR

    Go to remix, set up the environment to Injected web3 and put the addresses in respective position

    
*/
