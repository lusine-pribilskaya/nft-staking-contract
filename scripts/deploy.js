require("dotenv").config();
const hre = require("hardhat");

async function main() {
  const nft = process.env.NFT_ADDRESS;
  const rewardToken = process.env.REWARD_TOKEN_ADDRESS;

  const NFTStaking = await hre.ethers.getContractFactory("NFTStaking");
  const staking = await NFTStaking.deploy(nft, rewardToken);

  await staking.deployed();
  console.log("NFTStaking deployed to:", staking.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
