const _initial_nameRegistry = require('../migrations/3_initial_nameRegistry');
const truffleAssertions = require('truffle-assertions');

require('truffle-test-utils').init();
var NameRegistry = artifacts.require('NameRegistry');
var Platform = artifacts.require('Platform');

contract('NameRegistry', accounts => {
     let randomNonOwner = accounts[1];  
    it('should correctly register and fetch a name ', async() =>{
        let instance = await NameRegistry.deployed();
        const name = "Platform";
        const platformAddress = Platform.address;

        instance.registerName(name, platformAddress);
        returnPlatformAddress = await instance.getContractDetails("Platform");

        assert.equal(platformAddress == returnPlatformAddress, true, "Registered Platform address is not equal");
        //await truffleAssert.reverts(instance.registerName("name2", platformAddress, {from: randomNonOwner}));


    });

});

