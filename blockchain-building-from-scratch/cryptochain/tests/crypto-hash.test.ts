import { sha256 } from "../utils/sha256-hash";

describe("CryptoHash", () => {
  it("generated a SHA-256 hashed output", () => {
    expect(sha256("foo")).toEqual("2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae");
  });

  it("produces the same hash with the same input arguments in any order", () => {
    expect(sha256("foo", "bar")).toEqual(sha256("bar", "foo"));
  });
});
