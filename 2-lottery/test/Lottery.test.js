const assert = require("assert");
const ganache = require("ganache-cli"); // local test network
const Web3 = require("web3");
const { interface, bytecode } = require("../compile");

// creating an instance of web3
const provider = ganache.provider();
const web3 = new Web3(provider);
// console.log(Object.keys(web3));

let accounts;
let lottery;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    lottery = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: bytecode })
        .send({ from: accounts[0], gas: "1000000" });

    lottery.setProvider(provider);
});

describe("Lottery Contract", () => {
    it("deploys a contract", () => {
        assert.ok(lottery.options.address);
    });

    it("allows one account to enter", async () => {
        await lottery.methods.enter().send({
            from: accounts[0],
            value: web3.utils.toWei("0.02", "ether"),
        });

        const players = await lottery.methods.getPlayers().call({
            from: accounts[0],
        });

        assert.equal(accounts[0], players[0]);
        assert.equal(1, players.length);
    });

    it("allows multiple accounts to enter", async () => {
        await lottery.methods.enter().send({
            from: accounts[0],
            value: web3.utils.toWei("0.02", "ether"),
        });
        await lottery.methods.enter().send({
            from: accounts[1],
            value: web3.utils.toWei("0.02", "ether"),
        });
        await lottery.methods.enter().send({
            from: accounts[2],
            value: web3.utils.toWei("0.02", "ether"),
        });

        const players = await lottery.methods.getPlayers().call({
            from: accounts[0],
        });

        assert.equal(accounts[0], players[0]);
        assert.equal(accounts[1], players[1]);
        assert.equal(accounts[2], players[2]);
        assert.equal(3, players.length);
    });

    it("requires a minimium amount of ether to enter", async () => {
        try {
            await lottery.methods.enter().send({
                from: accounts[0],
                value: 200, // send less wei to enter Lottery contract
            });
            assert(false);
        } catch (err) {
            assert(err);
        }
    });

    it("only manager can call pickWinner", async () => {
        try {
            await lottery.methods.pickWinner().send({
                from: accounts[1],
            });
            assert(false);
        } catch (err) {
            assert(err);
        }
    });

    it("sends money to winner and reset the player array", async () => {
        await lottery.methods.enter().send({
            from: accounts[0],
            value: web3.utils.toWei("2", "ether"),
        });

        const initialBalance = await web3.eth.getBalance(accounts[0]);

        await lottery.methods.pickWinner().send({
            from: accounts[0],
        });

        const finalBalance = await web3.eth.getBalance(accounts[0]);

        const difference = finalBalance - initialBalance;
        console.log(difference, "is gas spent");
        assert(difference > web3.utils.toWei("1.8", "ether"));

        const players = await lottery.methods.getPlayers().call({
            from: accounts[0],
        });
        assert.equal(0, players.length);
    });
});
