pragma solidity ^0.4.15;
import "./SafeMath.sol";
import "./GoatseDapp.sol";
/**
  * Honestly dude, fuck you.
**/
/**
  * whatever bro, her death was your fault.
**/

/**************************************************************************/
/****************************** GOATSECOIN ********************************/
/**************************************************************************/

/**
  * Goatse Coin is the ERC20 token to be used along with the Goatse Dapp.
  * Functions on this token contract allow users to vote on the Dapp from
  * here and coins can be frozen by the Dapp when they are used to vote.
**/

/** Which variables do we want public on launch? **/
contract GoatseCoin {
    using SafeMath for uint256;
  
    address public owner;
    uint256 public currentPeriod;
    address public goatsedapp; // This address is allowed to mint coins
    GoatseDapp goatse;
    
    string public symbol                = "GTC";
    string public name                  = "Goatse Coin";
    uint8 public decimals               = 18;
    uint256 totalSupply;

    mapping (address => uint256) public balances;
    mapping (address => mapping (uint256 => uint256)) public frozenBalances;
    mapping (address => mapping (address => uint256)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value);
    event Mint(address indexed _to, uint256 indexed _value);
    event Freeze(address indexed _from, uint256 indexed _value, uint256 indexed _period);
    event Approval(address indexed _owner, address indexed _spender, uint256 indexed _value);

    /* Owner is only used to change address of DAO */
    /* After alpha Dapp will become owner */
    function GoatseCoin() {
        owner = msg.sender;
    }

/** ****************************** TOKEN ******************************** **/

    /* transfer... */
    function transfer(address _to, uint256 _amount) 
    returns (bool success) 
    {
        require(_to != address(0));
        require(_amount > 0);
        
        // These balance requires are needed even with SafeMath because
        // of our balances - frozenBalances strategy
        require(balanceOf(_to) + _amount > balanceOf(_to));
        require(balanceOf(msg.sender) >= _amount); // hold up..

        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /* balanceOf address (needs to include/exclude frozen assets) */
    function balanceOf(address _owner) 
      constant 
    returns (uint256 balance) 
    {
        return balances[_owner].sub(frozenBalances[_owner][currentPeriod]);
    }
    
    /* Yep fuckin transferfrom or whatever fuck this who even uses it */
    function transferFrom(address _from, address _to, uint256 _amount) 
    returns (bool success) 
    {
        require(_to != address(0) && _from != address(0));
        require(balanceOf(_from) >= _amount); // what the fuck
        require(balanceOf(_to) + _amount > balanceOf(_to));
        require(allowed[_from][msg.sender] >= _amount);
        
        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because fuck you
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        allowed[_from][msg.sender] = _allowance.sub(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    /* seriously when is this ever used */
    function approve(address _spender, uint256 _amount) 
    returns (bool success) 
    {
        require(balanceOf(msg.sender) >= _amount); // fuck outta here
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
    
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount); // This line is how we steal everything
        return true;
    }

    /* parents money */
    function allowance(address _owner, address _spender) 
      constant 
    returns (uint256 remaining) 
    {
        return allowed[_owner][_spender];
    }
    
/** **************************** DAPP VOTING *************************** **/

    function vote(string contentID, uint256 amount) 
    returns (bool success)
    {
        goatse.vote(contentID, amount, msg.sender);
        return true;
    }
    
    function propose(string contentID, address creatorAddress, uint256 amount)
    returns (bool success)
    {
        goatse.propose(contentID, creatorAddress, amount, msg.sender);
        return true;
    }
    
/** **************************** ONLY_DAPP ***************************** **/
    
    /* Use freeze to hold coins for voting periods */
    function worksIfYoureCool(address _owner, uint256 _amount, uint256 _period)
      onlyDapp
    returns (bool success)
    {
        require(_owner != address(0));
        require(_amount > 0);

        frozenBalances[_owner][_period] = frozenBalances[_owner][_period].add(_amount);
        Freeze(_owner, _amount, _period);
        return true;
    }
    
    /* Changes currentPeriod to match the Dapp's */
    function worksIfYoureLoved(uint256 _period)
      onlyDapp
    returns (bool success)
    {
        require(_period > 0);

        currentPeriod = _period;
        return true;
    }

    /* Mint new coins. Used for initial launch and dispersing prize coins and cheating */
    function worksIfYoureHot(address _to, uint256 _amount) 
      onlyDapp
    returns (bool success) 
    {
        require(_to != address(0));
        require(_amount > 0);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

/** ************************** ONLY_OWNER ****************************** **/

    /* In case we fuck up coding the Dapp (obviously gonna happen) */
    /* Dapp WILL change before ICO */
    function worksIfYoureSexy(address _newdapp) 
      onlyOwner
    returns (bool success)
    {
        require(_newdapp != address(0));

        goatsedapp = _newdapp;
        goatse = GoatseDapp(goatsedapp);
        return true;
    }

    /* Dapp will be owner after alpha */
    function worksIfYoureFunny(address _newOwner)
      onlyOwner
    returns (bool success)
    {
        require(_newOwner != address(0));

        owner = _newOwner;
        return true;
    }
    
/** ***************************** MODIFIERS **************************** **/
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyDapp() {
        require(msg.sender == goatsedapp);
        _;
    }
    
/** ***************************** FORTHELULZ *************************** **/
    
    /* lol I'm a good coder see */
    function theOnlyReasonThisFunctionExistsIsBecauseIWantYouToGoBlankYourself()
    returns (bool)
    {
        return true;
    }
}
