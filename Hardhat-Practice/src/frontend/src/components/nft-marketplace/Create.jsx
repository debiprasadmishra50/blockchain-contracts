import { useState } from "react";
import { ethers } from "ethers";
import { Row, Form, Button } from "react-bootstrap";
import { create as ipfsHttpClient } from "ipfs-http-client";

const headers = new Headers();
headers.set("Access-Control-Allow-Origin", "['*']");
headers.set("Access-Control-Allow-Credentials", "'true'");
headers.set("Access-Control-Allow-Methods", ["PUT", "GET", "POST"]);

// console.log(headers.get("Access-Control-Allow-Origin"));

const client = ipfsHttpClient({
  // url: "http://127.0.0.1:5001/api/v0",
  url: "/ip4/127.0.0.1/tcp/5001",
  headers: {
    "'Access-Control-Allow-Origin'": "['localhost:3000', '*', 'http://localhost:3000']",
    "'Access-Control-Allow-Methods'": ["GET", "GET", "POST", "OPTIONS"],
    Origin: "http://localhost:3000",
    // crossorigin: "anonymous",
    // mode: "no-cors",
  },
  // headers,
});
// console.log(client.getEndpointConfig());

const Create = ({ marketplace, nft }) => {
  const [image, setImage] = useState("");
  const [price, setPrice] = useState(null);
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");

  const uploadToIPFS = async (e) => {
    const id = await client.id();
    console.log(id);

    e.preventDefault();
    const file = e.target.files[0];
    if (typeof file !== "undefined") {
      try {
        const result = await client.add(file);
        console.log(result);
        setImage(`http://127.0.0.1:5001/ipfs/${result.path}`);
      } catch (error) {
        console.log("ipfs image upload error: ", error);
      }
    }
  };

  const createNFT = async () => {
    if (!image || !price || !name || !description) return;

    try {
      const result = await client.add(JSON.stringify({ image, price, name, description }));

      mintAndList(result);
    } catch (error) {
      console.log("ipfs uri upload error: ", error);
    }
  };

  const mintAndList = async (result) => {
    const uri = `http://127.0.0.1:5001/ipfs/${result.path}`;
    // mint nft
    await (await nft.mint(uri)).wait();
    // get tokenId of new nft
    const id = await nft.tokenCount();
    // approve marketplace to spend nft
    await (await nft.setApprovalForAll(marketplace.address, true)).wait();
    // add nft to marketplace
    const listingPrice = ethers.utils.parseEther(price.toString());
    await (await marketplace.makeItem(nft.address, id, listingPrice)).wait();
  };

  return (
    <div className="container-fluid mt-5">
      <div className="row">
        <main role="main" className="col-lg-12 mx-auto" style={{ maxWidth: "1000px" }}>
          <div className="content mx-auto">
            <Row className="g-4">
              <Form.Control type="file" required name="file" onChange={uploadToIPFS} />

              <Form.Control
                onChange={(e) => setName(e.target.value)}
                size="lg"
                required
                type="text"
                placeholder="Name"
              />

              <Form.Control
                onChange={(e) => setDescription(e.target.value)}
                size="lg"
                required
                as="textarea"
                placeholder="Description"
              />

              <Form.Control
                onChange={(e) => setPrice(e.target.value)}
                size="lg"
                required
                type="number"
                placeholder="Price in ETH"
              />

              <div className="d-grid px-0">
                <Button onClick={createNFT} variant="primary" size="lg">
                  Create & List NFT!
                </Button>
              </div>
            </Row>
          </div>
        </main>
      </div>
    </div>
  );
};

export default Create;
