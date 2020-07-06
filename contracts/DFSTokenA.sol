pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/token/MintableToken.sol";


/**
 * @title DFSTokenA
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract DFSTokenA is MintableToken {
    string public name = "DFS Token A";
    string public symbol = "DFS";
    uint public decimals = 18;
    uint public creationTime;
    
    // 29% of tokens meant for Reward Pool, Core Dev & Operating Teams, Advisory Team & ICO Bounties
    uint constant NON_VESTED_RESERVE_TOKENS = 116000000;
    // 6% of tokens meant for Founding Team
    uint constant VESTED_RESERVE_TOKENS = 24000000;

    /**
     *
     * Fix for the ERC20 short address attack
     *
     * http://vessenes.com/the-erc20-short-address-attack-explained/
     */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length != size + 4);
        _;
    }

    modifier afterOneYear {
        require(now > creationTime + (365 * 24 * 60 * 60));
        _;
    }

    function DFSTokenA() {
        creationTime = now;
        balances[msg.sender] = NON_VESTED_RESERVE_TOKENS;
    }

    function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool) {
        super.transfer(_to, _value);
    }

    function increaseApproval(address _spender, uint _addedValue)
        public
        onlyPayloadSize(2 * 32)
        returns (bool)
    {
        super.increaseApproval(_spender, _addedValue); 
    }

    function decreaseApproval(address _spender, uint _addedValue)
        public
        onlyPayloadSize(2 * 32)
        returns (bool)
    {
        super.decreaseApproval(_spender, _addedValue); 
    }
    
    function claimVestedReserve()
        public
        onlyOwner
        afterOneYear
    {
        balances[msg.sender] = VESTED_RESERVE_TOKENS;
    }
}
