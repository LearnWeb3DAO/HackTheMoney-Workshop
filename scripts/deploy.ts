import { ethers } from "hardhat";

async function main() {
  const NFTeeFactory = await ethers.getContractFactory("NFTee");
  const NFTeeContract = await NFTeeFactory.deploy(100);
  await NFTeeContract.deployed();

  console.log(`NFTee contract deployed to ${NFTeeContract.address}`);

  const NFTeeStakerFactory = await ethers.getContractFactory("NFTeeStaker");
  const NFTeeStakerContract = await NFTeeStakerFactory.deploy(
    NFTeeContract.address,
    "Staked NFTee",
    "stNFTEE"
  );
  await NFTeeStakerContract.deployed();

  console.log(
    `NFTeeStaker contract deployed to ${NFTeeStakerContract.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
