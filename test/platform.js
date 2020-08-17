require('truffle-test-utils').init();
var Platform = artifacts.require('Platform');
//var NameRegistery = artifacts.require('NameRegistery')
const truffleAssert = require('truffle-assertions');
var WildflowerMeadow = artifacts.require('WildflowerMeadow');
var NameRegistry = artifacts.require('NameRegistry');
var Campaign = artifacts.require('Campaign');

contract('Platform', accounts => {

    let randomNonOwner = accounts[1];
    let ts = Math. round((new Date()). getTime() / 1000);

    const capaignApprovalNeeded = 0;
    const campaignOpen = 1;
    const campaignClosed = 2;
    const campaignFull = 3;
    const campaignCanceled = 4;
 

    it("should correctly add and get a farmers to plattform", async () => {
        let instance = await Platform.deployed();
        let result0 = await instance.addFarmer("TestFarmer", "TestDescription", "11111100000");
        let result1 = await instance.addFarmer("TestFarmer2", "TestDescription2", "11111100000");
        const farmerReturn = await instance.getFarmer(0);
        const unverified = 0;
         
        assert.equal(
            farmerReturn[0] === "TestFarmer"
            && farmerReturn[1] === "TestDescription"
            &&  farmerReturn[2] === "11111100000"
            &&  farmerReturn[3] == unverified
            && farmerReturn[4] == 0
            && farmerReturn[5] == null, true, "Farmer was not successfully added");

        truffleAssert.eventEmitted(result0, 'FarmerAdded', (ev) => { return ev.farmerID == 0; });
        truffleAssert.eventEmitted(result1, 'FarmerAdded', (ev) => { return ev.farmerID == 1; });
        await truffleAssert.reverts(instance.addFarmer("TestFarmer2", "TestDescription2", "11111100000", {from: randomNonOwner}));
    });

    it("should modify farmers correctly", async() =>{

        const verified = 1;

        let instance = await Platform.deployed();
        let result0 = await instance.modifyFarmer(0, "changedName", "changedDescription", "0000", verified);
        truffleAssert.eventEmitted(result0, 'FarmerModified', (ev) => {
             return (
                 ev.farmerID == 0
                 && ev.name === "changedName"
                 && ev.description === "changedDescription"
                 && ev.bankAccount === "0000"); 
            });
        await truffleAssert.reverts(instance.modifyFarmer(0, "changedName", "changedDescription", "0000", verified, {from: randomNonOwner}));

    });

    it("should change farmers state correctly", async() =>{
        const unverified = 0;
        const verified = 1;
        const restricted = 2;

        let instance = await Platform.deployed();
        const farmerReturn = await instance.getFarmer(0);

        assert.equal( farmerReturn[3] == verified, true, "Farmer´s initial state is wrong");

        let result0 = await instance.setFarmerState(0, restricted);
        
        truffleAssert.eventEmitted(result0, 'FarmerStateModified', (ev) => {
            return (
                ev.farmerID == 0
                && parseInt(ev.state) === 2// == restricted
             ); 
           });

        await truffleAssert.reverts(instance.setFarmerState(0, verified, {from: randomNonOwner}));


    });
    it("should create an EPM and campaign correctly", async() =>{
        
        let wildflowerInstance = await WildflowerMeadow.deployed();
        let nameRegistryInstance = await NameRegistry.deployed();
        await nameRegistryInstance.registerName("WildflowerMeadowEPM", wildflowerInstance.address);
        
        var instance = await Platform.deployed();
        let start = ts;
        let end = start + 120;
        let minimumDollar = 10;
        let maximumDollar = 1200;
        let epmName = "WildflowerMeadowEPM";
        let result0 = await instance.createCampaign(0, "First campaign Description", start, end, minimumDollar, maximumDollar, epmName);
        let result1 = await instance.createCampaign(0, "Second Description", start, end, minimumDollar, maximumDollar, epmName);
        let resultCampaignAddress1 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 1)
        let resultCampaignAddress2 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 2)

       
        truffleAssert.eventEmitted(result0, 'CampaignCreated', (ev) => {
                return (
                    ev.farmerID == 0
                    && ev.campaignID == 0
                    && ev.campaignAddress == resultCampaignAddress1
                 ); 
            
           });

        truffleAssert.eventEmitted(result1, 'CampaignCreated', (ev) => {
            return (
                ev.farmerID == 0
                && ev.campaignID == 1
                && ev.campaignAddress == resultCampaignAddress2
             ); 
           });
    
           await truffleAssert.reverts(instance.createCampaign(0, "First campaign Description", start, end, minimumDollar, maximumDollar, epmName, {from: randomNonOwner}));

    });

    it("should get all campaigns of a farmer", async() =>{
        var instance = await Platform.deployed();
        let farmerResult = await instance.getFarmer(0);
        assert.equal(farmerResult['4'] == 2, true, "Farmer has more or less than two campaigns!");
        let resultCampaignAddress1 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 1);
        let resultCampaignAddress2 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 2);
        let campaignInstance = await Campaign.at(resultCampaignAddress1);
        let campaignInstance2 = await Campaign.at(resultCampaignAddress2);

        let campaignData = await campaignInstance.getCampaignData();
        let campaignData2 = await campaignInstance2.getCampaignData();

        assert.equal(
            
            campaignData['_description'] == 'First campaign Description'
            && campaignData['_start'] == ts
            && campaignData['_end'] == (ts+120)
            && campaignData['_minimum'] == 10
            && campaignData['_maximum'] == 1200
            && campaignData['epmName'] == 'WildflowerMeadowEPM'
            && campaignData['_amount'] == 0
            && campaignData['_campaignID'] == 0
        
            , true, "First campaign is wrong (unexpected data)");

        assert.equal(
                
                campaignData2['_description'] == 'Second Description'
                && campaignData2['_start'] == ts
                && campaignData2['_end'] == (ts+120)
                && campaignData2['_minimum'] == 10
                && campaignData2['_maximum'] == 1200
                && campaignData2['epmName'] == 'WildflowerMeadowEPM'
                && campaignData2['_amount'] == 0
                && campaignData2['_campaignID'] == 1
            
                , true, "Second campaign is wrong (unexpected data)");

    }); 

    it ("Should correctly accept a donation", async() => {
        var instance = await Platform.deployed();
        let resultCampaignAddress1 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 1);
        let resultCampaignAddress2 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 2);
        let campaignInstance = await Campaign.at(resultCampaignAddress1);
        let campaignInstance2 = await Campaign.at(resultCampaignAddress2);
        let campaignData = await campaignInstance.getCampaignData();


        assert.equal(

            campaignData['_description'] == 'First campaign Description'
            && campaignData['_start'] == ts
            && campaignData['_end'] == (ts+120)
            && campaignData['_minimum'] == 10
            && campaignData['_maximum'] == 1200
            && campaignData['epmName'] == 'WildflowerMeadowEPM'
            && campaignData['_amount'] == 0
            && campaignData['_campaignID'] == 0
            && campaignData['_state'] == 0

        
            , true, "First campaign is wrong (unexpected data)");

        await truffleAssert.reverts(campaignInstance.receiveDonation(100, 0));

        await campaignInstance.changeCampaignState(campaignOpen);
        await campaignInstance2.changeCampaignState(campaignOpen);
    
        let campaignSendDonation = await campaignInstance.receiveDonation(100, 0);

    truffleAssert.eventEmitted(campaignSendDonation, 'DonationSent', (ev) => {

            return (
                ev.donationID == 1,
                ev.paymentMethod == 0
             ); 
        });

    truffleAssert.eventEmitted(campaignSendDonation, 'CampaignUpdated', (ev) => {
        
            return (
                ev.campaingID == 0
             ); 
        });
    
    let campaignDataUpdated = await campaignInstance.getCampaignData();

    assert.equal(

        campaignDataUpdated['_description'] == 'First campaign Description'
        && campaignDataUpdated['_start'] == ts
        && campaignDataUpdated['_end'] == (ts+120)
        && campaignDataUpdated['_minimum'] == 10
        && campaignDataUpdated['_maximum'] == 1200
        && campaignDataUpdated['epmName'] == 'WildflowerMeadowEPM'
        && campaignDataUpdated['_amount'] == 100
        && campaignDataUpdated['_campaignID'] == 0
        && campaignDataUpdated['_state'] == 1


    
        , true, "Amount not updated or other data changed");
    
    let campaignSendDonation2 = await campaignInstance2.receiveDonation(150, 1);

    truffleAssert.eventEmitted(campaignSendDonation2, 'DonationSent', (ev) => {
    
        return (
            ev.donationID == 1,
            ev.paymentMethod == 1
             ); 
        });
    
    truffleAssert.eventEmitted(campaignSendDonation2, 'CampaignUpdated', (ev) => {
        
        return (
            ev.campaingID == 1
            ); 
        });
    let campaignDataUpdated2 = await campaignInstance2.getCampaignData();

    assert.equal(
                
        campaignDataUpdated2['_description'] == 'Second Description'
        && campaignDataUpdated2['_start'] == ts
        && campaignDataUpdated2['_end'] == (ts+120)
        && campaignDataUpdated2['_minimum'] == 10
        && campaignDataUpdated2['_maximum'] == 1200
        && campaignDataUpdated2['epmName'] == 'WildflowerMeadowEPM'
        && campaignDataUpdated2['_amount'] == 150
        && campaignDataUpdated2['_campaignID'] == 1
        && campaignDataUpdated2['_state'] == 1

    
        , true, "Second campaign is wrong (unexpected data)");
       
    });

    it("Should correctly obtain donation data and change the state of a donation", async() => {
        var instance = await Platform.deployed();
        let resultCampaignAddress1 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 1);
        let campaignInstance = await Campaign.at(resultCampaignAddress1);
        let donationData = await campaignInstance.getDonationData(0);
        assert.equal(
                
            donationData['_donor'] == 'anonymous'
            && donationData['_amount'] == 100
            && donationData['_paymentmethod'] == 0
            && donationData['_donationstate'] == 0
            && donationData['_id'] == 0
           
        
            , true, "First Donation data not correct");

        await campaignInstance.receiveDonation(123, 1);
        let donationData2 = await campaignInstance.getDonationData(1);
        assert.equal(
                
            donationData2['_donor'] == 'anonymous'
            && donationData2['_amount'] == 123
            && donationData2['_paymentmethod'] == 1
            && donationData2['_donationstate'] == 0
            && donationData2['_id'] == 1
           
        
            , true, "Second Donation data not correct");

        await campaignInstance.changeDonationState(1,2);
        donationData2 = await campaignInstance.getDonationData(1);
        assert.equal(      
            donationData2['_donor'] == 'anonymous'
            && donationData2['_amount'] == 123
            && donationData2['_paymentmethod'] == 1
            && donationData2['_donationstate'] == 2
            && donationData2['_id'] == 1
            , true, "after state change: Second Donation data not correct after");
        
    });

    it("Should correctly change the state of a campaign", async() => {
        
        
        var instance = await Platform.deployed();
        let resultCampaignAddress1 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 1);
        let campaignInstance = await Campaign.at(resultCampaignAddress1);
        let campaignData = await campaignInstance.getCampaignData();

        //Check if campaign is open
        assert.equal(campaignData["_state"] == campaignOpen, true, "Campaign state is equal to  'open'");

        //Sending transaction to set campaign to "full"
        let amountToFull = campaignData["_maximum"]-campaignData["_amount"];
        await campaignInstance.receiveDonation(amountToFull, 1);
        campaignData = await campaignInstance.getCampaignData();
        assert.equal(campaignData["_state"] == campaignFull, true, "Campaign state is equal to  'full'");
        await truffleAssert.reverts(campaignInstance.receiveDonation(1, 1));


        //Changing state to closed and sending transaction to closed campaign
        await campaignInstance.changeCampaignState(campaignClosed);
        campaignData = await campaignInstance.getCampaignData();
        assert.equal(campaignData["_state"] == campaignClosed, true, "Campaign state is after closed not equal to  'closed'");
        await truffleAssert.reverts(campaignInstance.receiveDonation(123, 1));

        //changing state to canceled and sending transaction to canceled campaign

        await campaignInstance.changeCampaignState(campaignCanceled);
        campaignData = await campaignInstance.getCampaignData();
        assert.equal(campaignData["_state"] == campaignCanceled, true, "Campaign state is after canceled not equal to  'canceled'");
        await truffleAssert.reverts(campaignInstance.receiveDonation(123, 1));

    });
  

});
