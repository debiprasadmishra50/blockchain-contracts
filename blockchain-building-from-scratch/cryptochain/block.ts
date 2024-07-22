import { GENESIS_DATA } from "./config";
import { BlockData, MineBlockData } from "./interfaces";
import { sha256 } from "./utils/sha256-hash";

class Block {
  timestamp: number;
  lastHash: string;
  hash: string;
  data: any;

  constructor(blockData: BlockData) {
    this.timestamp = blockData.timestamp;
    this.lastHash = blockData.lastHash;
    this.hash = blockData.hash;
    this.data = blockData.data;
  }

  static genesis(): Block {
    return new this(GENESIS_DATA);
  }

  static mineBlock(mineBlockData: MineBlockData): Block {
    const timestamp = Date.now();
    const lastHash = mineBlockData.lastBlock.hash;
    const data = mineBlockData.data;

    return new this({
      timestamp,
      lastHash,
      hash: sha256(timestamp, lastHash, data),
      data,
    });
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
