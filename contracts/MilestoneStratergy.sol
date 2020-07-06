/**
 * This smart contract code is inspired from TokenMarket Ltd. For more information see https://tokenmarket.net
 */
pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


/// @dev Time milestone based pricing with special support for pre-ico deals.
contract MilestoneStratergy is Ownable {
    using SafeMath for uint;

    uint public constant MAX_MILESTONE = 10;

    // How many active milestones we have
    uint public milestoneCount;

    uint currentMaxCap;

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
    Milestone[10] public milestones;

    Milestone previousMilestone;
    Milestone currentMilestone;
    
    modifier onlyAfterFirstMilestone {
        require(now > milestones[0].time);
        _;
    }

    /// @dev Contruction, creating a list of milestones
    /// @param _milestones uint[] milestones Pairs of (time, price, weiCap)
    function MilestoneStratergy(uint[] _milestones) {
        // Need to have tuples, length check
        if ((_milestones.length%3 == 1) || (_milestones.length >= MAX_MILESTONE*3)) revert();

        milestoneCount = _milestones.length / 3;

        // uint is initialized by compiler with 0
        uint lastTimestamp;

        // uint is initialized by compiler with 0
        for (uint i; i < milestoneCount; ++i) {
            // No invalid steps
            if ((lastTimestamp != 0) && ( _milestones[i*3] <= lastTimestamp)) revert();
            // weiCap must be greater that or equal to 0
            if (_milestones[(i*3) + 2] < 0) revert();

            milestones[i].index = i;
            milestones[i].time = _milestones[i*3];
            milestones[i].price = _milestones[(i*3) + 1];
            milestones[i].weiCap = _milestones[(i*3) + 2];

            lastTimestamp = milestones[i].time;
        }

        // Last milestone price and weiCap must be zero, terminating the crowdale
        assert(milestones[milestoneCount-1].price == 0);
        assert(milestones[milestoneCount-1].weiCap == 0);

        //set initialMilestone
        previousMilestone = milestones[0];
    }

    // Override it and add logic
    function setMilestone() internal {}

    /// @dev Get the current price.
    /// @return The current price or 0 if we are outside milestone period
    function getCurrentPrice() public constant returns (uint result) {
        return getCurrentMilestone().price;
    }

    /// @dev Get the current weiCap.
    /// @return The current weiCap or 0 if we are outside milestone period
    function getCurrentWeiCap() public returns (uint result) {
       return getCurrentMilestone().weiCap;
    }

    function isNewMilestone() internal returns (bool) {
        currentMilestone = getCurrentMilestone();
        
        if (currentMilestone.index > previousMilestone.index) {
            previousMilestone = currentMilestone;
            return true;
        }
        else return false;
    }

    /// @dev Get the current milestone or bail out if we are not in the milestone periods.
    /// @return {[type]} [description]
    function getCurrentMilestone()
        internal
        onlyAfterFirstMilestone
        returns (Milestone)
    {
        currentMaxCap = 0;
        for (uint8 i; i < milestoneCount; i++) {
            if (now < milestones[i].time) return milestones[i-1];
            currentMaxCap = currentMaxCap.add(milestones[i].weiCap);
        }
    }
}
