pragma solidity ^0.4.18;
import "./SafeMath.sol";
import "./GoatseCoin.sol";

/***************************************************************************/
/******************************* GOATSEDAPP ********************************/
/***************************************************************************/

/**
  * Goatse Dapp allows users to vote on their favorite memes through
  * the Goatse Coin contract. Memes are proposed, voted on, then the
  * meme with the most wins. Each voter is rewarded 1% of what they vote.
**/

/* Voting contract for the best OC created today */
contract GoatseDapp {
    uint256 public proposalsToday;                  // How many proposals have there been today
    uint256 public periodStart;                     // Time at which last voting period began
    uint256 public periodEnd;                       // At what second the current period ends
    uint256 public currentPeriod;                   // How many periods have there been over the lifespan of GC?
    address gcAddress;

    GoatseCoin goatseCoin;      
    string[] public entryIDs;                       // Use this array to loop through mapping and find winner
    mapping (string => Entry) entries;              // ID so votes can happen using string
    mapping (uint256 => Entry) public pastWinners;  // List of all past winners: period => Entry

    /* Struct entry keeps track of the data for every entry of the day */
    struct Entry {
        string nameOfEntry;
        address creatorAddress;
        uint256 voteCount;
    }
    
    function GoatseDapp(address _gcAddress) 
      public
    {
        gcAddress = _gcAddress;
        goatseCoin = GoatseCoin(gcAddress);
        currentPeriod = goatseCoin.currentPeriod();
        periodStart = now;
        periodEnd = periodStart + 1 days;
    }
       
/** ***************************** ONLY_TOKEN ***************************** **/
    
    /* Voter freezes funds (amount) in order to use them as tickets to vote on OC */
    function vote(string _contentID, uint256 _amount, address _voter) 
      hasEnough(_voter, _amount)
      validCreator(_contentID, entries[_contentID].creatorAddress)
      onlyToken
      public
    returns (bool success)
    {
        require(now <= periodEnd);
        require(_amount > 0);
        assert(goatseCoin.worksIfYoureCool(_voter, _amount));
        assert(goatseCoin.worksIfYoureHot(_voter, _amount / 500));
        entries[_contentID].voteCount += _amount;
        return true;
    }
    
    /* If OC has not been added yet, use propose to allow voters to vote using a string */
    function propose(string _contentID, address _creatorAddress, uint256 _amount, address _voter) 
      validCreator(_contentID, _creatorAddress)
      onlyToken
      external
    returns (bool success)
    {
        require(entries[_contentID].creatorAddress == 0);
        require(proposalsToday <= 300); // get it while it's hot

        entries[_contentID].creatorAddress = _creatorAddress;
        entries[_contentID].nameOfEntry = _contentID;

        vote(_contentID, _amount, _voter);
        
        entryIDs.push(_contentID);
        proposalsToday += 1;
        return true;
    }

/** ****************************** EXTERNAL ***************************** **/
    
    /* Finish the day's voting period */
    /* Anyone can call and get paid 1000 coins for calling */
    function finishPeriod()
      public
    returns (bool success)
    {
        require(now > periodEnd);
        
        assert(findWinner());
        assert(clearAll());
        
        currentPeriod += 1;
        assert(goatseCoin.worksIfYoureLoved(currentPeriod));
        
        proposalsToday = 0;
        periodStart = now;
        periodEnd = periodStart + 1 days;
        return true;
    }
    
    function getVotes(string _entryID)
      constant
    returns (uint256 votes)
    {
        return entries[_entryID].voteCount;
    }

/** ***************************** INTERNAL ******************************** **/
    
    function findWinner()
      internal
    returns (bool success)
    {
        uint256 mostVotes;                      // Most votes is whichever entry being checked is currently winning
        string currentWinner;                   // Keep track of whoever currently has bribed me the most
        for (uint256 i = 0; i < proposalsToday; i++) {
            uint256 ocVotes = entries[entryIDs[i]].voteCount;
            if (ocVotes >= mostVotes) {
                mostVotes = ocVotes;
                currentWinner = entryIDs[i];
            }
        }
	pastWinners[currentWinner] = entries[entryIDs[i]];
        assert(goatseCoin.worksIfYoureHot(entries[currentWinner].creatorAddress, 50000 * 1 ether));
        assert(goatseCoin.worksIfYoureHot(msg.sender, 1000 * 1 ether));
        success = true;
    }
    
    /* Delete OC Entry struct at the end of the day */
    function clearAll()
      internal
    returns (bool success)
    {
        for (uint256 f = 0; f < proposalsToday; f++) {
            delete entries[entryIDs[f]];
            delete entryIDs[f];
        }
        success = true;
    }
    
/** ***************************** MODIFIERS **************************** **/

    /* Can only vote through the token */
    modifier onlyToken() 
    {
        require(msg.sender == gcAddress);
        _;
    }

    /* Check if the voter has enough GC balance for their desired votes */
    modifier hasEnough(address _voter, uint256 _amount) 
    {
        require(goatseCoin.balanceOf(_voter) >= _amount);
        _;
    }
    
    /* Check if the desired variables aren't null */
    modifier validCreator(string _ocID, address _creatorAddress) 
    {
        require(bytes(_ocID).length != 0);
        require(_creatorAddress != 0);
        _;
    }
}
