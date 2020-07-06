/**
 * This smart contract code is inspired from TokenMarket Ltd. For more information see https://tokenmarket.net
 */
pragma solidity ^0.4.6;

import "./Crowdsale.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/// @dev Time milestone based pricing with special support for pre-ico deals.
contract MilestoneStratergy is Ownable {

  using SafeMathLib for uint;

  uint public constant MAX_MILESTONE = 8;

  /**
  * Define pricing schedule using milestones.
  */
  struct Milestone {

      // UNIX timestamp when this milestone kicks in
      uint time;

      // Milestone index
      uint index;

      // How many tokens per ether you will get after this milestone has been passed
      uint price;

      //how many tokens are available between two milestones
      uint tokenCap;
  }

  // Store milestones in a fixed array, so that it can be seen in a blockchain explorer
  Milestone[8] public milestones;

  Milestone previousMilestone;

  modifier onlyNextMilestone {
    Milestone currentMilestone = getCurrentMilestone();
    
    require(currentMilestone != previousMilestone && (currentMilestone.index - previousMilestone.index) == 1);
    _;
  }

  /// @dev Contruction, creating a list of milestones
  /// @param _milestones uint[] milestones Pairs of (time, price, tokenCap)
  function MilestoneStratergy(uint[24] _milestones) {
// uint is initialized by compiler with 0
    uint lastTimestamp;

    // uint is initialized by compiler with 0
    for(uint i; i < 8; i++) {
      // No invalid steps
      if((lastTimestamp != 0) && (milestones[i].time <= lastTimestamp)) revert();
      // tokenCap must be greater that or equal to 0
      if(_milestones[(i * 3) + 2] < 0) revert();

      milestones[i].index = i;
      milestones[i].time = _milestones[i * 3];
      milestones[i].price = _milestones[(i * 3) + 1];
      milestones[i].tokenCap = _milestones[(i * 3) + 2];

      lastTimestamp = milestones[i].time;
    }

    // Last milestone price must be zero, terminating the crowdale
    if(milestones[7].price != 0 || milestones[7].tokenCap != 0) revert();

    //set initialMilestone
    previousMilestone = getCurrentMilestone();
  }

  /// @dev Iterate through milestones. You reach end of milestones when price = 0
  /// @return tuple (time, price)
  function getMilestone(uint n) public constant returns (uint, uint) {
    return (milestones[n].time, milestones[n].price);
  }

  function getFirstMilestone() private constant returns (Milestone) {
    return milestones[0];
  }

  function getLastMilestone() private constant returns (Milestone) {
    return milestones[7];
  }

  function getPricingStartsAt() public constant returns (uint) {
    return getFirstMilestone().time;
  }

  function getPricingEndsAt() public constant returns (uint) {
    return getLastMilestone().time;
  }

  function isSane(address _crowdsale) public constant returns(bool) {
    Crowdsale crowdsale = Crowdsale(_crowdsale);
    return crowdsale.startsAt() == getPricingStartsAt() && crowdsale.endsAt() == getPricingEndsAt();
  }

  /// @dev Get the current milestone or bail out if we are not in the milestone periods.
  /// @return {[type]} [description]
  function getCurrentMilestone() internal constant returns (Milestone) {
    uint i;

    for(i = 0; i < milestones.length; i++) {
      if(now < milestones[i].time) {
        return milestones[i - 1];
      }
    }
  }

  /// @dev Get the current price.
  /// @return The current price or 0 if we are outside milestone period
  function getCurrentPrice() public constant returns (uint result) {
    return getCurrentMilestone().price;
  }

  /// @dev Get the current tokenCap.
  /// @return The current tokenCap or 0 if we are outside milestone period
  function getCurrentTokenCap() public constant returns (uint result) {
    return getCurrentMilestone().tokenCap;
  }

  function () payable {
    throw; // No money on this contract
  }

  // Override it and add logic
  function setMilestone() internal onlyNewMilestone {}

}
