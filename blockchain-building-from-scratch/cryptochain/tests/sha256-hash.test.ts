import { sha256 } from "../utils/sha256-hash";

describe("SHA256 Hash", () => {
  it("generated a SHA-256 hashed output", () => {
    expect(sha256("foo")).toEqual("b2213295d564916f89a6a42455567c87c3f480fcd7a1c15e220f17d7169a790b");
  });

  it("produces the same hash with the same input arguments in any order", () => {
    expect(sha256("foo", "bar")).toEqual(sha256("bar", "foo"));
  });

  it("produces a unique hash when the properties have changed on an input", () => {
    const foo: { [key: string]: number | string } = {};
    const originalHash = sha256(foo);

    foo["a"] = "a";

    expect(sha256(foo)).not.toEqual(originalHash);
  });
});
