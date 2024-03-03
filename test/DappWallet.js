const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("DappWallet", function () {
  let owner;
  let user;
  let wallet;
  let usdtToken;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    const USDTToken = await ethers.getContractFactory("ERC20Mock");
    usdtToken = await USDTToken.deploy("USDT Token", "USDT", 18);

    const DappWallet = await ethers.getContractFactory("DappWallet");
    wallet = await DappWallet.deploy();
    await wallet.setUSDT(usdtToken.address);

    await usdtToken.transfer(wallet.address, ethers.utils.parseEther("1000"));
  });

  it("should deposit tokens", async function () {
    await usdtToken.connect(user).approve(wallet.address, ethers.utils.parseEther("100"));
    await wallet.connect(user).deposit(ethers.utils.parseEther("100"));

    expect(await usdtToken.balanceOf(wallet.address)).to.equal(ethers.utils.parseEther("1100"));
    expect(await wallet.balances(user.address)).to.equal(ethers.utils.parseEther("100"));
  });

  it("should withdraw tokens", async function () {
    await usdtToken.connect(user).approve(wallet.address, ethers.utils.parseEther("100"));
    await wallet.connect(user).deposit(ethers.utils.parseEther("100"));

    await wallet.connect(user).withdraw(ethers.utils.parseEther("50"));

    expect(await usdtToken.balanceOf(wallet.address)).to.equal(ethers.utils.parseEther("1050"));
    expect(await wallet.balances(user.address)).to.equal(ethers.utils.parseEther("50"));
  });

  it("should transfer tokens", async function () {
    await usdtToken.connect(user).approve(wallet.address, ethers.utils.parseEther("100"));
    await wallet.connect(user).deposit(ethers.utils.parseEther("100"));

    await wallet.connect(user).transfer(owner.address, ethers.utils.parseEther("25"));

    expect(await usdtToken.balanceOf(wallet.address)).to.equal(ethers.utils.parseEther("1075"));
    expect(await wallet.balances(user.address)).to.equal(ethers.utils.parseEther("75"));
    expect(await wallet.balances(owner.address)).to.equal(ethers.utils.parseEther("25"));
  });
});