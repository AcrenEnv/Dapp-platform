pragma solidity >=0.4.21 <0.7.0;
import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./NameRegistry.sol";
//SPDX-License-Identifier: MIT

contract Campaign is Ownable {
    string public description;
    uint[2] public duration;
    enum state {approval_needed, open, closed , full, canceled}
    mapping(uint16 => Donation) donations;
    uint[2] public limit; // [0] minimum, [1] maximum
    uint public amount;
    //EPM public epm;
    string public epm;
    NameRegistry public nameRegistry;
    uint campaingID;
    //Proof
    //[Prooftype?]

    constructor (uint _campaignID, string memory _description, uint _start, uint _end, uint _minimum, uint _maximum, string memory epmName) public {
        campaingID = _campaignID;
        description = _description;
        duration[0] = _start;
        duration[1] = _end;
        limit[0] = _minimum;
        limit[1] = _maximum;
        epm = epmName;
        //epm = EPM(nameRegistry.getContractDetails(epmName));
    }
    enum Paymentmethod {banktransfer, DAI, Ether}
    enum DonationState {donor_sent, donor_received, admin_received, admin_sent, farmer_received}
    struct Donation {
        string donor;
        string amount;
        Paymentmethod paymentmethod;
        DonationState donationState;
        //ID
    }

    function getCampaignData()
    public
    view
    returns(string memory _description, uint _start, uint _end, uint _minimum, uint _maximum, string memory epmName, uint _amount)
    {
        return (description, duration[0], duration[1], limit[0], limit[1], epm, amount);
    }





}

/*abstract*/ contract EPM is Ownable {
    uint[2] costs;
    uint duration;
    uint[2] acceptedTimeframe;

    function
    setCosts(uint _minimum, uint _maximum)
    public
    onlyOwner //onlyAdmin
    {
     costs[0] = _minimum;
     costs[1] = _maximum;
    }

    function
    setDuration(uint _duration)
    public onlyOwner //onlyAdmin
    {
        duration = _duration;
    }

    function
    setAcceptedTimeframe(uint _begin, uint _end)
    public
    onlyOwner // onlyAdmin
    {
        acceptedTimeframe[0] = _begin;
        acceptedTimeframe[1] = _end;

    }

    constructor (uint _minimumCosts, uint _maximumCosts, uint _duration, uint _begin, uint _end) public {
        costs[0] = _minimumCosts;
        costs[1] = _maximumCosts;
        duration = _duration;
        acceptedTimeframe[0] = _begin;
        acceptedTimeframe[1] = _end;   
    }

}

contract WildflowerMeadow is EPM (1,2,3,4,5) {


}
