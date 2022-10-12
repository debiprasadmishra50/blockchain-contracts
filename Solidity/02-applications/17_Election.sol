// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    mapping(address => bool) public voters;
    mapping(uint256 => Candidate) public candidates;

    uint256 public candidatesCount;

    constructor() public {
        _addCandidate("Candidate 1");
        _addCandidate("Candidate 2");
    }

    function _addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint256 _candidateId) external {
        require(!voters[msg.sender], "already voted");
        require(
            _candidateId > 0 && _candidateId <= candidatesCount,
            "invalid candidate id"
        );

        voters[msg.sender] = true;

        candidates[_candidateId].voteCount++;
    }
}
