pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/token/MintableToken.sol";

/**
 * @title DFSTokenB
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract DFSTokenB is MintableToken {

  string public name = "DFS Token B";
  string public symbol = "DFSB";
  uint public decimals = 18;
  uint public creationTime;

  // 30% of tokens meant for Founding Team, Core Dev & Operating Teams, Advisory Team
  uint constant VESTED_RESERVE_TOKENS = 30000000;

  /**
   *
   * Fix for the ERC20 short address attack
   *
   * http://vessenes.com/the-erc20-short-address-attack-explained/
   */
  modifier onlyPayloadSize(uint size) {
    if(msg.data.length != size + 4) revert();
    _;
  }

  modifier afterThreeYears {
    require(now > creationTime + (3 * 365 * 24 * 60 * 60))
    _;
  }

  function DFSTokenB() {
    reationTime = now;
  }

  function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
    super.transfer(_to, _value);
  }

  function increaseApproval(address _spender, uint _addedValue)
    onlyPayloadSize(2 * 32) returns (bool success) {
    super.increaseApproval(_spender, _addedValue); 
  }

  function decreaseApproval(address _spender, uint _addedValue)
    onlyPayloadSize(2 * 32) returns (bool success) {
    super.decreaseApproval(_spender, _addedValue); 
  }

  function claimVestedReserve() onlyOwner afterThreeYears{
    balances[msg.sender] = VESTED_RESERVE_TOKENS;
  }
  
}
