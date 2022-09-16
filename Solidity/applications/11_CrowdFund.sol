// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

/* 
Crowd Funding
    - campaign creator can create new campaigns to raise funds for an idea
    - Users can pledge/donate to a campaign and donate a amount
    - Users can donate ERC20 tokens
    - campaign creator can cancel the campaign he created
    - users can get the refund

    For security reasons, each crowdfunding contract will only be able to handle one token only
*/

/* 
Deployment
    1. Deploy ERC20 contract
    2. Deploy Crowd Funding by providing the ERC20 address
    3. mint 100 tokens in second account as 1st account will be the campaign owner/creator
    4. switch to 1st account and execute launch() from CrowdFund, provide the goal to be 100, started at now and ended at a future time (100secs)
    5. switch to 2 and approve() in ERC20, provide the address of CrowdFund, 100
    6. execute pledge() in CrowdFund, id 1, amount 100
    7. execute campaigns() with id 1
    8. pledgedAmount: 1, 2nd account
    9. switch to account 1 and claim(): id 1
    10. check for both accounts in balanceOf of ERC20
*/
contract CrowdFund {
    event Launch(
        uint256 id,
        address indexed creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 indexed id, address indexed caller, uint256 amount);

    struct Campaign {
        address creator;
        uint256 goal;
        uint256 pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint256 public count;
    mapping(uint256 => Campaign) public campaigns;
    // campaignId => user => amount-pledged
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /* 
        Launch a campaign
        _goal: is the total no of token/money they want to raise
        _startAT: time when the campaign is started
        _endAt: time when the campaign is ended
    */
    function launch(
        uint256 _goal,
        uint32 _startAt,
        uint32 _endAt
    ) external {
        require(_startAT >= block.timestamp, "start at < now");
        require(_endAt >= _startAT, "end at <  start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    /* 
        Campaign creator can cancel the campaign, if the campaign is not yet started
    */
    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "campaign started");

        delete campaigns[_id];

        emit Cancel(_id);
    }

    /* 
        user can pledge to a campaign, specifying the _amount they want to send to this campaign
        when this is called, the _amount of token will be transferred to this contract while the campaign is in progress
    */
    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    /* 
        perhaps the user wants to change their mind on the amount of token they pledged, then they can call unpledge while the campaign is in progress
    */
    function unpledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    /* 
        IF the amount raised is > goal, then campaign creator will be able to claim all of the tokens that were pledged
    */
    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(_id);
    }

    /* 
        If the campaign was unsuccessful, the amount of token peldged by all users < _goal, users can call this function to get their tokens back
    */
    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");

        uint256 bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
