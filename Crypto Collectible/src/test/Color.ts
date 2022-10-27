import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("Color", () => {
  let Color, color: Contract, owner: SignerWithAddress, addr1: any;

  beforeEach(async () => {
    Color = await ethers.getContractFactory("Color");

    color = await Color.deploy("My Nft Token", "MNT");

    [owner, addr1] = await ethers.getSigners();
  });

  describe("Deployment", () => {
    it("Should verify contract deployment", () => {
      console.log(`[+] Deployed to ${color.address}`);
      expect(color.address).not.to.be.empty;
      expect(color.address).not.to.be.null;
      expect(color.address).not.to.be.undefined;
      expect(color.address).to.exist;
    });

    it("has a name", async () => {
      const name = await color.name();

      expect(name).to.eq("My Nft Token");
    });

    it("has a symbol", async () => {
      const symbol = await color.symbol();

      expect(symbol).to.eq("MNT");
    });
  });

  describe("Minting", () => {
    it("only owner should be able to mint", async () => {
      await expect(color.connect(addr1).mint("#efefef")).to.be.revertedWith("not owner");
    });

    it("should mint a color", async () => {
      await color.mint("#efefef");

      const total = await color.totalSupply();
      expect(total).to.eq(1);
      const res = await color.colors(0);
      expect(res).not.to.be.empty;
      expect(res).to.eq("#efefef");
    });

    it("should emit Transfer Event", async () => {
      const zeroAddress = "0x0000000000000000000000000000000000000000";
      await expect(color.mint("#efefe2")).to.emit(color, "Transfer").withArgs(zeroAddress, owner.address, 1);
    });

    it("should fail while minting duplicate color", async () => {
      await color.mint("#efefef");
      await expect(color.mint("#efefef")).to.be.revertedWith("color exists");
    });
  });

  describe("Indexing", () => {
    it("Lists Colors", async () => {
      // Mint 3 tokens
      await color.mint("#efefef");
      await color.mint("#efefe2");
      await color.mint("#efefe1");

      const totalSupply = await color.totalSupply();

      expect(totalSupply).to.eq(3);
      let result = [];

      for (let i = 0; i < totalSupply; i++) {
        result.push(await color.colors(i));
      }

      let expected = ["#efefef", "#efefe2", "#efefe1"];
      expect(result).to.deep.eq(expected);
    });
  });
});
