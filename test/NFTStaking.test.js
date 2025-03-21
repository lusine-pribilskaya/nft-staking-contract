const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTStaking", function () {
  let nft, rewardToken, staking, owner, user;
  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    const NFT = await ethers.getContractFactory("MockNFT");
    nft = await NFT.deploy();
    await nft.mint(user.address, 1);

    const Token = await ethers.getContractFactory("MockERC20");
    rewardToken = await Token.deploy();
    await rewardToken.transfer(staking?.address ?? owner.address, ethers.parseEther("1000"));

    const NFTStaking = await ethers.getContractFactory("NFTStaking");
    staking = await NFTStaking.deploy(nft.target, rewardToken.target);

    await nft.connect(user).approve(staking.target, 1);
  });

  it("should stake and earn rewards", async function () {
    await staking.connect(user).stake(1);
    await ethers.provider.send("evm_increaseTime", [86400]);
    await ethers.provider.send("evm_mine");
    await staking.connect(user).claimAllRewards();
  });
});
