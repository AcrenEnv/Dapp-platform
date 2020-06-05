const ExpertReview = artifacts.require("ExpertReview");

module.exports = function(deployer) {
    deployer.deploy(ExpertReview, "name", ["0x0bd80f25b040CB966525dB889d4f7ABC797b8633", "0x47841B092F893af68e33b4149408535267935DA6", "0x8F6b108489A4deb8675243FF7B70416092e0ac56"]);

};
