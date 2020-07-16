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

    uint campaignCount = 0;

    event FarmerAdded(
        uint16 farmerID
    );
    event FarmerModified(
        uint16 farmerID,
        string name,
        string description,
        string bankAccount,
        FarmerState state

    );
    event FarmerStateModified(
        uint16 farmerID,
        FarmerState state
    );
    event CampaignCreated(
        uint16 farmerID,
        uint campaignID,
        address campaignAddress
    );


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
        emit FarmerAdded(numFarmers);
        numFarmers++;
    }

    function setFarmerState(uint16 id, FarmerState state) public
    onlyOwner
    {
        farmers[id].state = state;
        emit FarmerStateModified(id, state);
    }

    function modifyFarmer(uint16 id, string memory name, string memory description, string memory bankAccount, FarmerState state) public
    onlyOwner
    {
        farmers[id].name = name;
        farmers[id].description = description;
        farmers[id].bankAccount = bankAccount;
        farmers[id].state = state;
        emit FarmerModified(id, name, description, bankAccount, state);

    }

    function getFarmer(uint16 id)
    public
    view
    returns(string memory, string memory, string memory, FarmerState, uint)
    {
        return(
        farmers[id].name,
        farmers[id].description,
        farmers[id].bankAccount,
        farmers[id].state,
        farmers[id].campaignsCount
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
        uint campaignsCount;
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

    function createCampaign(
        uint16 farmerID, string memory _description, uint _start, uint _end, uint _minimum, uint _maximum, string memory _epmName
        )
        public
        /*onlyActivatedFarmer*/
        /*onlyAllowedEPMs*/
        onlyOwner
        {
            Campaign campaign = new Campaign(campaignCount, _description, _start, _end, _minimum, _maximum, _epmName);
            campaigns.push(campaign);
            farmers[farmerID].campaigns.push(campaign);
            farmers[farmerID].campaignsCount += 1;
            emit CampaignCreated(farmerID, campaignCount, address(campaign));
            campaignCount++;
        }

    function getCampainAddressByFarmerIdAndCampaignId(uint16 farmerID, uint16 campaignID)
    public
    view
    returns(address campaignAddress)
    {

        return address(farmers[farmerID].campaigns[campaignID-1]);
    }

    /*function getCampaignsByFarmerAndCampaignID(uint16 farmerID, uint16 campaignID)
    public
    view
    returns (string memory description/*, uint _start, uint _end, uint _minimum, uint _maximum, string memory epmName, uint amount){
        description = farmers[farmerID].campaigns[campaignID].getCampaignData();
        return description;
    }*/
    /*function getCampaignCount()
        public
        view
        returns(uint256 campaignCount)
        {
            return(campaignCount);
        }
*/



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
