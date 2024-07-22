import Block from "./block";

export class Blockchain {
  chain: Block[] = [];

  constructor() {
    this.chain = [Block.genesis()];
  }

  addBlock({ data }: { data: string }) {
    const newBlock = Block.mineBlock({ lastBlock: this.chain[this.chain.length - 1], data });

    this.chain.push(newBlock);
  }
}
