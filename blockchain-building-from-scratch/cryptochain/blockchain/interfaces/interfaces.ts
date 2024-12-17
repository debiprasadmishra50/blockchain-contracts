import Block from "../block";

export interface BlockData {
  timestamp: number;
  lastHash: string;
  hash: string;
  data: any;
  nonce: number;
  difficulty: number;
}

export interface MineBlockData {
  lastBlock: BlockData;
  data: string;
}

export interface AdjustDifficulty {
  originalBlock: BlockData;
  timestamp: number;
}
