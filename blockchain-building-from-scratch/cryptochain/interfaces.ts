import Block from "./block";

export interface BlockData {
  timestamp: number;
  lastHash: string;
  hash: string;
  data: any;
}

export interface MineBlockData {
  lastBlock: Block;
  data: string;
}
