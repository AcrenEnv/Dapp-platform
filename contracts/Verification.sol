pragma solidity >=0.4.21 <0.7.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
*@todo: Implement roles instead of ownaböe
*
 */

contract Verification is Ownable {

    enum VerifierStatus {blocked, inactive, active}

    struct Verifier { //@todo: verifier struct should be callable from different contract
        uint8 rating; // rating 0 - 100
        //uint256 stake;
        VerifierStatus status;
        bool instantiated;
        mapping(uint16 => bool) votings;
    }


    struct Voting{
        uint256 votingStart;
        uint256 votingEnd;
        uint8 quorum;
        //uint256 stake;
        uint8 yesVotes;
        uint8 totalVotes;
        //bool accepted;
        //VotingState state;
        uint reward;
        mapping(address => bool) yesVote; //rename

    }
    event VotingAdded(uint16 votingID);


    string public adminName;

    mapping(address => Verifier) public verifiers; //@todo: id or other pattern should be applied to retrieve all verifiers
    uint256 public numVerifiers;

    uint16 public votingsNum;
    mapping(uint16 => Voting) public votings;

    modifier inVotingPeriod(uint16 _votingID) {
        require(block.timestamp >= votings[_votingID].votingStart, "Voting hasn't started yet");
        require(block.timestamp <= votings[_votingID].votingEnd, "Voting has ended");
        _;
    }

    modifier afterVotingPeriod(uint16 _votingID){
        require(block.timestamp > votings[_votingID].votingEnd, "Voting hasn't ended yet");
        _;
    }

    modifier onlyActiveVerifier(){
        require(verifiers[msg.sender].status == VerifierStatus.active, "You are not an active verifier!");
        _;
    }

    constructor (string memory _adminName, address[] memory _verifiers) public {
        adminName = _adminName;
        numVerifiers = _verifiers.length;

        for (uint i = 0; i < _verifiers.length; i++){
            verifiers[_verifiers[i]].rating = 100;
            verifiers[_verifiers[i]].status = VerifierStatus.active;
            verifiers[_verifiers[i]].instantiated = true;
        }
    }

    function addVoting(uint256 _votingStart, uint256 _votingEnd, uint8 _quorum)
        public
        onlyOwner //@todo: change to Donation Smart-Contract
        payable
        {
            require(_quorum>0 && _quorum<numVerifiers, "quorum set too low or high");
            require(_quorum%2 == 0, "Only odd quorum allowed");
            votingsNum++;
            uint16 votingID = votingsNum;
            votings[votingID] = Voting(_votingStart, _votingEnd, _quorum, 0, 0, msg.value);
            votings[votingID].reward = msg.value;
            emit VotingAdded(votingID);
        }

    function castVote(uint16 _votingID, bool _yesVote)
        public
        onlyActiveVerifier()
        inVotingPeriod(_votingID)
        {
            require(!verifiers[msg.sender].votings[_votingID], "Already voted");
            verifiers[msg.sender].votings[_votingID] = true;
            votings[_votingID].yesVote[msg.sender] = _yesVote;
            if(_yesVote) {votings[_votingID].yesVotes += 1;}
            votings[_votingID].totalVotes += 1;
        }

    function readVotingResults(uint16 _votingID)
        public
        view
        afterVotingPeriod(_votingID)
        returns(bool)
        {
            Voting storage voting = votings[_votingID];

            if((voting.totalVotes-voting.yesVotes) < voting.yesVotes){
                return true; // voting accepted
            } else {
                return false; // voting rejected
            }
        }

    function readVotingStatus(uint16 _votingID)
        public
        view
        returns(bytes32)
        {
            if(votings[_votingID].votingStart == 0) {return "invalid votingID";}

            if (block.timestamp < votings[_votingID].votingStart){
                return "not started yet";
            } else
            if(block.timestamp >= votings[_votingID].votingStart && block.timestamp <= votings[_votingID].votingEnd){
                return "started";
            } else {
                return "ended";
            }

        }
        


    function modifyVerifier(address _id, uint8 _rating, VerifierStatus _status)
        public
        onlyOwner
        {
            if(!(verifiers[_id].instantiated) && _status == VerifierStatus.active){numVerifiers += 1; verifiers[_id].instantiated = true;}
            verifiers[_id].rating = _rating;
            //verifiers[_id].stake = _stake;
            verifiers[_id].status = _status;

        }

    function readVerifierStatus(address _verifier)
        public
        view
        returns(bytes32) //aktualisieren..
        {
            if (verifiers[_verifier].status == VerifierStatus.blocked) {
                return "blocked";
            } else if (verifiers[_verifier].status == VerifierStatus.active){
                    return "active";
                } else {
                        return "inactive";
                }
        }

    function getVerifierVotingSpecified(address _verifier, uint16 _votingID)
        public
        view
        returns (uint8, VerifierStatus, bool, bool)
        {
            return(
                verifiers[_verifier].rating,
                verifiers[_verifier].status,
                verifiers[_verifier].instantiated,
                verifiers[_verifier].votings[_votingID]
                );

        }

    function deleteContract()
        public
        onlyOwner
        {
            selfdestruct(msg.sender);
        }
   
}
