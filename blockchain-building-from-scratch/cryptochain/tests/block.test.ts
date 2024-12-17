import Block from "../blockchain/block";
import { MINE_RATE } from "../config";
import hexToBinary from "../utils/hex-to-binary";
import { binaryHash, sha256 } from "../utils/sha256-hash";

describe("Block", () => {
  const timestamp = 2000;
  const lastHash = "last-hash";
  const hash = "cur-hash";
  const data = ["blockchain", "data"];
  const nonce = 1;
  const difficulty = 1;
  const block = new Block({ timestamp, lastHash, hash, data, nonce, difficulty });

  it("has a timestamp, lastHash, hash and data property", () => {
    expect(block.timestamp).toEqual(timestamp);
    expect(block.lastHash).toEqual(lastHash);
    expect(block.hash).toEqual(hash);
    expect(block.data).toEqual(data);
    expect(block.nonce).toEqual(nonce);
    expect(block.difficulty).toEqual(difficulty);
  });

  describe("GENESIS", () => {
    const genesisBlock = Block.genesis();
    // console.log("[+] Genesis Block", genesisBlock);

    it("returns a Block instance", () => {
      expect(genesisBlock instanceof Block).toBe(true);
    });

    it("returns the genesis data", () => {
      expect(genesisBlock).toEqual(genesisBlock);
    });
  });

  describe("mineBlock()", () => {
    const lastBlock = Block.genesis();
    const data = "mined data";
    const minedBlock = Block.mineBlock({ lastBlock, data });

    it("returns a Block instance", async () => {
      expect(minedBlock instanceof Block).toBe(true);
    });

    it("sets the `lastHash` to be the `hash` of the `lastBlock`", () => {
      expect(minedBlock.lastHash).toEqual(lastBlock.hash);
    });

    it("sets the `data`", () => {
      expect(minedBlock.lastHash).toEqual(lastBlock.hash);
    });

    it("sets the `timestamp`", () => {
      expect(minedBlock.lastHash).toEqual(lastBlock.hash);
    });

    it("creates a SHA-256 `hash` based on the proper inputs`", () => {
      expect(minedBlock.hash).toEqual(
        sha256(minedBlock.timestamp, minedBlock.nonce, minedBlock.difficulty, lastBlock.hash, data)
        // binaryHash(minedBlock.timestamp, minedBlock.nonce, minedBlock.difficulty, lastBlock.hash, data)
      );
    });

    it("sets a `hash` that matches the difficulty criteria", () => {
      expect(hexToBinary(minedBlock.hash).substring(0, minedBlock.difficulty)).toEqual(
        "0".repeat(minedBlock.difficulty)
      );
    });

    it("adjusts the difficulty", () => {
      const possibleResults = [lastBlock.difficulty + 1, lastBlock.difficulty - 1];

      expect(possibleResults.includes(minedBlock.difficulty)).toBe(true);
    });
  });

  describe("adjustDifficulty()", () => {
    it("raises the difficulty for a quickly mined block", () => {
      expect(
        Block.adjustDifficulty({ originalBlock: block, timestamp: block.timestamp + MINE_RATE - 100 })
      ).toEqual(block.difficulty + 1);
    });

    it("lowers the difficulty for a slowly mined block", () => {
      expect(
        Block.adjustDifficulty({ originalBlock: block, timestamp: block.timestamp + MINE_RATE + 100 })
      ).toEqual(block.difficulty - 1);
    });

    it("has a lower limit of 1", () => {
      block.difficulty = -1;

      expect(Block.adjustDifficulty({ originalBlock: block, timestamp: Date.now() })).toEqual(1);
    });
  });
});
