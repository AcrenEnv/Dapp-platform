pragma solidity >=0.4.21 <0.7.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
*@todo: Implement roles instead of ownable
*
 */

contract ExpertReview is Ownable {
    enum ExpertStatus {verified, restricted, blocked}
    enum EPMState {started, inactive, proposed}

    struct Expert {
        String name;
        ExpertStatus status;
        bool instantiated;
        mapping(uint16 => bool) votings;
    }


    struct Voting {
        uint256 votingStart;
        uint256 votingEnd;
        uint8 quorum;
        uint8 totalVotes;
        uint8 yesVotes;
        bool accepted;
        mapping(address => bool) yesVote;

    }

    struct EPMProposal {
       String title;
       String description;
       ProofType proofType;
       address author;
       EPMState state;
    }

    struct ProofType {
        String description;
        //EPM[] epms; @todo: Define EPM struct
        //uint256 stakingMinimum;
        String verificationSteps;
        String preCondition;
        String postCondition;
    }

    modifier inVotingPeriod(uint16 _votingID) {
        require(block.timestamp >= votings[_votingID].votingStart, "Voting hasn't started yet");
        require(block.timestamp <= votings[_votingID].votingEnd, "Voting has ended");
        _;
    }

    modifier afterVotingPeriod(uint16 _votingID){
        require(block.timestamp > votings[_votingID].votingEnd, "Voting hasn't ended yet");
        _;
    }

    modifier onlyActivatedExpert() {
        require(experts[msg.sender].status == ExpertStatus.activated, "You are not an activated expert!");
        _;
    }

    modifier onlyAuthor(uint16 _epm_proposalID) {
        require(epm_proposal[_epm_proposalID].author == msg.sender, "You are not the author of the EPM!");
        _;
    }

    modifier EPMProposalPlanned(uint16 _epm_proposalID) {
        require(votings[_epm_proposalID].votingStart > block.timestamp, "The EPM is not in the right state (proposed)!");
        _;
    }

    modifier EPMProposalStarted(uint16 _epm_proposalID) {
        require(block.timestamp >= votings[_epm_proposalID].votingStart, "Voting hasn't started yet");
        require(block.timestamp <= votings[_epm_proposalID].votingEnd, "Voting has ended");
    }

    modifier EPMProposalEnded(uint16 _epm_proposalID) {
        require(votings[_epm_proposalID].votingEnd < block.timestamp, "The EPM is not in the right state (ended)!");
        _;
    }

    event VotingAdded(uint16 votingID);
    event Voted(address voter, uint16 votingID, bool yesVote)

    string public adminName;

    mapping(address => Expert) public experts; 
    uint256 public numExperts;

    mapping(uint16 => Voting) votings;

    mapping(uint16 => EPMProposal) epm_proposals;
    uint16 public epm_proposalsNum;


    constructor (string memory _adminName, address[] memory _experts)
        public
        {
            _transferOwnership(msg.sender);
            adminName = _adminName;
            numExperts = _experts.length;

            for (uint i = 0; i < _experts.length; i++){
                verifiers[_experts[i]].rating = 100;
                verifiers[_experts[i]].status = ExpertStatus.active;
                verifiers[_experts[i]].instantiated = true;
        }
    }

    function changeAdministrator (adress _newOwner, string _adminName)
        public
        {
            transferOwnership(_newOwner);
            adminName = _adminName;
        }

    function modifyExpert(address _id, String _name, ExpertStatus _status)
        public
        onlyOwner
        {
            if(!(experts[_id].instantiated)){numExperts += 1; experts[_id].instantiated = true;}
            experts[_id].name = _name;
            experts[_id].status = _status;

        }


    function createEPMProposal(String _title, String _description, String _proof_description, String _verificationSteps, String _preCondition, String _postCondition)
        public
        onlyActivatedExpert
        returns (uint16 epm_proposalID)
        {
            epm_proposalID = epm_proposalNum++;
            proofType = ProofType(_proof_description, _verificationSteps, _preCondition, _postCondition);
            epm_proposals[epm_proposalID] = EPMProposal(_title, _description, proofType, msg.sender, EPMState.proposed);
            return epm_proposalID;
        }

    function modifyEPMProposal(uint16 _id, String _title, String _description, String _proof_description, String _verificationSteps, String _preCondition, String _postCondition)
        public
        onlyOwner onlyAuthor EPMProposalPlanned(_id)
        {
            proofType = ProofType(_proof_description, _verificationSteps, _preCondition, _postCondition);
            epm_proposals[_id].title = _title;
            epm_proposals[_id].description = _description;
            epm_proposals[_id].proofType = proofType;
        }

    function deleteEPMProposal(uint16 _id)
        public
        onlyOwner onlyAuthor EPMProposalPlanned(_id)
        {
            delete epm_proposals[_id];
        }

    function addVoting(uint16 _epm_proposalID, uint256 _votingStart, uint256 _votingEnd, uint8 _quorum)
        public
        onlyAuthor onlyActivatedExpert
        {
            require(_quorum>0 && _quorum<numVerifiers, "quorum set too low or high");
            require(_quorum%2 == 0, "Only odd quorum allowed");
            require(_quorum == 1, "Quorum has to be minimum 3");
            require(block.timestamp <= _votingStart, "Voting start time has to be in future");
            require(_votingStart < _votingEnd, "Voting end time has to be after start time");
            votings[_epm_proposalID] = Voting(_votingStart, _votingEnd, _quorum, 0, 0, false);
            emit VotingAdded(_epm_proposalID);
        }

    function castVote(uint16 _epm_proposalID, bool _yesVote)
        public
        onlyActivatedExpert
        EPMProposalStarted(_epm_proposalID)
        {
            require(experts[msg.sender].votings[_epm_proposalID], "Already voted");
            votings[_epm_proposalID].yesVote[msg.sender] = _yesVote;
            if(_yesVote) {votings[_epm_proposalID].yesVotes += 1;}
            votings[_epm_proposalID].totalVotes += 1;
            emit Voted(msg.sender, _epm_proposalID, _yesVote);
        }

    function readVotingResults(uint16 _epm_proposalID)
        public
        view
        EPMProposalEnded(_epm_proposalID)
        returns(bool)
        {
            if((votings[_epm_proposalID].totalVotes-votings[_epm_proposalID].yesVotes) < votings[_epm_proposalID].yesVotes){
                return true; // voting accepted
            } else {
                return false; // voting rejected
            }
        }


    function readExpertStatus(address _id)
        public
        view
        returns(ExpertStatus)
        {
            return(experts[_id].status);
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

    function readEPMProposal(uint16 _id)
        public
        view
        returns(String title, String description, ProofType proofType)
        {
            return(epm_proposals[_id].title, epm_proposals[_id].description, epm_proposals[_id].proofType);
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