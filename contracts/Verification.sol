pragma solidity >=0.4.21 <0.7.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
*@todo: Implement roles instead of ownaböe
*
 */

contract Verification is Ownable {
    enum VerifierStatus {inactive, blocked, active}
    enum VotingState {added, started, ended}

    struct Verifier { //@todo: verifier struct should be callable from different contract
        uint8 rating; // rating 0 - 100
        uint256 stake;
        VerifierStatus status;
        bool instantiated;
        mapping(uint16 => bool) votings;
    }


    struct Voting{
        uint256 votingStart;
        uint256 votingEnd;
        uint8 minimumVotes;
        //uint256 stake;
        uint8 yesVotes; //todo: should be encrypted
        uint8 totalVotes;
        bool accepted;
        VotingState state;
        uint reward;
        mapping(address => bool) yesVote;

    }

    uint16 votingsNum;
    mapping(uint16 => Voting) votings;

    modifier inVotingPeriod(uint16 _votingID) {
        require(block.timestamp >= votings[_votingID].votingStart, "Voting hasn't started yet");
        require(block.timestamp <= votings[_votingID].votingEnd, "Voting has ended");
        _;
    }
    modifier onlyActiveVerifier(){
        require(verifiers[msg.sender].status == VerifierStatus.active, "You are not an active verifier!");
        _;
    }

    function addVoting(uint256 _votingStart, uint256 _votingEnd, uint8 _minimumVotes)
        public
        onlyOwner //@todo: change to Donation Smart-Contract
        payable
        returns (uint16 votingID)
        {
            votingID = votingsNum++;
            votings[votingID] = Voting(_votingStart, _votingEnd, _minimumVotes, 0, 0,false, VotingState.added, msg.value);
            votings[votingID].reward = msg.value;
        }

    function castVote(uint16 _votingID, bool _yesVote)
        public
        onlyActiveVerifier()
        inVotingPeriod(_votingID)
        {
            require(verifiers[msg.sender].votings[_votingID], "Already voted");
            votings[_votingID].yesVote[msg.sender] = _yesVote;
            if(_yesVote) {votings[_votingID].yesVotes += 1;}
            votings[_votingID].totalVotes += 1;
        }


    string public adminName;
    mapping(address => Verifier) public verifiers; //@todo: id or other pattern should be applied to retrieve all verifiers
    uint256 public numVerifiers;



    constructor (string memory _adminName, address[] memory _verifiers) public {
        adminName = _adminName;
        numVerifiers = _verifiers.length;

        for (uint i = 0; i < _verifiers.length; i++){
            verifiers[_verifiers[i]].rating = 100;
            verifiers[_verifiers[i]].status = VerifierStatus.active;
            verifiers[_verifiers[i]].instantiated = true;
        }
    }

    function modifyVerifier(address _id, uint8 _rating, uint256 _stake, VerifierStatus _status)
        public
        onlyOwner
        {
            if(!(verifiers[_id].instantiated)){numVerifiers += 1; verifiers[_id].instantiated = true;}
            verifiers[_id].rating = _rating;
            verifiers[_id].stake = _stake;
            verifiers[_id].status = _status;

        }

    function readVerifierStatus(address _verifier)
        public
        view
        returns(VerifierStatus)
        {
            return(verifiers[_verifier].status);
        }

    /*
    pragma experimental ABIEncoderV2 needed for returning structs
    function getVerifier(address _id)
        public
        view
        returns(Verifier)
        {
            return verifiers[_id];
        }
    */


}