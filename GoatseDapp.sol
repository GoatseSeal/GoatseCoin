pragma solidity ^0.4.15;
import "./SafeMath.sol";
import "./GoatseCoin.sol";

/***************************************************************************/
/******************************* GOATSEDAPP ********************************/
/***************************************************************************/

/**
  * Goatse Dapp allows users to vote on their favorite memes through
  * the Goatse Coin contract. Memes are proposed, voted on, then the
  * meme with the most wins and 10 random voters get rewarded. The
  * process restarts every 24 hours.
**/

/* Voting contract for the best OC created today */
contract GoatseDapp {
    uint256 public proposalsToday;                  // How many proposals have there been today
    uint256 public lastPeriod;                      // Time at which last voting period began
    uint256 public periodEnd;                       // At what second the current period ends
    uint256 public currentPeriod;                   // How many periods have there been over the lifespan of GC?
    address public gcAddress;                       // Address of the GoatseCoin

    GoatseCoin goatseCoin;      
    string[] public entryIDs;                       // Use this array to loop through mapping and find winner
    mapping (string => Entry) entries;              // ID so votes can happen using string
    mapping (uint256 => Entry) public pastWinners;  // List of all past winners
    mapping (string => Entry) pastEntries;          // List of all entry names
    uint256[] randomWinners;                        // Make an array to decide on random voter winners

    /* Struct entry keeps track of the data for every entry of the day */
    struct Entry {
        string nameOfEntry;
        address creatorAddress;
        uint256 voteCount;
        uint256[] votes;
        address[] voters;
    }
    
    function GoatseDapp(address _gcAddress) {
        gcAddress = _gcAddress;
        goatseCoin = GoatseCoin(gcAddress);
        currentPeriod = goatseCoin.currentPeriod();
        lastPeriod = now;
    }
       
    function () { revert(); }
    
/** ***************************** ONLY_TOKEN ***************************** **/
    
    /* Voter freezes funds (amount) in order to use them as tickets to vote on OC */
    function vote(string _contentID, uint256 _amount, address _voter) 
      hasEnough(_voter, _amount)
      validCreator(_contentID, entries[_contentID].creatorAddress)
      onlyToken
    returns (bool success)
    {
        require(now <= lastPeriod + 1 days);
        require(_amount > 0);
        assert(goatseCoin.worksIfYoureCool(_voter, _amount));
        entries[_contentID].voteCount += _amount;
        entries[_contentID].voters.push(_voter);
        entries[_contentID].votes.push(_amount);
        return true;
    }
    
    /* If OC has not been added yet, use propose to allow voters to vote using a string */
    function propose(string _contentID, address _creatorAddress, uint256 _amount, address _voter) 
      validCreator(_contentID, _creatorAddress)
      onlyToken
    returns (bool success)
    {
        require(entries[_contentID].creatorAddress == 0);
        require(pastEntries[_contentID].creatorAddress == 0);
        require(proposalsToday <= 300); // get it while it's hot

        entries[_contentID].creatorAddress = _creatorAddress;
        entries[_contentID].nameOfEntry = _contentID;

        // forever de duping
        pastEntries[_contentID].creatorAddress = _creatorAddress;
        pastEntries[_contentID].nameOfEntry = _contentID;

        vote(_contentID, _amount, _voter);
        
        entryIDs.push(_contentID);
        proposalsToday += 1;
        return true;
    }

/** ****************************** EXTERNAL ***************************** **/
    
    /* Finish the day's voting period */
    /* Anyone can call and get paid 1000 coins for calling */
    function finishPeriod()
    returns (bool success)
    {
        require(now > lastPeriod + 1 days);

        string memory winnerID = findWinner();
        payout(winnerID);
        
        pastWinners[currentPeriod] = entries[winnerID];
        clearAll();
        
        currentPeriod += 1;
        assert(goatseCoin.worksIfYoureLoved(currentPeriod));
        
        proposalsToday = 0;
        lastPeriod = now;
        periodEnd = lastPeriod + 1 days;
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
    returns (string _winnerID) 
    {
        uint256 mostVotes;                      // Most votes is whichever entry being checked is currently winning
        for (uint256 i = 0; i < proposalsToday; i++) {
            uint256 ocVotes = entries[entryIDs[i]].voteCount;
            if (ocVotes >= mostVotes) {
                mostVotes = ocVotes;
                _winnerID = entryIDs[i];
            }
        }
        return _winnerID;
    }
    
    /* Payout 50% to winner and 50% to all voters of OC */
    function payout(string _winnerID)
      internal
    returns (bool success)
    {
        /** 
          * Pretty weird way to get a random 10 voters but it works for now.
          * With increment and a somewhat random thing to modulo by (voteCount), it would
          * be difficult to rig beforehand by casting certain votes. What could
          * happen is a lucky miner manipulating time a second or two to rig a
          * randomWinner to be their own vote...probably not worth it.
        **/
        uint256 totalVotes;                     // Total votes; used to get a random number within vote range
        uint256 prngStart = now;
        for (uint256 i = 0; i < proposalsToday; i++) {
            totalVotes += entries[entryIDs[i]].voteCount;
        }
        
        uint256 increment = totalVotes / 10;    // Votes to pass before using voteCount to get randomWinner
        uint256 milestones;                     // Keep track of votes until increment is passed
        for (uint256 j = 0; j < proposalsToday; j++) {
            milestones += entries[entryIDs[j]].voteCount;
            if (milestones >= increment) {
                uint256 randomWinner = (prngStart * entries[entryIDs[j]].voteCount) % totalVotes;
                randomWinners.push(randomWinner);
                milestones = 0;
            }
        }
        
        assert(payVoters(randomWinners));
        assert(goatseCoin.worksIfYoureHot(entries[_winnerID].creatorAddress, 50000 * 1 ether));
        assert(goatseCoin.worksIfYoureHot(msg.sender, 1000 * 1 ether));
        return true;
    }

    /**
      * So gross.
      * Costs too much.
      * Needs to change.
      * (just like ur mom)
    **/    
    function payVoters(uint256[] _randomWinners) 
      internal
    returns (bool success)
    {
        /* Loop through all chosen winners */
        for (uint256 i = 0; i < _randomWinners.length; i++) {
            uint256 lastPlace;
            uint256 currentPlace;
            
            /* Loop through all entries to find entry with the winning vote */
            for (uint256 j = 0; j < proposalsToday; j++) {
                lastPlace = currentPlace;
                Entry storage currentEntry = entries[entryIDs[j]];
                currentPlace += currentEntry.voteCount;
                
                /* If the entry has the vote in it... */
                if (currentPlace >= _randomWinners[i]) {
                    
                    /* Loop through the voters in the entry to find the winner */
                    for (uint256 k = 0; k < currentEntry.voters.length; k++) {
                        lastPlace += currentEntry.votes[k];
                        
                        if (lastPlace >= _randomWinners[i]) {
                            address voter = currentEntry.voters[k];
                            assert(goatseCoin.worksIfYoureHot(voter, 5000 * 1 ether));
                            break;
                        }
                    }
                    break;
                }
            }
        }
        return true;
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
        for (uint256 k = 0; k < randomWinners.length; k++) {
            delete randomWinners[k];
        }
        return true;
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
