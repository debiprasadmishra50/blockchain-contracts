const path = require("path");
const fs = require("fs");
const solc = require("solc");

const inboxpath = path.resolve(__dirname, "contracts", "Inbox.sol");

const content = fs.readFileSync(inboxpath, "utf-8");

// code to compile, and no of contracts to compile
const data = solc.compile(content, 1);

// console.log(data);

module.exports = data.contracts[":Inbox"];
