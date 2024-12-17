import { GENESIS_DATA, MINE_RATE } from "./config";
import { AdjustDifficulty, BlockData, MineBlockData } from "./interfaces";
import { binaryHash, sha256 } from "./utils/sha256-hash";

class Block {
  timestamp: number;
  lastHash: string;
  hash: string;
  data: any;
  difficulty: number;
  nonce: number;

  constructor(blockData: BlockData) {
    this.timestamp = blockData.timestamp;
    this.lastHash = blockData.lastHash;
    this.hash = blockData.hash;
    this.data = blockData.data;
    this.nonce = blockData.nonce;
    this.difficulty = blockData.difficulty;
  }

  static genesis(): Block {
    return new this(GENESIS_DATA);
  }

  static mineBlock(mineBlockData: MineBlockData): Block {
    const { lastBlock, data } = mineBlockData;
    const lastHash = lastBlock.hash;

    let hash, timestamp;
    let { difficulty } = lastBlock;
    let nonce = 0;

    do {
      nonce++;
      timestamp = Date.now();
      difficulty = Block.adjustDifficulty({ originalBlock: lastBlock, timestamp });
      // NOTE: HEX Version of Hash
      hash = sha256(timestamp, lastHash, data, nonce, difficulty);

      // // NOTE: Binary Version of Hash
      // hash = binaryHash(timestamp, lastHash, data, nonce, difficulty);
    } while (hash.substring(0, difficulty) !== "0".repeat(difficulty));

    return new this({ timestamp, lastHash, nonce, difficulty, hash, data });
  }

  static adjustDifficulty(params: AdjustDifficulty): any {
    const { originalBlock, timestamp } = params;

    const { difficulty } = originalBlock;

    if (difficulty < 1) return 1;

    if (timestamp - originalBlock.timestamp > MINE_RATE) return difficulty - 1;

    return difficulty + 1;
  }
}

export default Block;

// const block1 = new Block({
//   timestamp: new Date().toISOString(),
//   lastHash: "lasthash",
//   hash: "hash",
//   data: "data string",
// });

// console.log("[+] Block 1", block1);
