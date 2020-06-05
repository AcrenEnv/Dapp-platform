pragma solidity >=0.4.21 <0.7.0;
import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
//SPDX-License-Identifier: MIT

contract Donation is Ownable {
    enum FarmerState {unverfied, verified, restricted, blocked}

    //enum paymentState {}
    //address[] campaigns;
    mapping(uint16 => Farmer) public farmers;
    uint16 numFarmers;
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


    struct Farmer {
        string name;
        string description; // ipfs
        string bankAccount;
        FarmerState state;
    }

    function deleteContract()
        public
        onlyOwner
        {
            selfdestruct(msg.sender);
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
