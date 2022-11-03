import { ethers } from "ethers";
import React, { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";

import NFTContract from "../../contracts/nft-marketplace/NFT-contract-address.json";
import NFT from "../../contracts/nft-marketplace/NFT.json";
import MarketplaceContract from "../../contracts/nft-marketplace/Marketplace-contract-address.json";
import Marketplace from "../../contracts/nft-marketplace/Marketplace.json";
import Navigation from "./NavBar";
import { Spinner } from "react-bootstrap";
import "./NFT-Marketplace.css";
import Home from "./Home";
import Create from "./Create";
import MyListedItems from "./MyListedItems";
import MyPurchases from "./MyPurchases";

function NFTMarketplace() {
  const [loading, setLoading] = useState(true);
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [marketplace, setMarketplace] = useState({});
  const [nft, setNft] = useState({});

  const loadWeb3 = async () => {
    if (window.ethereum) {
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);

      window.ethereum.on("chainChanged", (chainId) => {
        window.location.reload();
      });

      window.ethereum.on("accountsChanged", async function (accounts) {
        setAccount(accounts[0]);
        await loadWeb3();
      });

      // Get metamask provider
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setProvider(provider);

      const signer = provider.getSigner();
      loadBlockchainData(signer);
    } else if (window.web3) {
      const provider = new ethers.providers.Web3Provider(window.web3.currentProvider);
      await provider.send("eth_requestAccounts", []);

      setProvider(provider);
    } else {
      alert("Non-Ethereum Browser detected, consider installing Metamask");
    }
  };

  const loadBlockchainData = (signer) => {
    // Get deployed contract
    const marketplace = new ethers.Contract(MarketplaceContract.deployedAddress, Marketplace.abi, signer);
    setMarketplace(marketplace);

    const nft = new ethers.Contract(NFTContract.deployedAddress, NFT.abi, signer);
    setNft(nft);

    setLoading(false);
  };

  return (
    <BrowserRouter>
      <div className="App">
        <Navigation web3Handler={loadWeb3} account={account} />
        <div>
          {loading ? (
            <div
              style={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: "80vh" }}
            >
              <Spinner animation="border" style={{ display: "flex" }} />
              <p className="mx-3 my-0">Awaiting Metamask Connection...</p>
            </div>
          ) : (
            <Routes>
              <Route path="/" element={<Home marketplace={marketplace} nft={nft} />} />
              <Route path="/create" element={<Create marketplace={marketplace} nft={nft} />} />
              <Route
                path="/my-listed-items"
                element={<MyListedItems marketplace={marketplace} nft={nft} account={account} />}
              />
              <Route
                path="/my-purchases"
                element={<MyPurchases marketplace={marketplace} nft={nft} account={account} />}
              />
            </Routes>
          )}
        </div>
      </div>
    </BrowserRouter>
  );
}

export default NFTMarketplace;
