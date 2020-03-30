pragma solidity >=0.4.21 <0.7.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
*@todo: Implement roles instead of ownaböe
*
 */

contract Verification is Ownable {
    enum Status {inactive, blocked, active}

    struct Verifier { //@todo: verifier strcut should be callable from differen contract
        uint8 rating; // rating 0 - 100
        uint256 stake;
        Status status;
        bool instantiated;
    }


    string public adminName;
    mapping(address => Verifier) public verifiers; //@todo: id or other pattern should be applied to retrieve all verifiers
    uint256 public numVerifiers;



    constructor (string memory _adminName, address[] memory _verifiers) public {
        adminName = _adminName;
        numVerifiers = _verifiers.length;

        for (uint i = 0; i < _verifiers.length; i++){
            verifiers[_verifiers[i]].rating = 100;
            verifiers[_verifiers[i]].status = Status.active;
            verifiers[_verifiers[i]].instantiated = true;
        }
    }

    function modifyVerifier(address _id, uint8 _rating, uint256 _stake, Status _status)
        public
        onlyOwner
        {
            if(!(verifiers[_id].instantiated)){numVerifiers += 1; verifiers[_id].instantiated = true;}
            verifiers[_id].rating = _rating;
            verifiers[_id].stake = _stake;
            verifiers[_id].status = _status;

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