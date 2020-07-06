const DFSTokenACrowdsale = artifacts.require("./DFSTokenACrowdsale.sol");

const _startTime = 1509017400;
const _endTime = 1509087400;
const _initialRate = 100;
const _goal = "10000000000000000000";
const _initialCap = "3000000000000000000";
const _wallet = "0xc22729e46412e535275b8cc2561520a1abb8ea1c";
const _milestones = [
  1509017400, 100, "3000000000000000000",
  1509027400, 0, "3000000000000000000",
  1509037400, 80, "3000000000000000000",
  1509047400, 70, "3000000000000000000",
  1509057400, 60, "3000000000000000000",
  1509067400, 50, "3000000000000000000",
  1509077400, 40, "3000000000000000000",
  1509087400, 0, 0
];

module.exports = function(deployer) {
  deployer.deploy(DFSTokenACrowdsale, _startTime, _endTime, _initialRate, _goal, _initialCap, _wallet,
    _milestones, { from: "0xecd0dbd7ac6e376945d3c3a02035e8a2448ecb06" });
};
