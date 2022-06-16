import React from "react";
import web3 from "../web3";
import lottery from "../lottery";

class App extends React.Component {
    state = {
        manager: "",
        players: [],
        balance: "",
        value: "",
        message: "",
    };

    async componentDidMount() {
        const manager = await lottery.methods.manager().call();
        const players = await lottery.methods.getPlayers().call();
        const balance = await web3.eth.getBalance(lottery.options.address);

        this.setState({ manager, players, balance });
    }

    async onSubmit(e) {
        e.preventDefault();

        const accounts = await web3.eth.getAccounts();

        this.setState({ message: "waiting on transaction success..." });

        await lottery.methods.enter().send({
            from: accounts[0],
            value: web3.utils.toWei(this.state.value, "ether"),
        });

        this.setState({
            message: "You just entered the lottery, congratulations!",
            value: "",
        });
    }

    async onClick(e) {
        const accounts = await web3.eth.getAccounts();

        this.setState({ message: "waiting on transaction success..." });

        await lottery.methods.pickWinner().send({ from: accounts[0] });

        this.setState({ message: "A winner has been picked!" });
    }

    render() {
        // console.log(web3.version);

        // web3.eth.getAccounts().then(console.log);

        return (
            <div>
                <h2 style={{ borderBottom: "1px solid #333" }}>
                    Lottery Contract
                </h2>
                <p>This contract is managed by {this.state.manager}</p>
                <p>
                    There are currently {this.state.players.length} people
                    entered, competing to win{" "}
                    {web3.utils.fromWei(this.state.balance, "ether")} ether!
                </p>

                <hr />

                <form onSubmit={this.onSubmit.bind(this)}>
                    <h4>Want to try our luck!</h4>
                    <div>
                        <label htmlFor="amount">
                            Amount of ether to enter: &nbsp;
                        </label>
                        <input
                            type="text"
                            name="amount"
                            id="amount"
                            placeholder="amount"
                            onChange={(e) =>
                                this.setState({ value: e.target.value })
                            }
                            value={this.state.value}
                        />
                    </div>
                    <button>Enter</button>
                </form>

                <hr />
                <h4>Ready to pick a winner?</h4>
                <button onClick={this.onClick.bind(this)}>
                    Pick a winner!
                </button>
                <hr />

                <h2>{this.state.message}</h2>
            </div>
        );
    }
}

export default App;
