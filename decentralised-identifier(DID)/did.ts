import * as dotenv from "dotenv";
dotenv.config({ path: ".env" });

import did from "did-jwt";
import { Resolver } from "did-resolver";
import { getResolver } from "ethr-did-resolver";

function wait(secs: number) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve(true);
    }, secs * 1000);
  });
}

const currentTimeInSecs = () => new Date().getTime() / 1000;

async function app() {
  console.log("[+] Private Address:", process.env.PRIVATE_KEY);
  console.log("[+] Account Address: ", process.env.ADDRESS);

  const signer = did.ES256KSigner(did.hexToBytes(process.env.PRIVATE_KEY));
  const issuer = `did:ethr:${process.env.ADDRESS}`;

  //   console.log(signer.toString());
  // https://www.rfc-editor.org/rfc/rfc7519#section-4.1.1
  let jwt = await did.createJWT(
    { aud: issuer, iat: currentTimeInSecs(), name: "Debi Prasad" },
    { issuer, signer },
    { alg: "ES256K" }
  );

  console.log("\n[+] JWT Token:", jwt);

  const decoded = did.decodeJWT(jwt);

  console.log("\n[+] Decoded JWT:", decoded);

  await wait(2);

  const resolver = new Resolver({ ...getResolver({ infuraProjectId: process.env.INFURA_KEY }) });

  const result = await did.verifyJWT(jwt, { resolver, audience: issuer });

  console.log("\n[+] Verified JWT:", result);

  //   const doc = await resolver.resolve(`${issuer}/some/path#fragment=123`);
  const doc = await resolver.resolve(`${issuer}`);
  console.log("\n[+] DID:", doc);
}

app();

/* 
    https://github.com/decentralized-identity/did-jwt
    https://github.com/decentralized-identity/did-resolver

    https://www.youtube.com/watch?v=t8lMCmjPKq4 : Introduction to Decentralized Identifiers (DID) - by Ivan Herman (W3C)
    https://iherman.github.io/did-talks/talks/2020-Fintech/#/1

    DID is a URN functionally but for access it can be resolved into 1 or more URLs
    URN: persistent name for a resource that will never change no matter it's location

    Sovrin Ledger

    https://dev.uniresolver.io


    >> use uport for ethr method
    https://www.uport.me
    https://veramo.io

    https://veramo.io/docs/node_tutorials/node_setup_identifiers

    did:ethr:0xbE67C00D971ed2B095A34F998D3cd2A30a4D8432

    did => https
    ethr => method

    https://github.com/veramolabs/veramo-nodejs-tutorial
    https://github.com/veramolabs/credential-ld-example/

    
*/
