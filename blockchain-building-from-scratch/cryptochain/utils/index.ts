import { ec as EC } from "elliptic";
import { sha256 } from "./sha256-hash";

export type SignatureType = EC.Signature;

export type SignaturePayload = {
  publicKey: string;
  data: any;
  signature: SignatureType;
};

const ec = new EC("secp256k1"); // SECP: Standards of Efficient Cryptography 256 bits k: Neil Koblitz 1: first implementation

export const verifySignature = ({ publicKey, data, signature }: SignaturePayload) => {
  const keyFromPublic = ec.keyFromPublic(publicKey, "hex");

  return keyFromPublic.verify(sha256(data), signature);
};

export { sha256 };
export type KeyPair = EC.KeyPair;
export default ec;
