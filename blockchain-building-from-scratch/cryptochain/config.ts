export const MINE_RATE = 1000; // 1000 milisec =  1 sec
const INITIAL_DIFFICULTY = 3;
const INITIAL_NONCE = 0;

export const GENESIS_DATA = {
  timestamp: 1,
  lastHash: "-----",
  hash: "hash-one",
  data: [],
  nonce: INITIAL_NONCE,
  difficulty: INITIAL_DIFFICULTY,
};
