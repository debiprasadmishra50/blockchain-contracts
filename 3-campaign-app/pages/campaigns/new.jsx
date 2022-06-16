import React from "react";
import { Form, Button, Input, Message } from "semantic-ui-react";
import Layout from "../../components/Layout";
import factory from "../../ethereum/factory";
import web3 from "../../ethereum/web3";
import { Link, Router } from "../../routes";

class CampaignNew extends React.Component {
    state = {
        minimumContribution: "",
        errMsg: "",
        loading: false,
    };

    async onsubmit(e) {
        e.preventDefault();
        this.setState({ loading: true, errMsg: "" });

        try {
            const accounts = await web3.eth.getAccounts();
            await factory.methods
                .createCampaign(this.state.minimumContribution)
                .send({ from: accounts[0] });

            Router.pushRoute("/");
        } catch (err) {
            this.setState({ errMsg: err.message });
        }

        this.setState({ loading: false });
    }

    render() {
        return (
            <Layout>
                <h1>New Campaign!</h1>

                <Form
                    onSubmit={this.onsubmit.bind(this)}
                    style={{ padding: "0px 5px 10px" }}
                    error={this.state.errMsg ? true : false}
                >
                    <Form.Field>
                        <label htmlFor="min-contribution">
                            Minimum Contribution
                        </label>
                        <Input
                            label="wei"
                            labelPosition="right"
                            placeholder="minimum 100 wei to contribute"
                            id="min-contribution"
                            value={this.state.minimumContribution}
                            onChange={(e) =>
                                this.setState({
                                    minimumContribution: e.target.value,
                                })
                            }
                        />
                    </Form.Field>

                    <Message error header="Oops!" content={this.state.errMsg} />
                    <Button primary loading={this.state.loading}>
                        Create!
                    </Button>
                </Form>
            </Layout>
        );
    }
}

export default CampaignNew;
