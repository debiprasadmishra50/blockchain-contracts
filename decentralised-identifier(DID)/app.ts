import { CredentialPayload } from "@veramo/core";
import { agent, MY_CUSTOM_CONTEXT_URI } from "./setup";

async function listIdentifiers() {
  const identifiers = await agent.didManagerFind();

  console.log(`There are ${identifiers.length} identifiers`);

  if (identifiers.length > 0) {
    identifiers.map((id) => {
      console.log(id);
    });
  }
}

async function createIdentifier() {
  const identifier = await agent.didManagerCreate({ alias: "default" });
  console.log(`New identifier created`);
  console.log(JSON.stringify(identifier, null, 2));
}

async function createCredential() {
  const issuer = await agent.didManagerGetByAlias({ alias: "default" });

  const credential: CredentialPayload = {
    "@context": [MY_CUSTOM_CONTEXT_URI],
    issuer: issuer.did,
    credentialSubject: {
      nothing: "else matters", // the `nothing` property is defined in the custom context (See ./setup.ts)
      //   you: "Debi Prasad",
    },
    // credentialStatus: { id: issuer.did, type: "active" },
    // issuanceDate: new Date(),
  };

  const verifiableCredential = await agent.createVerifiableCredential({
    credential,

    // Shuffle the proof format with the requirement
    proofFormat: "jwt",
    // proofFormat: "lds",
    // proofFormat: "EthereumEip712Signature2021",
  });
  console.log(`New credential created`);
  console.log(JSON.stringify(verifiableCredential, null, 2));
}

async function verifyCredential() {
  const result = await agent.verifyCredential({
    credential: {
      credentialSubject: {
        nothing: "else matters",
        you: "Debi Prasad",
      },
      //   credentialStatus: {
      //     id: "did:ethr:goerli:0x02be159c80f43ac73f0a89712c1058524f7d61909ca4de878056d583e4d080d887",
      //     type: "active",
      //   },
      issuer: {
        id: "did:ethr:goerli:0x035b42ddce955932fd511c973a4621cca652694f1c4f807fb949a8820f2e10faeb",
      },
      type: ["VerifiableCredential"],
      "@context": ["https://www.w3.org/2018/credentials/v1"],
      issuanceDate: "2022-11-17T06:00:42.000Z",
      proof: {
        type: "JwtProof2020",
        jwt: "eyJhbGciOiJFUzI1NksiLCJ0eXAiOiJKV1QifQ.eyJ2YyI6eyJAY29udGV4dCI6WyJodHRwczovL3d3dy53My5vcmcvMjAxOC9jcmVkZW50aWFscy92MSIsImh0dHBzOi8vZXhhbXBsZS5jb20vY3VzdG9tL2NvbnRleHQiXSwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCJdLCJjcmVkZW50aWFsU3ViamVjdCI6eyJub3RoaW5nIjoiZWxzZSBtYXR0ZXJzIiwieW91IjoiRGViaSBQcmFzYWQifX0sIm5iZiI6MTY2ODY2NDg0MiwiaXNzIjoiZGlkOmV0aHI6Z29lcmxpOjB4MDM1YjQyZGRjZTk1NTkzMmZkNTExYzk3M2E0NjIxY2NhNjUyNjk0ZjFjNGY4MDdmYjk0OWE4ODIwZjJlMTBmYWViIn0.wcHH-8MyqTetj_su7fqUsbLNsatQW3WjIlpRtCruxBHLx5VmEGjrSxSm8syVs99WFDEFJrlrt9hVX4kazuX-4Q",
      },
    },
  });
  console.log(`Credential verified`, result.verified);
}

async function run() {
  //   await listIdentifiers();
  //   console.log("\n-------------------------------------\n");

  await createIdentifier();
  console.log("\n-------------------------------------\n");

  //   await listIdentifiers();
  //   console.log("\n-------------------------------------\n");

  await createCredential();
  //   console.log("\n-------------------------------------\n");

  //   await verifyCredential();
}

run().catch(console.log);
