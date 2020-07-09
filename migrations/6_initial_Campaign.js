const Campaign = artifacts.require("Campaign");
const WildflowerMeadow = artifacts.require("WildflowerMeadow");

module.exports = function(deployer) {
   //deployer.deploy(Campaign);
    deployer.deploy(WildflowerMeadow);
};
