import { createHash } from "crypto";

export const sha256 = (...args: (string | number)[]): string =>
  createHash("sha256").update(args.sort().join(" ")).digest("hex");
