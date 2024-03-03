// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DappWallet {
    address public owner;
    IERC20 public usdtToken;

    mapping(address => uint256) public balances;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event Transfer(address user, address receiver, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setUSDT(address _usdtToken) external onlyOwner {
        usdtToken = IERC20(_usdtToken);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount less than 0");
        require(
            usdtToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount less than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(usdtToken.transfer(msg.sender, amount), "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    function withdrawAll() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        require(usdtToken.transfer(msg.sender, amount), "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) external {
        require(amount > 0, "Transfer amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}
