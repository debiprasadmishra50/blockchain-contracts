import { createHash } from "crypto";
import hexToBinary from "./hex-to-binary";

export const sha256 = (...args: (string | number)[]): string =>
  createHash("sha256").update(args.sort().join(" ")).digest("hex");

export const binaryHash = (...args: (string | number)[]) => hexToBinary(sha256(...args));
