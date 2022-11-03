import { ethers } from "ethers";
import React, { Component } from "react";
import Token from "../../contracts/crypto-collectibles/Color-contract-address.json";
import Color from "../../contracts/crypto-collectibles/Color.json";
import "./Crypto-Collectible.css";

class CryptoCollectible extends Component {
  state = {
    account: "",
    contract: null,
    totalSupply: 0,
    colors: [],
  };

  async loadEther() {
    if (window.ethereum) {
      this.provider = new ethers.providers.Web3Provider(window.ethereum);
      await this.provider.send("eth_requestAccounts", []);
      // console.log(accs);

      const blockNumber = await this.provider.getBlockNumber();
      console.log(blockNumber);
    } else if (window.web3) {
      this.provider = new ethers.providers.Web3Provider(window.web3.currentProvider);
      await this.provider.send("eth_requestAccounts", []);
    } else {
      alert("Non-Ethereum Browser detected, consider installing Metamask");
    }
  }

  async loadBlockchainData() {
    const accounts = await this.provider.listAccounts();

    this.setState({ account: accounts[0] });

    window.ethereum.on("accountsChanged", ([newAddress]) => {
      this.setState({ account: newAddress });
    });

    const contract = new ethers.Contract(Token.deployedAddress, Color.abi, this.provider.getSigner(0));
    this.setState({ contract });

    const totalSupply = await this.state.contract.totalSupply();
    this.setState({ totalSupply: totalSupply.toNumber() });

    if (totalSupply > 0) {
      for (let i = 0; i < totalSupply; i++) {
        const color = await contract.colors(i);
        this.setState({ colors: [...this.state.colors, color] });
      }
    }

    // console.log(this.state.colors);

    // const bal = await this.provider.getBalance(this.state.account);
    // console.log(ethers.utils.formatEther(bal.toString()), "ETH");
  }

  async componentDidMount() {
    await this.loadEther();
    await this.loadBlockchainData();
  }

  async mint(color) {
    if (this.state.colors.includes(color)) {
      alert("Color already present");
    } else {
      await this.state.contract.mint(color);

      this.setState({ colors: [...this.state.colors, color] });
      this.color.value = "";
    }
  }

  render() {
    return (
      <div>
        <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
          <a
            className="navbar-brand col-sm-3 col-md-2 mr-0"
            href="https://debiprasadmishra.net"
            target="_blank"
            rel="noopener noreferrer"
          >
            Color Tokens
          </a>
          <ul className="navbar-nav px-3">
            <li className="nav-item text-nowrap d-none d-sm-none d-sm-block">
              <small className="text-white">
                <span id="account">{this.state.account}</span>
              </small>
            </li>
          </ul>
        </nav>
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 d-flex text-center">
              <div className="content mr-auto ml-auto">
                <h1>Issue Token</h1>
                <form
                  onSubmit={(event) => {
                    event.preventDefault();
                    const color = this.color.value;
                    this.mint(color);
                  }}
                >
                  <input
                    type="text"
                    className="form-control mb-1"
                    placeholder="e.g. #FFFFFF"
                    ref={(input) => {
                      this.color = input;
                    }}
                  />
                  <input type="submit" className="btn btn-block btn-primary" value="MINT" />
                </form>
              </div>
            </main>
          </div>
          <hr />
          <div className="row text-center">
            {this.state.colors.map((color, key) => {
              return (
                <div key={key} className="col-md-3 mb-3">
                  <div className="token" style={{ backgroundColor: color }}></div>
                  <div>{color}</div>
                </div>
              );
            })}
          </div>
        </div>

        <div className="container" style={{ position: "fixed", bottom: "5px", textAlign: "center" }}>
          <a
            href="https://debiprasadmishra.net"
            target="_blank"
            rel="noopener noreferrer"
            style={{ textDecoration: "none", color: "black" }}
          >
            © Debi Prasad Mishra
          </a>
        </div>
      </div>
    );
  }
}

export default CryptoCollectible;
