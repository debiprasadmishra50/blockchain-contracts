import { createHash } from "crypto";
import hexToBinary from "./hex-to-binary";

export const sha256 = (...args: (string | number | { [key: string]: number | string })[]): string =>
  createHash("sha256")
    .update(
      args
        .map((input) => JSON.stringify(input))
        .sort()
        .join(" ")
    )
    .digest("hex");

export const binaryHash = (...args: (string | number)[]) => hexToBinary(sha256(...args));
