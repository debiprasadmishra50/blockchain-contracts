import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";
import { fromWei, toWei } from "../utils/helper";

describe("NFT Marketplace", () => {
  let deployer: SignerWithAddress,
    addr1: SignerWithAddress,
    addr2: SignerWithAddress,
    nft: Contract,
    marketplace: Contract,
    feePercent = 1;
  let URI = "Sample URI";

  beforeEach(async () => {
    [deployer, addr1, addr2] = await ethers.getSigners();
    const NFT = await ethers.getContractFactory("NFT");
    const Marketplace = await ethers.getContractFactory("Marketplace");

    nft = await NFT.deploy();
    marketplace = await Marketplace.deploy(feePercent);
  });

  describe("Deployment", () => {
    it("should track name and symbol of the nft collection", async () => {
      expect(await nft.name()).to.eq("Debi NFT");
      expect(await nft.symbol()).to.eq("DPM");
    });
    it("should track name and symbol of the marketplace collection", async () => {
      expect(await marketplace.feeAccount()).to.eq(deployer.address);
      expect(await marketplace.feePercent()).to.eq(feePercent);
    });
  });

  describe("Minting NFTs", () => {
    it("should track each minted NFT", async () => {
      // addr1 minting NFTs
      await nft.connect(addr1).mint(URI);
      expect(await nft.tokenCount()).to.eq(1);
      expect(await nft.balanceOf(addr1.address)).to.eq(1);
      expect(await nft.tokenURI(1)).to.eq(URI);

      // addr2 minting NFTs
      await nft.connect(addr2).mint(URI);
      expect(await nft.tokenCount()).to.eq(2);
      expect(await nft.balanceOf(addr1.address)).to.eq(1);
      expect(await nft.tokenURI(2)).to.eq(URI);
    });
  });

  describe("Making marketplace items", () => {
    beforeEach(async () => {
      // addr1 minting NFTs
      await nft.connect(addr1).mint(URI);

      // addr1 approves marketplace to spend the nft
      await nft.connect(addr1).setApprovalForAll(marketplace.address, true);
    });

    it("should track newly created item, transfer NFT from seller to marketplace and emit Offered event", async () => {
      // addr1 offers his nft at a price of 1 Ether
      await expect(marketplace.connect(addr1).makeItem(nft.address, 1, toWei(1)))
        .to.emit(marketplace, "Offered")
        .withArgs(1, nft.address, 1, toWei(1), addr1.address);

      // Owner of NFT should now be the marketplace contract
      expect(await nft.ownerOf(1)).to.eq(marketplace.address);

      // item count in marketplace must be 1
      expect(await marketplace.itemCount()).to.eq(1);

      // get item from items mapping then check fields to ensure they are correct
      /* 
        struct Item {
            uint itemId;
            IERC721 nft;
            uint tokenId;
            uint price;
            address payable seller;
            bool sold;
        }
      */
      const item = await marketplace.items(1);
      expect(item.itemId).to.eq(1);
      expect(item.nft).to.eq(nft.address);
      expect(item.tokenId).to.eq(1);
      expect(item.price).to.eq(toWei(1));
      expect(item.sold).to.eq(false);
    });

    it("Should fail if price is set to zero", async () => {
      await expect(marketplace.connect(addr1).makeItem(nft.address, 1, 0)).to.be.revertedWith(
        "price must be > 0"
      );
    });
  });

  describe("Purchasing marketplace items", () => {
    let price = 2,
      totalPriceInWei: number | BigNumber; // 2 ETH

    beforeEach(async () => {
      // addr1 mints nft
      await nft.connect(addr1).mint(URI);

      // addr1 approves marketplace to spend the nft
      await nft.connect(addr1).setApprovalForAll(marketplace.address, true);

      // addr1 makeer their nft a merketplace item
      await marketplace.connect(addr1).makeItem(nft.address, 1, toWei(price));
    });

    it("should update item as sold, pay seller, transfer NFT to buyer, charge fees and emit a Bought event", async () => {
      const sellerInitialETHBal = await addr1.getBalance();
      const feeAccountInitialETHBal = await deployer.getBalance();
      // console.log(`[+] Seller initial balance: ${fromWei(sellerInitialETHBal)}`);
      // console.log(`[+] FeeAccount initial balance: ${fromWei(feeAccountInitialETHBal)}`);

      // fetch item's total price (market fee * item price)
      totalPriceInWei = await marketplace.getTotalPrice(1);
      // console.log("totalPrice", fromWei(totalPriceInWei), "ETH");

      // addr2 purchases the item
      await expect(marketplace.connect(addr2).purchaseItem(1, { value: totalPriceInWei }))
        .to.emit(marketplace, "Bought")
        .withArgs(1, nft.address, 1, toWei(price), addr1.address, addr2.address);

      const sellerFinalETHBal = await addr1.getBalance();
      const feeAccountFinalETHBal = await deployer.getBalance();
      // console.log(`[+] Seller Final balance: ${fromWei(sellerFinalETHBal)}`);
      // console.log(`[+] FeeAccount Final balance: ${fromWei(feeAccountFinalETHBal)}`);

      // Seller should receive payment for the price of the NFT sold
      expect(+fromWei(sellerFinalETHBal)).to.eq(+price + +fromWei(sellerInitialETHBal));

      // calculate fee
      const fee = (feePercent / 100) * price;
      console.log(fee);

      // feeAcccount should reveive the fee
      expect(+fromWei(feeAccountFinalETHBal)).to.eq(+fee + +fromWei(feeAccountInitialETHBal));

      // the buyer should now own the nft
      expect(await nft.ownerOf(1)).to.eq(addr2.address);

      // item should be marked as sold
      expect((await marketplace.items(1)).sold).to.eq(true);
    });

    it("should fail for invalid item ids, sold items and when not enough ether is paid", async () => {
      // fails for invalid item ids
      await expect(marketplace.connect(addr2).purchaseItem(0, { value: totalPriceInWei })).to.be.revertedWith(
        "item doesn't exist"
      );
      await expect(marketplace.connect(addr2).purchaseItem(2, { value: totalPriceInWei })).to.be.revertedWith(
        "item doesn't exist"
      );
      // fails when not enough ether
      await expect(marketplace.connect(addr2).purchaseItem(1, { value: toWei(price) })).to.be.revertedWith(
        "not enough balance to cover item price and market fee"
      );
      // addr2 purchases item 1
      await marketplace.connect(addr2).purchaseItem(1, { value: totalPriceInWei });

      // deployeer tries to purchase item 1 after the purchase
      await expect(
        marketplace.connect(deployer).purchaseItem(1, { value: totalPriceInWei })
      ).to.be.revertedWith("item already sold");
    });
  });
});
