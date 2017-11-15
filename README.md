# GoatseCoin
Goatse is a blockchain-based incentivized meme generation platform where users cast votes on their favorite memes of the day and the winner and 10 random voters receive prizes. Users can both propose a new meme and vote from the token contract. They enter in a string with their vote which is tied to an entry, that entry's vote count is increased by the number of votes they submitted, and the voter is added to the list of voters on that meme (so random voters weighted by votes submitted can be found later). A user can cast as many votes as they have GoatseCoins; the number of coins voted with are then frozen until the end of the current voting period. Once 24 hours of voting has passed, anyone can call the finish period function which finds and rewards the winning meme and the random voter winners--this caller receives 1,000 Goatse for paying the gas of this function. Rinse and repeat.


<h1>Contracts:</h1>
<h2>1. GoatseCoin.sol:</h2> 
The ERC20 token contract. The difference between this and any default token is that users are given the ability to propose and vote on GoatseDapp memes (to allow user all control from on contract) and users have a balance and a frozen balance, which is used to temporarily lock funds that have been voted with. <b>The owner of this contract has the ability to mint coins at will (as it can change the minter); users must be given the ability to control the token quickly so us malicious owners cannot take advantage of this!</b>

<h2>2. GoatseDapp.sol:</h2> 
This contract holds the core of the voting system. Users will first propose a meme, it will be voted on (and voters will be minted 1% of the tokens they vote with), then--at the end of the voting period--the meme with the most votes will be declared winner and rewarded a large amount of coins. The main functions on the Dapp can only be called from the token so as to consolidate all use in one contract. The Dapp can be changed out at will by the owner of the token but, as stated above,  this means the owner can essentially mint coins at will, so the Dapp (or token) must soon be given a function for the users to be able to be the owner of the contract in a PoS manner.

<h2>3. Crowdsale.sol:</h2>
Straightforward crowdsale contract.
<h2>4. Holder.sol:</h2> 
Locks founder tokens in a contract for 1 year. The crowdsale contract gives all founder and advisor GoatseCoins to this address, then whoever launched Holder.sol can assign addresses and percent of team tokens to team members who can then withdraw 1 year after the crowdsale ended.
<h2>5. MultiSig Wallet:</h2> 
Consensys multisig that we will likely use for receiving crowdsale funds.


<h1>Bug Bounty:</h1>

We take security seriously so please  go over our contracts and report any findings to GoatseSeal on Reddit. We don't just care about disastrous bugs like many other ICOs; report non-asserted sends, functions acting differently than claimed, efficiency problems, or even suggestions. We'll be judging all reports on a case-by-case basis and will reward reporters a generous amount of GoatseCoins.
