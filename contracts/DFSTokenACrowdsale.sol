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
 * MilestoneStratergy - sets various milestone parameters like weiCap and price for the milestone
 */
contract DFSTokenACrowdsale is MilestoneStratergy, CappedCrowdsale, RefundableCrowdsale {

  function DFSTokenACrowdsale(uint _startTime, uint _endTime, uint _initialRate, uint _goal,
    uint _initialCap, address _wallet, uint[24] _milestones)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    CappedCrowdsale(_initialCap)
    MilestoneStratergy(_milestones)
    Crowdsale(_startTime, _endTime, _initialRate, _wallet)
  { 
    // Sum of all the milestone based weiCaps
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

    uint weiLeftFromLastMilestoneCap = previousMilestone.weiCap - weiRaised;
    cap = currentMilestone.weiCap + weiLeftFromLastMilestoneCap;
  }

  // Override buyTokens of Crowdsale
  function buyTokens(address _beneficiary) public payable {
    setMilestone();

    super.buyTokens(_beneficiary);
  }

}
