// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "./IERC20.sol";

/* 
    1. Deploy 2 ERC20 contracts and pass the address and deploy the StakingRewards
        - 1st token: stakingToken, 2nd token: rewardToken
    2. owner: 1st user account, staker: 2nd user account
    3. setRewardsDuration(1000) 
    4. mint 2nd ERC20 tokens: rewards tokens: 1000000000000000000000 (10^(18+3)) 1000tokens
    5. transfer(staking contract, 1000000000000000000000): reward token
    6. notifyRewardAmount(1000000000000000000000): Staking contract
    7. switch to 2nd account
    8. mint 1000 staking(1st) tokens: 1000000000000000000000
    9. approve(stakingContract, 1000000000000000000000)
    10. stake(1000000000000000000000) in stakingContract
    11. balanceOf with user2 address
    12. earned(user2)
    13. getReward()
    14. go to reward token, in balanceOf put user2 to check the rewards
    15. stakingContract: withdraw(1000000000000000000000)
    
*/
contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;

    uint256 public duration;
    uint256 public finishAt;
    uint256 public updatedAt;
    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf; // amount user has staked

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // owner will be able to set reward duration
    function setRewardDuration(uint256 _duration) external onlyOwner {
        require(block.timestamp > finishAt, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint256 _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        // reward duration hasn't expired or hasn't started
        if (block.timestamp > finishAt) {
            rewardRate = _amount / duration;
        } else {
            // compute the amount of remaining rewards
            uint256 remainingRewards = rewardRate *
                (finishAt - block.timestamp);
            rewardRate = (remainingRewards + _amount) / duration;
        }
        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(block.timestamp, finishAt);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalSupply;
    }

    function earned(address _account) public view returns (uint256) {
        return
            (balanceOf[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) /
            1e18 +
            rewards[_account];
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];

        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x < y ? x : y;
    }
}
