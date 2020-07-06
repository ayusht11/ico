/**
 * This smart contract code is inspired from TokenMarket Ltd. For more information see https://tokenmarket.net
 */
pragma solidity ^0.4.6;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/// @dev Time milestone based pricing with special support for pre-ico deals.
contract MilestoneStratergy is Ownable {

  using SafeMath for uint;

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

      //how many wei can be raised     between two milestones
      uint weiCap;
  }

  // Store milestones in a fixed array, so that it can be seen in a blockchain explorer
  Milestone[8] public milestones;

  Milestone previousMilestone;
  Milestone currentMilestone;

  modifier onlyNextMilestone {
    currentMilestone = getCurrentMilestone();
    
    require((currentMilestone.index - previousMilestone.index) == 1);
    _;
  }

  /// @dev Contruction, creating a list of milestones
  /// @param _milestones uint[] milestones Pairs of (time, price, weiCap)
  function MilestoneStratergy(uint[24] _milestones) {
// uint is initialized by compiler with 0
    uint lastTimestamp;

    // uint is initialized by compiler with 0
    for(uint i; i < 8; ++i) {
      // No invalid steps
      if((lastTimestamp != 0) && ( _milestones[i * 3] <= lastTimestamp)) revert();
      // weiCap must be greater that or equal to 0
      if(_milestones[(i * 3) + 2] < 0) revert();

      milestones[i].index = i;
      milestones[i].time = _milestones[i * 3];
      milestones[i].price = _milestones[(i * 3) + 1];
      milestones[i].weiCap = _milestones[(i * 3) + 2];

      lastTimestamp = milestones[i].time;
    }

    // Last milestone price must be zero, terminating the crowdale
    if(milestones[7].price != 0 || milestones[7].weiCap != 0) revert();

    //set initialMilestone
    previousMilestone = milestones[0];
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

  /// @dev Get the current weiCap.
  /// @return The current weiCap or 0 if we are outside milestone period
  function getCurrentWeiCap() public constant returns (uint result) {
    return getCurrentMilestone().weiCap;
  }

  function () payable {
    revert(); // No money on this contract
  }

  // Override it and add logic
  function setMilestone() internal onlyNextMilestone {}

}
