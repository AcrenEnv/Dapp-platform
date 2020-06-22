var Platform = artifacts.require('Platform');
contract('Platform', function(accounts) {




    it("should correctly add a farmer to plattform", async () => {
        let instance = await Platform.deployed();
        farmerID = await instance.addFarmer("TestFarmer", "TestDescription", "11111100000");
        const farmerReturn = await instance.getFarmer(0); //todo: add event-listener
        const unverified = 0;
         
        assert.equal(
            farmerReturn[0] === "TestFarmer"
            && farmerReturn[1] === "TestDescription"
            &&  farmerReturn[2] === "11111100000"
            &&  farmerReturn[3] == unverified
            && farmerReturn[4] == null, true, "Farmer was not successfully added");

        //@todo: testing with non-owner account
    });
  

});
