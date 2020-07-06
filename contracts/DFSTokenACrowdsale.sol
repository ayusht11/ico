pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/crowdsale/RefundableCrowdsale.sol";
import "zeppelin-solidity/contracts/crowdsale/CappedCrowdsale.sol";
import "./DFSTokenA.sol";
import "./MilestoneStratergy.sol";

/**
 * @title DFSTokenACrowdsale
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this crowdsale we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundableCrowdsale - set a min goal to be reached and returns funds if it's not met
 */
contract DFSTokenACrowdsale is MilestoneStratergy, CappedCrowdsale, RefundableCrowdsale {

  function OrmCoCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _initialRate, uint256 _goal,
     uint256 _initialCap, address _wallet, uint[24] _milestones)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    CappedCrowdsale(_initialCap)
    MilestoneStratergy(_milestones)
    Crowdsale(_startTime, _endTime, _initialRate, _wallet)
  { 
    // Sum of all the milestone based tokenCaps 
    uint totalCap;

    for(uint i; i < 8; i++) {
      totalCap += _milestones[(i * 3) + 2];
    }

    //As goal needs to be met for a successful crowdsale
    //the value needs to less or equal than a cap which is limit for accepted funds
    require(_goal <= totalCap);
  }

  function createTokenContract() internal returns (MintableToken) {
    return new DFSTokenA();
  }

  // Override setMilestone of MilestoneStratergy
  function setMilestone() internal onlyNextMilestone {
    rate = currentMilestone.price;

    uint tokensLeftFromLastMilestoneCap = previousMilestone - totalSupply;
    cap = currentMilestone.tokenCap + tokensLeftFromLastMilestoneCap;
  }

  // Override buyTokens of Crowdsale
  function buyTokens(address _beneficiary) public payable {
    setMilestone();

    super.buyTokens(_beneficiary);
  }

}
