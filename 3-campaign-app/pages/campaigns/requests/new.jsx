import React from "react";
import { Form, Button, Message, Input } from "semantic-ui-react";
import Layout from "../../../components/Layout";
import CampaignContract from "../../../ethereum/campaign";
import web3 from "../../../ethereum/web3";
import { Link, Router } from "../../../routes";

class RequestNew extends React.Component {
    state = {
        value: "",
        description: "",
        recipient: "",
        loading: false,
        errMsg: "",
    };

    static async getInitialProps(props) {
        const { address } = props.query;

        return { address };
    }

    async onSubmit(e) {
        e.preventDefault();

        const campaign = CampaignContract(this.props.address);

        const { description, value, recipient } = this.state;

        try {
            const accounts = await web3.eth.getAccounts();

            this.setState({ loading: true, errMsg: "" });

            await campaign.methods
                .createRequest(
                    description,
                    web3.utils.toWei(value, "ether"),
                    recipient
                )
                .send({
                    from: accounts[0],
                });

            Router.pushRoute(`/campaigns/${this.props.address}/requests`);
        } catch (err) {
            this.setState({ errMsg: err.message });
        }
        this.setState({
            loading: false,
            value: "",
            recipient: "",
            description: "",
        });
    }

    render() {
        return (
            <Layout>
                <Link route={`/campaigns/${this.props.address}/requests`}>
                    <a>{"<"}Back</a>
                </Link>
                <h3>Create a Request: </h3>
                <Form
                    onSubmit={this.onSubmit.bind(this)}
                    error={!!this.state.errMsg}
                >
                    <Form.Field>
                        <label>Description</label>
                        <Input
                            value={this.state.description}
                            onChange={(e) =>
                                this.setState({ description: e.target.value })
                            }
                            placeholder="description"
                        ></Input>
                    </Form.Field>
                    <Form.Field>
                        <label>Value in ether</label>
                        <Input
                            value={this.state.value}
                            onChange={(e) =>
                                this.setState({ value: e.target.value })
                            }
                            placeholder="value in ether"
                        ></Input>
                    </Form.Field>
                    <Form.Field>
                        <label>Recipient</label>
                        <Input
                            value={this.state.recipient}
                            onChange={(e) =>
                                this.setState({ recipient: e.target.value })
                            }
                            placeholder="recipient address"
                        ></Input>
                    </Form.Field>

                    <Message
                        error
                        header="Oops!"
                        content={this.state.errMsg}
                    ></Message>
                    <Button primary loading={this.state.loading}>
                        Create!
                    </Button>
                </Form>
            </Layout>
        );
    }
}

export default RequestNew;
