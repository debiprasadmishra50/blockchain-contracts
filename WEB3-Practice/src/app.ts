import * as dotenv from "dotenv";
dotenv.config({ path: ".env" });

// Uniswap imports
import { ChainId, Fetcher, Route, WETH, Trade, TokenAmount, TradeType, Percent } from "@uniswap/sdk";

// etherjs import
import * as ethers from "ethers";

// work with Web3
import Web3 from "web3";
import * as lib from "./utils/web3";

let web3: Web3;

const account = process.env.ADDRESS;
const privateKey = process.env.PRIVATE_KEY;
const explorerURI = "https://goerli.etherscan.io/tx";
web3 = lib.initWeb3(`https://goerli.infura.io/v3/${process.env.INFURA_KEY}`);
web3.eth.accounts.wallet.add(privateKey);

const app = async () => {
  console.log(`The chainId of mainnet is ${ChainId.MAINNET}`);

  const chainId = ChainId.MAINNET;
  const tokenAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

  const dai = await Fetcher.fetchTokenData(chainId, tokenAddress);
  const weth = WETH[chainId];

  const pair = await Fetcher.fetchPairData(dai, weth);

  const route = new Route([pair], weth);

  console.log(route.midPrice.toSignificant(6)); // DAI price against 1 WETH
  console.log(route.midPrice.invert().toSignificant(6)); // WETH price against 1 DAI

  // Asking uniswap, If I trade X amount of A token, then what would be the executionPrice and nextMidPrice
  const tokenAmount = "100000000000000000"; // 100 tokens
  const trade = new Trade(route, new TokenAmount(weth, tokenAmount), TradeType.EXACT_INPUT);
  // console.log(trade);
  console.log(trade.executionPrice.toSignificant(6));
  console.log(trade.nextMidPrice.toSignificant(6));

  const slippageTokerance = new Percent("50", "10000"); // 50 bips, 1 bip = 0.001%

  const amountOutMin = trade.minimumAmountOut(slippageTokerance).raw;
  const path = [weth.address, dai.address];
  const to = "0x62af1BF552347b7BaAC5cE78790E75E19F2D77A0";
  const deadline = Math.floor(Date.now() / 1000) + 60 * 20; // 20 seconds
  const value = trade.inputAmount.raw;

  const provider = ethers.getDefaultProvider("mainnet", {
    infura: "https://mainnet.infura.io/v3/${process.env.INFURA_KEY}",
  });

  const signer = new ethers.Wallet(process.env.PRIVATE_KEY);
  const account = signer.connect(provider);

  const uniswap = new ethers.Contract(
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    [
      `function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);`,
    ],
    account
  );

  const tx = await uniswap.sendExactETHForTokens(amountOutMin, path, to, deadline, { value, gasPrice: 20e9 });
  console.log("Transaction hash:", tx);
  const receipt = await tx.wait();
  console.log("Transaction was mined in block", receipt.blockNumber);
};

// app();

