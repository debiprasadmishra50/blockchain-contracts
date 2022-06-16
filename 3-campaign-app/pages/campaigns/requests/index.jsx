import React from "react";
import { Button, Table } from "semantic-ui-react";
import { Link } from "../../../routes";
import Layout from "../../../components/Layout";
import CampaignContract from "../../../ethereum/campaign";
import RequestRow from "../../../components/RequestRow";

class RequestIndex extends React.Component {
    static async getInitialProps(props) {
        const { address } = props.query;
        const campaign = CampaignContract(address);
        const requestCount = await campaign.methods.getRequestsCount().call();
        const approversCount = await campaign.methods.approversCount().call();

        const requests = await Promise.all(
            Array(+requestCount)
                .fill()
                .map((el, index) => {
                    return campaign.methods.requests(index).call();
                })
        );

        return { address, requests, requestCount, approversCount };
    }

    renderRows() {
        return this.props.requests.map((request, index) => {
            return (
                <RequestRow
                    request={request}
                    id={index}
                    key={index}
                    address={this.props.address}
                    approversCount={this.props.approversCount}
                />
            );
        });
    }

    render() {
        const { Header, Row, HeaderCell, Body } = Table;

        return (
            <Layout>
                <h3>Request List</h3>

                <Link route={`/campaigns/${this.props.address}/requests/new`}>
                    <a>
                        <Button
                            primary
                            floated="right"
                            style={{ marginBottom: "10px" }}
                        >
                            Add Request
                        </Button>
                    </a>
                </Link>

                <Table>
                    <Header>
                        <Row>
                            <HeaderCell>ID</HeaderCell>
                            <HeaderCell>Description</HeaderCell>
                            <HeaderCell>Amount</HeaderCell>
                            <HeaderCell>Recipient</HeaderCell>
                            <HeaderCell>Approval Count</HeaderCell>
                            <HeaderCell>Approve</HeaderCell>
                            <HeaderCell>Finalize</HeaderCell>
                        </Row>
                    </Header>

                    <Body>{this.renderRows()}</Body>
                </Table>
                <div>Found {this.props.requestCount} requests</div>
            </Layout>
        );
    }
}

export default RequestIndex;
