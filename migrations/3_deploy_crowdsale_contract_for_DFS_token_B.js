const DFSTokenBCrowdsale = artifacts.require("./DFSTokenBCrowdsale.sol");

const _startTime = 1519017400;
const _endTime = 1519087400;
const _initialRate = 100;
const _goal = "10000000000000000000";
const _initialCap = "3000000000000000000";
const _wallet = "0xc22729e46412e535275b8cc2561520a1abb8ea1c";
const _milestones = [
  1519017400, 100, "3000000000000000000",//presale start time, rate and weiCap
  1519027400, 0, "3000000000000000000",  //presale end time, rate (must be to be 0) and weiCap
  1519037400, 80, "3000000000000000000", //milestone 1 (sale start)
  1519047400, 70, "3000000000000000000", //milestone 2
  1519057400, 60, "3000000000000000000", //milestone 3
  1519067400, 50, "3000000000000000000", //milestone 4
  1519077400, 40, "3000000000000000000", //milestone 5
  1519087400, 0, 0                       //sale end- price and weiCap must be 0 
];

module.exports = (deployer) => {
  deployer.deploy(DFSTokenBCrowdsale, _startTime, _endTime, _initialRate, _goal, _initialCap, _wallet,
    _milestones, { from: "0xf7bd6f262b83da35d74137bde6a317b119275b32" });
};
