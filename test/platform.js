require('truffle-test-utils').init();
var Platform = artifacts.require('Platform');
const truffleAssert = require('truffle-assertions');
//let accounts = await web3.eth.getAccounts();
contract('Platform', accounts => {

    it("should correctly add a farmers to plattform", async () => {
        let randomNonOwner = accounts[1];
        
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
        let instance = await Platform.deployed();
        instance.modifyFarmer(0, "changedName", "changedDescription", "0000");
        

    });
});
