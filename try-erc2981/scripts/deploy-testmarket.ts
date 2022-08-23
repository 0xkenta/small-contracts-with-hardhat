import { ethers } from "hardhat";

async function main() {
  const nft = await (
    await ethers.getContractFactory("TestNFTWithRoyalties")
  ).deploy();
  nft.deployed();

  const marketplace = await (
    await ethers.getContractFactory("TestMarketplace")
  ).deploy();
  nft.deployed();
  console.log("nft address: ", nft.address);
  console.log("marketplace address: ", marketplace.address);
  // await marketplace.initialize()
  // await marketplace.updateTransactableNft(nft.address, true)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
