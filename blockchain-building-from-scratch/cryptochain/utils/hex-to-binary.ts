// Define a lookup object with hexadecimal to binary mappings
const lookup: Record<string, string> = {
  "0": "0000",
  "1": "0001",
  "2": "0010",
  "3": "0011",
  "4": "0100",
  "5": "0101",
  "6": "0110",
  "7": "0111",
  "8": "1000",
  "9": "1001",
  a: "1010",
  b: "1011",
  c: "1100",
  d: "1101",
  e: "1110",
  f: "1111",
  A: "1010",
  B: "1011",
  C: "1100",
  D: "1101",
  E: "1110",
  F: "1111",
};

// Function to convert hexadecimal string to binary string
function hexToBinary(s: string): string {
  return s
    .split("")
    .map((char) => lookup[char] || "")
    .join("");
}

// Export the function
export default hexToBinary;
