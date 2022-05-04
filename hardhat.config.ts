import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

task("mintFreeNFT", "Mint free NFTee")
  .addParam("nftContract", "The NFTee contract address")
  .setAction(async (args, hre) => {
    const NFTeeContract = await hre.ethers.getContractAt(
      "NFTee",
      args.nftContract
    );

    const txn = await NFTeeContract.freeMint();
    await txn.wait();

    console.log("Successfully minted an NFTee");
  });

task("getNFTBalance", "Get the number of NFTee's owned by you")
  .addParam("nftContract", "The NFTee contract address")
  .setAction(async (args, hre) => {
    const NFTeeContract = await hre.ethers.getContractAt(
      "NFTee",
      args.nftContract
    );

    const signers = await hre.ethers.getSigners();
    const myAddress = signers[0].address;
    const balance = await NFTeeContract.balanceOf(myAddress);

    console.log(`You own ${balance.toString()} NFTees`);
  });

task("getTokenBalance", "Get the number of reward tokens owned by you")
  .addParam("tokenContract", "The staked token contract address")
  .setAction(async (args, hre) => {
    const StakerContract = await hre.ethers.getContractAt(
      "NFTeeStaker",
      args.tokenContract
    );

    const signers = await hre.ethers.getSigners();
    const myAddress = signers[0].address;
    const balance = await StakerContract.balanceOf(myAddress);

    console.log(`You own ${balance.toString()} stNFTEE Tokens`);
  });

task(
  "setApprovalForAll",
  "Set approval for staking contract to transfer all NFTee tokens"
)
  .addParam("nftContract", "The NFTee contract address")
  .addParam("tokenContract", "The stNFTEE token contract address")
  .setAction(async (args, hre) => {
    const NFTeeContract = await hre.ethers.getContractAt(
      "NFTee",
      args.nftContract
    );

    const txn = await NFTeeContract.setApprovalForAll(args.tokenContract, true);
    await txn.wait();

    console.log("Set approval for all successfully!");
  });

task("stake", "Stake NFTee in Staker")
  .addParam("tokenContract", "The stNFTEE token contract address")
  .addParam("tokenIds", "Comma-separated token id's to stake")
  .setAction(async (args, hre) => {
    const tokenIds = (args.tokenIds as string).split(",");
    const StakerContract = await hre.ethers.getContractAt(
      "NFTeeStaker",
      args.tokenContract
    );

    const txn = await StakerContract.stake(tokenIds);
    await txn.wait();

    console.log(`Staked ${args.tokenIds}`);
  });

task("unstake", "Unstake NFTee in Staker")
  .addParam("tokenContract", "The stNFTEE token contract address")
  .addParam("tokenIds", "Comma-separated token id's to unstake")
  .setAction(async (args, hre) => {
    const tokenIds = (args.tokenIds as string).split(",");
    const StakerContract = await hre.ethers.getContractAt(
      "NFTeeStaker",
      args.tokenContract
    );

    const txn = await StakerContract.unstake(tokenIds);
    await txn.wait();

    console.log(`Unstaked ${args.tokenIds}`);
  });

task("claim", "Claim tokens from Staker")
  .addParam("tokenContract", "The stNFTEE token contract address")
  .setAction(async (args, hre) => {
    const StakerContract = await hre.ethers.getContractAt(
      "NFTeeStaker",
      args.tokenContract
    );

    const txn = await StakerContract.claim();
    await txn.wait();

    console.log(`Claimed tokens from Staker contract`);
  });

const config: HardhatUserConfig = {
  solidity: "0.8.4",
};

export default config;
