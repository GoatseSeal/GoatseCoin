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
    address owner;
    
    mapping (address => bool) receivers;
    
    function Giveaway() 
    {
        token = Token(0x71d271f8b14adef568f8f28f1587ce7271ac4ca5);
        owner = msg.sender;
    }
    
    function ()
      payable
      external
    {
        require(!receivers[msg.sender]);
        assert(token.transfer(msg.sender, 1000 * 1 ether));
        receivers[msg.sender] = true;
    }
    
    function withdraw(uint256 _value)
      external
    returns (bool success)
    {
        require(msg.sender == owner);
        assert(token.transfer(owner, _value * 1 ether));
        return true;
    }
}
