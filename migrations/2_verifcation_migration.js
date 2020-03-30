const Verification = artifacts.require("Verification");

module.exports = function(deployer) {
  deployer.deploy(Verification, "name", ["0x6DA4fedaB122269DcaEdf7d09D84D01a09930986", "0x52Ab85871b5Fc7A2F1E64De4F0D643397bA7b8AE"]);
};
