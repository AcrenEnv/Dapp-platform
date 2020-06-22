const NameRegistry = artifacts.require("NameRegistry");

module.exports = function(deployer) {
    deployer.deploy(NameRegistry);
};
