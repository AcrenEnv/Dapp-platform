pragma solidity >=0.4.21 <0.7.0;
import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Campaign.sol";


//SPDX-License-Identifier: MIT

contract Platform is Ownable {
    enum FarmerState {unverfied, verified, restricted, blocked}

    //enum paymentState {}
    Campaign[] public campaigns; //@todo: standardize
    mapping(uint16 => Farmer) public farmers;
    uint16 numFarmers = 0;
    //EPM[..] public allowedEPMs
    //mapping(address=> Donor) public donors;
    //string public adminName;



    constructor (/*string memory _adminName*/) public {
        //adminName = _adminName;
    }

    function changeAdministrator (address _newOwner/*, string memory _adminName*/)
        public
        {
            transferOwnership(_newOwner);
            //adminName = _adminName;
        }

    function addFarmer(string memory name, string memory description, string memory bankAccount) public
    onlyOwner
    {
        farmers[numFarmers].name = name;
        farmers[numFarmers].description = description;
        farmers[numFarmers].bankAccount = bankAccount;
        farmers[numFarmers].state = FarmerState.unverfied;
        farmers[numFarmers].id = numFarmers;
        numFarmers++;
       
    }

    function setFarmerState(uint16 id, FarmerState state) public
    onlyOwner
    {
        farmers[id].state = state;
    }

    function modifyFarmer(uint16 id, string memory name, string memory description, string memory bankAccount) public
    onlyOwner
    {
        farmers[id].name = name;
        farmers[id].description = description;
        farmers[id].bankAccount = bankAccount;
    }

    function getFarmer(uint16 id)
    public
    view
    returns(string memory, string memory, string memory, FarmerState)
    {
        return(
        farmers[id].name,
        farmers[id].description,
        farmers[id].bankAccount,
        farmers[id].state
        );

    }



    struct Farmer {
        uint id;
        string name;
        string description; // ipfs
        string bankAccount;
        FarmerState state;
        EPM[] epms;
        Campaign[] campaigns;
    }

    function deleteContract()
        public
        onlyOwner
        {
            selfdestruct(msg.sender);
        }

    struct Contributer{
        uint256 amount;
        string contactData; // ipfs
        string bankAccount;
        address ethAddress;
    }

    function createCampaign(uint16 farmerID, string memory _description, int _start, int _end, int _minimum, int _maximum, string memory _epmName)
        public
        /*onlyActivatedFarmer*/
        /*onlyAllowedEPMs*/
        {
            Campaign campaign = new Campaign(_description, _start, _end, _minimum, _maximum, _epmName);
            campaigns.push(campaign);
            farmers[farmerID].campaigns.push(campaign);
        }

    function getCampaignCount()
        public
        view
        returns(uint256 campaignCount)
        {
            return(campaigns.length);
        }




    /*struct Donor {
        uint256 amount;
        string contactData; // ipfs
        string bankAccount;
        address ethAddress;
    }
    struct Donation  {
        uint256 amount;
        uint256 fee;


        //Campaign campaing;
    }
    struct PaymentMethod{

    }*/
/*

    contract Campaign {

        //all specific campaign data

    }
*/

}
