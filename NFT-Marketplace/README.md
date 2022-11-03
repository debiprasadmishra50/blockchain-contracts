# Sample NFT Marketplace

Please follow the steps to run the application

Try running some of the following tasks:

```shell
yarn install

npx hardhat node

npx hardhat run src/scripts/Marketplace-deploy.ts

npx hardhat test src/test/Marketplace.ts

cd src/frontend

yarn run start

```

1. Install IPFS [https://docs.ipfs.tech/install/command-line/](https://docs.ipfs.tech/install/command-line/)

```shell
ipfs daemon --offline
```

    *uploaded files will be available in localhost:8080/ipfs/\<Hash\>*

Open [http://localhost:3000](http://localhost:3000) in browser and use the application.
