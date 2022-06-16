import web3 from "./web3";
import CampaignFactory from "./build/CampaignFactory.json";

const instance = new web3.eth.Contract(
    JSON.parse(CampaignFactory.interface),
    "0x2932a026bc05dcB6Efd3734bbe8De7231f6647Ff"
);

export default instance;
