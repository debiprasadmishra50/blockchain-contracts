const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const { interface, bytecode } = require("../compile");

// creating an instance of web3
const provider = ganache.provider();
const web3 = new Web3(provider);
// console.log(Object.keys(web3));

let accounts;
let inbox;
const INITIAL_STRING = "Hi There!";
beforeEach(async () => {
    // Get all unlocked accounts from ganache
    accounts = await web3.eth.getAccounts();
    console.log(accounts);

    // Use one of those accounts to deploy the contract
    inbox = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({ data: bytecode, arguments: [INITIAL_STRING] })
        .send({ from: accounts[0], gas: "1000000" });

    inbox.setProvider(provider);
});

describe("Inbox", () => {
    it("deploys a contract", () => {
        // console.log(accounts);
        // console.log(inbox);

        assert.ok(inbox.options.address); // if address exists or not after deployment
    });

    it("has a default message", async () => {
        const message = await inbox.methods.message().call();

        assert.equal(message, INITIAL_STRING);
    });

    it("can change the message", async () => {
        await inbox.methods
            .setMessage("Bye Contract!")
            .send({ from: accounts[0], gas: "1000000" });

        const message = await inbox.methods.message().call();
        assert.equal(message, "Bye Contract!");
    });
});
