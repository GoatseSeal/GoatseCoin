pragma solidity ^0.4.18;

/**
  * @dev Extremely simple giveaway contract. 
  * @dev Wallet sends default transaction to contract, contract sends back
  * @dev 1000 GTC. People can easily game it by making new wallets but
  * @dev the goal is that the gas cost + effort won't be worth it at this point.
**/

contract Token { function transfer(address _to, uint256 _value) returns (bool); }
contract Giveaway {
    Token token;
    
    mapping (address => bool) receivers;
    
    function Giveaway(address _tokenAddress) 
    {
        token = Token(_tokenAddress);
    }
    
    function ()
      payable
    {
        require(!receivers[msg.sender]);
        assert(token.transfer(msg.sender, 1000 * 1 ether));
    }
}
