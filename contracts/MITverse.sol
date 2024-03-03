// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MITverse is ERC20 {
    address public owner;
    uint256 public mitPriceInBinance;
    IERC20 public binanceToken;
    uint256 public quantity;
    


    uint256 private constant TOTAL_SUPPLY = 100000000 * 10**18; // Total supply of tokens
    mapping(address => uint256) private _lockedBalances30days;
    mapping(address => uint256) private _lockedBalances6months;
    mapping(address => uint256) private _lockStart;

    event TokensLocked(
        address indexed account,
        uint256 amount,
        uint256 lockStart
    );
    event TokensUnlocked(address indexed account, uint256 amount);

    constructor() ERC20("Mitverse", "MIT") {
        _mint(msg.sender, TOTAL_SUPPLY);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setBinance(address _binanceToken) external onlyOwner {
        binanceToken = IERC20(_binanceToken);
    }

    function setMitPriceInBinance(uint256 price) public onlyOwner {
        mitPriceInBinance = price;
    }

    function purchaseTokens(uint256 amount) public payable {
        require(amount > 0, "Amount is 0");
        require(mitPriceInBinance > 0, "MIT price not set");
        uint256 price = amount * mitPriceInBinance * 10**18;

        binanceToken.approve(address(this), price);
        binanceToken.transferFrom(msg.sender, owner, price);

        if(amount<100){
            uint256 newAmt = amount * 10**18 ;
        }
        
        if(amount>=100 && amount<500){
            uint256 newAmt = (amount + 10) * 10**18 ;
            quantity = newAmt;
        }
        if(amount>=500 && amount<1000){
            uint256 newAmt = (amount + 60) * 10**18 ;
            quantity = newAmt;
        }
        if(amount>=1000 && amount<10000){
            uint256 newAmt = (amount + 150) * 10**18 ;
            quantity = newAmt;
        }
        if(amount>=10000){
            uint256 newAmt = (amount + 2000) * 10**18 ;
            quantity = newAmt;
        }

        uint256 unlockedAmount = (((quantity * 99)/100) * 20) / 100;
        uint256 locked30DaysAmount = (((quantity * 99)/100) * 30) / 100;
        uint256 locked6MonthsAmount = (((quantity * 99)/100) * 50) / 100;

        // Transfer the purchased tokens to the buyer
        _transfer(owner, msg.sender, unlockedAmount);

        // Lock 30% of purchased tokens for 30 days
        _lockedBalances30days[msg.sender] += locked30DaysAmount;

        // Lock 50% of purchased tokens for 180 days
        _lockedBalances6months[msg.sender] += locked6MonthsAmount;

        _lockStart[msg.sender] = block.timestamp;

        // Emit event for locked tokens
        emit TokensLocked(msg.sender, locked30DaysAmount, block.timestamp);
        emit TokensLocked(msg.sender, locked6MonthsAmount, block.timestamp);
    }

    function purchaseTokensWithoutLock(uint256 amount) public payable {
        require(mitPriceInBinance > 0, "MIT price not set");
        uint256 price = amount * mitPriceInBinance * 10**18;

        binanceToken.approve(address(this), price);
        binanceToken.transferFrom(msg.sender, owner, price);

        uint256 newAmt = amount * 10**18 ;
        uint256 TotalAmt = ((newAmt * 99)/100) ;
    

        // Transfer the purchased tokens to the buyer
        _transfer(owner, msg.sender, TotalAmt);

    }

    function unlockTokens30days() public {
        uint256 currentLockedBalance = _lockedBalances30days[msg.sender];
        require(currentLockedBalance > 0, "No tokens to unlock");

        if (block.timestamp >= _lockStart[msg.sender] + 30 days) {
            _lockedBalances30days[msg.sender] = 0;
            _mint(msg.sender, currentLockedBalance);
            emit TokensUnlocked(msg.sender, currentLockedBalance);
        }
    }

    function unlockTokens6months() public {
        uint256 currentLockedBalance = _lockedBalances6months[msg.sender];
        require(currentLockedBalance > 0, "No tokens to unlock");

        if (block.timestamp >= _lockStart[msg.sender] + 180 days) {
            _lockedBalances6months[msg.sender] = 0;
            _mint(msg.sender, currentLockedBalance);
            emit TokensUnlocked(msg.sender, currentLockedBalance);
        }
    }

    function lockedBalance30days(address account)
        public
        view
        returns (uint256)
    {
        return _lockedBalances30days[account];
    }

    function lockedBalance6months(address account)
        public
        view
        returns (uint256)
    {
        return _lockedBalances6months[account];
    }


    function lockStart(address account) public view returns (uint256) {
        return _lockStart[account];
    }

    function unlockedBalance30days(address account)
        public
        view
        returns (uint256)
    {
        return balanceOf(account) - _lockedBalances30days[account];
    }

    function unlockedBalance6months(address account)
        public
        view
        returns (uint256)
    {
        return balanceOf(account) - _lockedBalances6months[account];
    }

    function withdrawBNB(uint256 amount) public onlyOwner {
        binanceToken.transfer(owner, amount);
    }

}
