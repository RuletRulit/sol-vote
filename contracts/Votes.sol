// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Votes is Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    uint256 constant VOTE_DURATION = 3 days;
    uint256 constant VOTE_FEE = 0.01 ether;
    uint256 constant COMMISSION = 0.0015 ether;

    Counters.Counter private currentVoteId;

    struct Candidate {
        address candidateAddress;
        uint256 voteCount;
    }

    struct Vote {
        uint256 id;
        string info;
        Candidate[] candidates;
        uint256 startTime;
        bool isActive; // Flag to indicate if the vote is active
    }

    Vote[] private votes;

    function initializeCandidates(address[] memory voteCandidates) private pure returns (Candidate[] memory) {
        Candidate[] memory initializedCandidates = new Candidate[](voteCandidates.length);

        for (uint256 i = 0; i < voteCandidates.length; i++) {
            initializedCandidates[i] = Candidate(voteCandidates[i], 0);
        }

        return initializedCandidates;
    }

    function addVote(string memory info, address[] memory voteCandidates) private onlyOwner {
        uint voteId = currentVoteId.current();
        votes[voteId] = Vote(voteId, info, initializeCandidates(voteCandidates), block.timestamp, true);
        currentVoteId.increment();
    }

    function listVotes() public view returns (Vote[] memory) {
        return votes;
    }

    function vote(uint256 _voteId, address _candidate) public payable {
        require(votes[_voteId].isActive, "Vote ended");
        require(votes[_voteId].startTime.add(VOTE_DURATION) > block.timestamp, "Vote ended");
        require(msg.value == VOTE_FEE, "Insufficient amount");

        Vote storage currentVote = votes[_voteId];
        Candidate storage selectedCandidate = findCandidate(currentVote.candidates, _candidate);
        selectedCandidate.voteCount = selectedCandidate.voteCount.add(1);
    }

    function findCandidate(Candidate[] storage _candidates, address _candidateAddress)
        private
        view
        returns (Candidate storage)
    {
        for (uint256 i = 0; i < _candidates.length; i++) {
            if (_candidates[i].candidateAddress == _candidateAddress) {
                return _candidates[i];
            }
        }
        revert("Candidate not found");
    }

    function endVote(uint256 _voteId) public onlyOwner {
        require(votes[_voteId].isActive, "Vote already ended");

        Vote storage currentVote = votes[_voteId];
        require(currentVote.startTime.add(VOTE_DURATION) <= block.timestamp, "Vote still ongoing");

        currentVote.isActive = false;
    }

    function calcWinner(uint256 _voteId) public view onlyOwner returns (address) {
        require(!votes[_voteId].isActive, "Vote still ongoing");

        Vote storage currentVote = votes[_voteId];
        Candidate[] storage candidates = currentVote.candidates;

        uint256 maxVotes = 0;
        address winner;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winner = candidates[i].candidateAddress;
            }
        }

        return winner;
    }
}
