import Block from "./block";
import { binaryHash, sha256 } from "./utils/sha256-hash";

export class Blockchain {
  chain: Block[] = [];

  constructor() {
    this.chain = [Block.genesis()];
  }

  addBlock({ data }: { data: string }) {
    const newBlock = Block.mineBlock({ lastBlock: this.chain[this.chain.length - 1], data });

    this.chain.push(newBlock);
  }

  replaceChain(chain: Block[]): void | Block[] {
    if (chain.length <= this.chain.length) {
      console.error("incoming chain must be longer");

      return;
    }

    if (!Blockchain.isValidChain(chain)) {
      console.error("incoming chain must be longer");

      return;
    }

    console.log("replacing chain with", chain);

    this.chain = chain;
  }

  static isValidChain(chain: Block[]): boolean {
    if (JSON.stringify(chain[0]) !== JSON.stringify(Block.genesis())) return false;

    for (let i = 1; i < chain.length; i++) {
      const { timestamp, lastHash, data, hash, nonce, difficulty } = chain[i];

      const { hash: actualLastHash, difficulty: lastDifficulty } = chain[i - 1];

      if (lastHash !== actualLastHash) return false;

      // NOTE: HEX Version of Hash
      // const validatedHash = sha256(timestamp, lastHash, data, nonce, difficulty);

      // NOTE: Binary Version of Hash
      const validatedHash = binaryHash(timestamp, lastHash, data, nonce, difficulty);

      if (hash !== validatedHash) return false;

      if (Math.abs(lastDifficulty - difficulty) > 1) return false;
    }

    return true;
  }
}
