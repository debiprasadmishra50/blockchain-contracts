const lightningHash = (data: string) => data + "*";

class Block {
  data: string;
  hash: string;
  lashHash: string;

  constructor(data: string, hash: string, lashHash: string) {
    this.data = data;
    this.hash = hash;
    this.lashHash = lashHash;
  }
}

class Blockchain {
  chain: Block[];

  constructor() {
    const genesis = new Block("gen-data", "gen-hash", "gen-lashHash");

    this.chain = [genesis];
  }

  addBlock(data: string) {
    const lashHash = this.chain[this.chain.length - 1].hash;

    const hash = lightningHash(data + lashHash);

    const block = new Block(data, hash, lashHash);

    this.chain.push(block);
  }
}

const demoBlockchain = new Blockchain();

demoBlockchain.addBlock("one");
demoBlockchain.addBlock("two");
demoBlockchain.addBlock("three");

console.log(demoBlockchain);
