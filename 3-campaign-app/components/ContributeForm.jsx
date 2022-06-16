import React from "react";
import { Form, Input, Message, Button } from "semantic-ui-react";
import Campaign from "../ethereum/campaign";
import web3 from "../ethereum/web3";
import { Router } from "../routes";

class ContributeForm extends React.Component {
    state = {
        value: "",
        errMsg: "",
        loading: false,
    };

    async onSubmit(e) {
        e.preventDefault();

        this.setState({ loading: true, errMsg: "" });
        const campaign = Campaign(this.props.address);
        try {
            const accounts = await web3.eth.getAccounts();
            await campaign.methods.contribute().send({
                from: accounts[0],
                value: web3.utils.toWei(this.state.value, "ether"),
            });

            Router.replaceRoute(`/campaigns/${this.props.address}`);
        } catch (err) {
            this.setState({ errMsg: err.message });
        }

        this.setState({ loading: false, value: "" });
    }

    render() {
        return (
            <Form
                onSubmit={this.onSubmit.bind(this)}
                error={!!this.state.errMsg}
            >
                <Form.Field>
                    <label>Amount to Contribute</label>
                    <Input
                        label="ether"
                        labelPosition="right"
                        placeholder="amount to contribute in ether"
                        value={this.state.value}
                        onChange={(e) =>
                            this.setState({ value: e.target.value })
                        }
                    />
                </Form.Field>

                <Message error header="Oops!" content={this.state.errMsg} />
                <Button primary loading={this.state.loading}>
                    Contribute!
                </Button>
            </Form>
        );
    }
}

export default ContributeForm;
