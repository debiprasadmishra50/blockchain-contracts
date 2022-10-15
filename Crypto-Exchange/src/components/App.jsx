import React, { Component } from "react";
import "./App.css";
import Web3 from "web3";
import Navbar from "./NavBar";
import Main from "./Main";
import Token from "../abis/Token.json";
import EthSwap from "../abis/EthSwap.json";

// https://eips.ethereum.org/EIPS/eip-1193
class App extends Component {
  state = {
    defaultAddress: "",
    token: {},
    tokenBalance: "0",
    ethSwap: {},
    ethBalance: "0",
    loading: true,
  };

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      // await window.ethereum.enable();
      // await window.ethereum.send("eth_requestAccounts");
      // const data = await window.ethereum.request({ method: "eth_requestAccounts" });
      // const accounts = await window.ethereum.request({ method: "eth_accounts" });

      // console.log(accounts);
    } else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      alert("Non-Ethereum browser detected, consider installing Metamask");
    }
  }

  async loadBlockchainData() {
    const web3 = window.web3;

    const accounts = await web3.eth.getAccounts();
    // console.log(accounts);
    this.setState({ defaultAddress: accounts[0] });
    // console.log(this.state.defaultAddress);

    const ethBalance = await this.getBalance(this.state.defaultAddress);
    this.setState({ ethBalance });
    // console.log(this.state.ethBalance, "ether");

    // Load Token
    const networkId = await web3.eth.net.getId();
    const tokenData = Token.networks[networkId];
    if (!tokenData) alert("Token contract not deployed to detected network");
    else {
      const token = new web3.eth.Contract(Token.abi, tokenData.address);
      this.setState({ token });

      let tokenBalance = await token.methods.balanceOf(this.state.defaultAddress).call();
      tokenBalance = this.toEth(tokenBalance.toString());
      this.setState({ tokenBalance });
    }

    // Load EthSwap
    const ethSwapData = EthSwap.networks[networkId];
    if (!ethSwapData) alert("EthSwap contract not deployed to detected network");
    else {
      const ethSwap = new web3.eth.Contract(EthSwap.abi, ethSwapData.address);
      this.setState({ ethSwap });
    }

    this.setState({ loading: false });
  }

  toEth(wei) {
    return window.web3.utils.fromWei(wei, "ether");
  }

  async getBalance(accountAddress) {
    let bal = await window.web3.eth.getBalance(accountAddress);
    bal = window.web3.utils.fromWei(bal, "ether");

    return bal;
  }

  buyTokens = (etherAmount) => {
    this.setState({ loading: true });
    this.state.ethSwap.methods
      .buyTokens()
      .send({ value: etherAmount, from: this.state.defaultAddress })
      .on("transactionHash", (hash) => {
        this.setState({ loading: false });
        window.location.reload();
      });
  };

  sellTokens = (tokenAmount) => {
    this.setState({ loading: true });
    this.state.token.methods
      .approve(this.state.ethSwap.address, tokenAmount)
      .send({ from: this.state.defaultAddress })
      .on("transactionHash", (hash) => {
        this.state.ethSwap.methods
          .sellTokens(tokenAmount)
          .send({ from: this.state.defaultAddress })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
            window.location.reload();
          });
      });
  };

  async componentDidMount() {
    await this.loadWeb3();
    await this.loadBlockchainData();
    // console.log(window.web3);
  }

  render() {
    let content;
    if (this.state.loading) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else {
      content = (
        <Main
          ethBalance={this.state.ethBalance}
          tokenBalance={this.state.tokenBalance}
          buyTokens={this.buyTokens}
          sellTokens={this.sellTokens}
        />
      );
    }

    return (
      <div>
        <Navbar account={this.state.defaultAddress} />

        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: "600px" }}>
              <div className="content mr-auto ml-auto">{content}</div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
