import Block from "../block";
import { sha256 } from "../utils/sha256-hash";

describe("Block", () => {
  const timestamp = Date.now();
  const lastHash = "last-hash";
  const hash = "cur-hash";
  const data = ["blockchain", "data"];

  it("has a timestamp, lastHash, hash and data property", () => {
    const block = new Block({ timestamp, lastHash, hash, data });

    expect(block.timestamp).toEqual(timestamp);
    expect(block.lastHash).toEqual(lastHash);
    expect(block.hash).toEqual(hash);
    expect(block.data).toEqual(data);
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

    it("creates a SHA-256 `hash` based on the priper inputs`", () => {
      expect(minedBlock.hash).toEqual(sha256(minedBlock.timestamp, lastBlock.hash, data));
    });
  });
});
