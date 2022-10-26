import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("Token", () => {
  let Token, token: Contract, owner: any, addr1: any, addr2: any;

  beforeEach(async () => {
    Token = await ethers.getContractFactory("Token");

    token = await Token.deploy();
    console.log("[+] Token deployed to:", token.address);

    [owner, addr1, addr2] = await ethers.getSigners();
    console.log("[+] Addresses to work with", owner.address, addr1.address, addr2.address);
  });

  describe("Deployment", () => {
    it("Should set the right owner", async () => {
      expect(await token.owner()).to.equal(owner.address);
    });

    it("should assign the total supply of tokens to the owner", async () => {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", () => {
    it("Should transfer tokens between accounts", async () => {
      await token.transfer(addr1.address, 50);
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);

      await token.connect(addr1).transfer(addr2.address, 50);
      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

    it("Should fail if sender doesn't has enough tokens", async () => {
      const initOwnerBalance = await token.balanceOf(owner.address);

      //   await token.connect(addr1).transfer(owner.address, 1);

      // FIXME: for ganache-test it's giving an error
      await expect(token.connect(addr1).transfer(owner.address, 1)).to.be.revertedWith("insufficient funds");

      expect(await token.balanceOf(owner.address)).to.equal(initOwnerBalance);
    });

    it("Should update balances after transfers", async () => {
      const initOwnerBalance = await token.balanceOf(owner.address);

      await token.transfer(addr1.address, 100);
      await token.transfer(addr2.address, 50);

      const finalOwnerBalance = await token.balanceOf(owner.address);
      expect(finalOwnerBalance).to.eq(initOwnerBalance - 150);

      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance).to.eq(100);
      const addr2Balance = await token.balanceOf(addr2.address);
      expect(addr2Balance).to.eq(50);
    });

    // it("check", async () => {
    //   await expect(token.connect(addr1).mint()).to.be.revertedWith("not owner");
    //   // await expect(token.connect(owner).mint()).to.be.revertedWith("not owner");
    //   //   await token.connect(owner).mint();
    // });
  });
});
