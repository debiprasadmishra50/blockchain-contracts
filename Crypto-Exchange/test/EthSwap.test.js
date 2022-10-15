const { assert } = require("chai");

const Token = artifacts.require("Token");
const EthSwap = artifacts.require("EthSwap");

require("chai")
  .use(require("chai-as-promised"))
  .should();

function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

// contract("EthSwap", (accounts) => {
contract("EthSwap", ([deployer, investor]) => {
  let token, ethSwap;

  before(async () => {
    token = await Token.new();
    ethSwap = await EthSwap.new(token.address);
    // Transfer all tokens to EthSwap, 1 million
    await token.transfer(ethSwap.address, tokens("1000000"));
  });

  describe("Token deployment", async () => {
    it("contract has a name", async () => {
      const name = await token.name();
      assert.equal(name, "Debi Prasad Token");
    });
  });

  describe("EthSwap deployment", async () => {
    it("contract has a name", async () => {
      const name = await ethSwap.name();
      assert.equal(name, "EthSwap Instant Exchange");
    });
  });

  it("contract has tokens", async () => {
    let balance = await token.balanceOf(ethSwap.address);
    assert.equal(balance.toString(), tokens("1000000"));
  });

  describe("Buy Tokens", async () => {
    let result;

    before(async () => {
      result = await ethSwap.buyTokens({ from: investor, value: tokens("1") });
    });

    it("Allows user to instantly purchase tokens from ethSwap for a fixed price", async () => {
      // check investor balance after purchase
      let investorBalance = await token.balanceOf(investor);
      assert.equal(investorBalance.toString(), tokens("100"));

      // check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await token.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("999900"));

      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("1"));

      const event = result.logs[0].args;
      //   console.log(result.logs[0].args);
      assert.equal(event.buyer, investor);
      assert.equal(event.token, token.address);
      assert.equal(event.amount.toString(), tokens("100"));
      assert.equal(event.rate.toString(), "100");
    });
  });

  describe("Sell Tokens", async () => {
    let result;

    before(async () => {
      await token.approve(ethSwap.address, tokens("100"), { from: investor }); // approve ethSwap to spend 100 tokens

      result = await ethSwap.sellTokens(tokens("100"), { from: investor });
    });

    it("Allows user to instantly sell tokens to ethSwap for a fixed price", async () => {
      // check investor balance after purchase
      let investorBalance = await token.balanceOf(investor);
      assert.equal(investorBalance.toString(), tokens("0"));

      // check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await token.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("1000000"));

      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("0"));

      const event = result.logs[0].args;
      //   console.log(result.logs[0].args);
      assert.equal(event.buyer, investor);
      assert.equal(event.token, token.address);
      assert.equal(event.amount.toString(), tokens("100"));
      assert.equal(event.rate.toString(), "100");

      // FAILURE
      await ethSwap.sellTokens(tokens("500"), { from: investor }).should.be.rejected;
    });
  });
});