/*  
Uniswap:

V1 Docs: https://github.com/Uniswap/v1-docs
https://github.com/Uniswap/v1-contracts

V2 Docs: https://docs.uniswap.org/protocol/V2/reference/smart-contracts/factory

V3 docs: change the version in V2

pre-requisites: 
  Liquidity Providers, Traders, Liquidity Pools, Swapping, ETH, ERC20

Model of Uniswap
  Traders <––––––––––> Liquidity Pool <––––––––––> Liquidity Provider

  Earn from UNI by 
    - performing buy and sell ERC20 tokens 
    - by becoming a Liquidity Provider for Uniswap

  - Liquidity Provider(LP) need to send equal amouunt of Ether and ERC20 tokens to a specific pool and in exchange they will be given liquidity tokens to represent the asset he has provided.

  - A LP at any point can redeem those Liquidity tokens agaisnt the assets in the pool. 
  
  - Traders are able to buy or sell ERC20 Token of that specific pool

  - If a trader wants to buy some ERC20 Token he will send some ETH to the Liquidity pool and he will receive the ERC20 token in exchange. 

  - He will also provide a transaction fee which will be give to LP when they withdraw their asset

  - At no point a Trader trades directly with Liquidity Providers, they trade with the Liquidity Pool only

  - The price of the ERC20 and ETH in the liquidity pool is set automatically to keep them balanced

  X = ERC20, Y = ETH
  - If someone buys ERC20 token, 
  X:Y = 1:1
  X decreases compared to Y
  in this case smart contract will increase the price of ERC20 token incentivizing the traders which will re-balance the liquidity pool.

  Smart Contracts
  ------------------------
                          Factory

      Exchange      Exchange      Exchange      Exchange
      ETH/BAT       ETH/ZRX       ETH/DAI       ETH/BTC   ...etc

      - There is one extended smart contract per pair of asset
      - that's where the liquidity pools are and where trading actually happens.

      - There is only one Factory smart contract
      - The responsibilities of Factory is to create the exchanges smart contract and act as a registry for these excahnges.

      - V1 is written in Vyper
        https://github.com/Uniswap/v1-docs

      - V2 is written in solidity

      // Solidity Interface Uniswap V1 Factory
      contract UniswapFactoryInterface {
          // Public Variables
          address public exchangeTemplate;
          uint256 public tokenCount;

          // Create Exchange
          function createExchange(address token) external returns (address exchange);

          // Get Exchange and Token Info
          function getExchange(address token)
              external
              view
              returns (address exchange);

          function getToken(address exchange) external view returns (address token);

          function getTokenWithId(uint256 tokenId)
              external
              view
              returns (address token);

          // Never use
          function initializeFactory(address template) external;
      }

      
      
  Uniswap V2
  -------------------
      interface IUniswapV2Factory {
        event PairCreated(address indexed token0, address indexed token1, address pair, uint);

        function feeTo() external view returns (address);
        function feeToSetter() external view returns (address);

        function getPair(address tokenA, address tokenB) external view returns (address pair);
        function allPairs(uint) external view returns (address pair);
        function allPairsLength() external view returns (uint);

        function createPair(address tokenA, address tokenB) external returns (address pair);

        function setFeeTo(address) external;
        function setFeeToSetter(address) external;
      }

    Goerli Testnet: https://goerli.etherscan.io/address/0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f#code

    - Factory: Create different market in uniswap and act as a registry for Different market

    - Pair: Each market is represented by smart contract called Pair Smart contract

    - In each Pair you have 2 tokens: DAI/WETH, USDC/WETH, 
    
    - Router: It is a utility which helps you to use Uniswap in a simpler way

    - ERC20: Tokens that are manipulated by Uniswap

                      Factory

        PAIR          PAIR         PAIR          PAIR
      ETH/BAT       ETH/ZRX       ETH/DAI       ETH/BTC   ...etc

    - 1WETH token = 1ETH

    - In uniswapV1 you can create markets with Ether but in V2 you can create PAIR with WETH

    - Anybody can create a PAIR and this is a permissionless system, you need to call Factory Smart Contract to create a PAIR

    Interacting with PAIR
    --------------------------------
      - 2 person can interact with a PAIR
        1. Liquidity Provider
        2. Traders

                        DAI + WETH
      Liquidity  –––––––––––––––––––––––––>     PAIR
      Provider   <–––––––––––––––––––––––––   DAI/WETH
                      LP Token

      
      - If a PAIR is of DAI/WETH then a LP can provide both of same value and receive LP tokens as a redeemable token

      - Plus you will also get the trading fee that will earn by the PAIR smart contract in the meantime

                  WETH + trading fees
      Trader   –––––––––––––––––––––––––>     PAIR
               <–––––––––––––––––––––––––   DAI/WETH
                        DAI

                        
    - It can get tricky to interact directly with PAIR smart contract so uniswap Router that can be used as a conduit or convenience in order to interact with the PAIR

    - If you are building your own system around uniswap, it's recommended to use Router smart contract instead of directly interfacing with the PAIR contracts

                                          PAIR
    Trader –––>–––––+        +–––––––––> DAI/WETH  
                    | Router |
    Liquidity ––>–––+        +––––––––––> PAIR
    Provider                            USDC?WETH


    - Advantages for using Router is you can have complex trading using the Router

    - Let's say there are 2 PAIRS available, DAI/WETH and DAI/USDC but iur requirement is DAI/USDC which is not available

    - Here we can specify a route to the router smart contract, we will use the DAI/WETH Pair and then the USDC/WETH Pair, that way we can synthetically create the DAI/USDC market

    - You can also use ETH to trade on uniswap and Router will automacically convert back and forth between ETH and WETH

    - otherwise if you trade directly with the pair, you have to take care of the yourself of wrapping your ETH into a WETH token first. 

    
    

*/
