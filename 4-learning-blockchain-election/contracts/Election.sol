// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

contract Election {
    // model a candidate
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    // store a candidate
    // fetch candidate
    mapping (uint => Candidate) public candidates;

    // store accounts that have voted
    mapping (address => bool) public voters;

    // store candidates count
    uint public candidatesCount;

    event votedEvent(uint indexed _candidateId);

    // constructor() public {
    function Election() public {
        addCandidate("Candidate 1");
        addCandidate("Candidate 2");
    }

    function addCandidate(string name) private {
        candidatesCount++;

        candidates[candidatesCount] = Candidate(candidatesCount, name, 0);
    }

    function vote(uint voterId) public {
        // require that they haven't voted before
        require(!voters[msg.sender]);

        // require a valid candidate
        require(voterId > 0 && voterId <= candidatesCount);

        // record the voter has voted
        voters[msg.sender] = true;

        // update vote
        candidates[voterId].voteCount++;

        // trigger event
        votedEvent(voterId);
    }
}

/* 
    >> truffle console
    >> Election.deployed().then(res => app = res);
    >> app
    >> app.address
    >> app.methods
*/