import * as dotenv from "dotenv";
dotenv.config({ path: ".env" });

// Core interfaces
import {
  createAgent,
  IDIDManager,
  IResolver,
  IDataStore,
  IDataStoreORM,
  IKeyManager,
  ICredentialPlugin,
} from "@veramo/core";

// Core identity manager plugin
import { DIDManager, MemoryDIDStore } from "@veramo/did-manager";

// Ethr did identity provider
import { EthrDIDProvider } from "@veramo/did-provider-ethr";

// Core key manager plugin
import { KeyManager, MemoryKeyStore, MemoryPrivateKeyStore } from "@veramo/key-manager";

// Custom key management system for RN
import { KeyManagementSystem, SecretBox } from "@veramo/kms-local";

// W3C Verifiable Credential plugin
import { CredentialPlugin } from "@veramo/credential-w3c";

import {
  ContextDoc,
  CredentialIssuerLD,
  LdDefaultContexts,
  VeramoEd25519Signature2018,
  VeramoEcdsaSecp256k1RecoverySignature2020,
} from "@veramo/credential-ld";

import { CredentialIssuerEIP712 } from "@veramo/credential-eip712";

// Custom resolvers
import { DIDResolverPlugin } from "@veramo/did-resolver";
import { Resolver } from "did-resolver";
import { getResolver as ethrDidResolver } from "ethr-did-resolver";
import { getResolver as webDidResolver } from "web-did-resolver";

// Storage plugin using TypeOrm
import { Entities, KeyStore, DIDStore, PrivateKeyStore, migrations } from "@veramo/data-store";

// TypeORM is installed with `@veramo/data-store`
import { DataSource } from "typeorm";

// This will be the name for the local sqlite database for demo purposes
const DATABASE_FILE = "database.sqlite";

// You will need to get a project ID from infura https://www.infura.io
const INFURA_PROJECT_ID = process.env.INFURA_KEY;

// This will be the secret key for the KMS
// npx @veramo/cli config create-secret-key
const KMS_SECRET_KEY = "6100dbd2c6344bfde9af9f32475711747df244478c331eb207f13b3ea9525272";

// const dbConnection = new DataSource({
//   type: "sqlite",
//   database: DATABASE_FILE,
//   synchronize: false,
//   migrations,
//   migrationsRun: true,
//   logging: ["error", "info", "warn"],
//   entities: Entities,
// }).initialize();

export const MY_CUSTOM_CONTEXT_URI = "https://example.com/custom/context";

const extraContexts: Record<string, ContextDoc> = {};
extraContexts[MY_CUSTOM_CONTEXT_URI] = {
  "@context": {
    nothing: "https://example.com/custom/context",
    // you: "Debi",
  },
};

export const agent = createAgent<
  IDIDManager & IKeyManager & IDataStore & IDataStoreORM & IResolver & ICredentialPlugin
>({
  plugins: [
    new KeyManager({
      // // Which key manager you wish to use, either in database or in memory
      //   store: new KeyStore(dbConnection),
      //   kms: {
      //     local: new KeyManagementSystem(new PrivateKeyStore(dbConnection, new SecretBox(KMS_SECRET_KEY))),
      //   },
      store: new MemoryKeyStore(),
      kms: {
        local: new KeyManagementSystem(new MemoryPrivateKeyStore()), // for this sample, keys are stored in memory
      },
    }),
    new DIDManager({
      // // where do you wish to store the keys
      //   store: new DIDStore(dbConnection), // will be stored in sqllite database generated on the fly
      store: new MemoryDIDStore(), // will be stored in memory
      defaultProvider: "did:ethr:goerli",
      providers: {
        "did:ethr:goerli": new EthrDIDProvider({
          defaultKms: "local",
          network: "goerli",
          rpcUrl: "https://goerli.infura.io/v3/" + INFURA_PROJECT_ID,
          //   gas: 100000,
          //   ttl: 60 * 60 * 24 * 30 * 12 + 1,
        }),
      },
    }),
    new DIDResolverPlugin({
      resolver: new Resolver({
        ...ethrDidResolver({ infuraProjectId: INFURA_PROJECT_ID }),
        ...webDidResolver(),
      }),
    }),
    new CredentialPlugin(),
    new CredentialIssuerLD({
      contextMaps: [LdDefaultContexts, extraContexts],
      suites: [
        new VeramoEd25519Signature2018(),
        new VeramoEcdsaSecp256k1RecoverySignature2020(), //needed for did:ethr
      ],
    }),
    new CredentialIssuerEIP712(),
  ],
});
