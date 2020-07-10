require('truffle-test-utils').init();
var Platform = artifacts.require('Platform');
//var NameRegistery = artifacts.require('NameRegistery')
const truffleAssert = require('truffle-assertions');
var WildflowerMeadow = artifacts.require('WildflowerMeadow');
var NameRegistry = artifacts.require('NameRegistry');

contract('Platform', accounts => {

    let randomNonOwner = accounts[1];    

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
            && farmerReturn[4] == null, true, "Farmer was not successfully added");

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
        let start = 100;
        let end = start + 120;
        let minimumDollar = 10;
        let maximumDollar = 1200;
        let epmName = "WildflowerMeadowEPM";
        let result0 = await instance.createCampaign(0, "First campaign Description", start, end, minimumDollar, maximumDollar, epmName);
        let result1 = await instance.createCampaign(0, "Second Description", start, end, minimumDollar, maximumDollar, epmName);
        let resultCampaignAddress1 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 1)
        let resultCampaignAddress2 = await instance.getCampainAddressByFarmerIdAndCampaignId(0, 2)

        var instance = await Platform.deployed();
        truffleAssert.eventEmitted(result0, 'CampaignCreated', (ev) => {
                return (
                    ev.farmerID == 0
                    && ev.campaignID == 1
                    && ev.campaignAddress == resultCampaignAddress1
                 ); 
            
           });

        truffleAssert.eventEmitted(result1, 'CampaignCreated', (ev) => {
            return (
                ev.farmerID == 0
                && ev.campaignID == 2
                && ev.campaignAddress == resultCampaignAddress2
             ); 
           });
    
           await truffleAssert.reverts(instance.createCampaign(0, "First campaign Description", start, end, minimumDollar, maximumDollar, epmName, {from: randomNonOwner}));

    });


});
