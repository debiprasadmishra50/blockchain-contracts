import React from "react";
import { Table, Button } from "semantic-ui-react";
import web3 from "../ethereum/web3";
import CampaignContract from "../ethereum/campaign";
import { Router } from "../routes";

class RequestRow extends React.Component {
    async onApprove(e) {
        e.preventDefault();

        const campaign = CampaignContract(this.props.address);
        const accounts = await web3.eth.getAccounts();
        await campaign.methods
            .approveRequest(this.props.id)
            .send({ from: accounts[0] });

        Router.replaceRoute(`/campaigns/${this.props.address}/requests`);
    }

    async onFinalize(e) {
        e.preventDefault();

        const campaign = CampaignContract(this.props.address);
        const accounts = await web3.eth.getAccounts();
        await campaign.methods
            .finaliseRequest(this.props.id)
            .send({ from: accounts[0] });

        Router.replaceRoute(`/campaigns/${this.props.address}/requests`);
    }

    render() {
        const { Row, Cell } = Table;
        const { id, request, approversCount, address } = this.props;
        const readyToFinalize = request.approvalCount > approversCount / 2;
        return (
            <Row
                disabled={request.complete}
                warning={readyToFinalize && !request.complete}
            >
                <Cell>{id}</Cell>
                <Cell>{request.description}</Cell>
                <Cell>{web3.utils.fromWei(request.value, "ether")}</Cell>
                <Cell>{request.recipient}</Cell>
                <Cell>
                    {request.approvalCount}/{approversCount}
                </Cell>
                <Cell>
                    {request.complete ? null : (
                        <Button
                            color="green"
                            basic
                            onClick={this.onApprove.bind(this)}
                        >
                            Approve
                        </Button>
                    )}
                </Cell>
                <Cell>
                    {request.complete ? null : (
                        <Button
                            color="teal"
                            basic
                            onClick={this.onFinalize.bind(this)}
                        >
                            Finalize
                        </Button>
                    )}
                </Cell>
            </Row>
        );
    }
}

export default RequestRow;
