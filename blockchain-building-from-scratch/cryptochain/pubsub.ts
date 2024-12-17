import { createClient } from "redis";
import { Blockchain as ChainBlock } from "./blockchain";

type Publish = {
  channel: string;
  message: string;
};

type Blockchain = { blockchain: ChainBlock };

const CHANNELS = {
  TEST: "TEST",
  BLOCKCHAIN: "BLOCKCHAIN",
};

class PubSub {
  publisher: any;
  subscriber: any;
  blockchain: ChainBlock;

  constructor({ blockchain }: Blockchain) {
    this.blockchain = blockchain;
    this.publisher = createClient();
    this.subscriber = createClient();

    // this.subscriber.subscribe(CHANNELS.TEST);

    // this.subscriber.on("message", (channel: string, message: string) => this.handleMessage(channel, message));
    (async () => {
      // Connect both clients
      await this.publisher.connect();
      await this.subscriber.connect();

      //   // Subscribe to the channel and handle messages directly via callback
      //   await this.subscriber.subscribe(CHANNELS.TEST, (message: string) => {
      //     this.handleMessage(CHANNELS.TEST, message);
      //   });
      //   // Subscribe to the Blockchain CHannel
      //   await this.subscriber.subscribe(CHANNELS.TEST, (message: string) => {
      //     this.handleMessage(CHANNELS.TEST, message);
      //   });

      this.subscribeToChannels();
    })();
  }
  subscribeToChannels() {
    Object.values(CHANNELS).forEach(async (channel) => {
      await this.subscriber.subscribe(channel, (message: string, channel: string) => {
        this.handleMessage(channel, message);
      });
    });
  }

  handleMessage(channel: string, message: string) {
    console.log(`\nMessage Received. Channel: ${channel}. Message: ${message}`);

    const parsedMessage = JSON.parse(message);

    if (channel == CHANNELS.BLOCKCHAIN) {
      this.blockchain.replaceChain(parsedMessage);
    }
  }

  publish({ channel, message }: Publish) {
    this.subscriber
      .unsubscribe(channel)
      .then(() => {
        return this.publisher.publish(channel, message);
      })
      .then((numClients: any) => {
        // console.log("Published to:", numClients, "subscriber(s)");
        return this.subscriber.subscribe(channel, () => {
          // Do nothing on message
        });
      })
      .then(() => {
        // All done
      });
  }

  broadcastChain() {
    this.publish({
      channel: CHANNELS.BLOCKCHAIN,
      message: JSON.stringify(this.blockchain.chain),
    });
  }
}

export default PubSub;
