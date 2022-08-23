import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, utils } from "ethers";
import { TestNFTWithRoyalties, TestMarketplace } from "../types";
import chai, { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { solidity } from "ethereum-waffle";

chai.use(solidity);

describe("TestMarketplace.sol", () => {
  let nft: TestNFTWithRoyalties;
  let marketplace: TestMarketplace;

  let owner: SignerWithAddress;
  let user1: SignerWithAddress;
  let user2: SignerWithAddress;
  let royaltyRecipient: SignerWithAddress;

  before(async () => {
    [owner, user1, user2, royaltyRecipient] = await ethers.getSigners();
    nft = (await (
      await ethers.getContractFactory("TestNFTWithRoyalties")
    ).deploy()) as TestNFTWithRoyalties;
    nft.deployed();

    marketplace = (await (
      await ethers.getContractFactory("TestMarketplace")
    ).deploy()) as TestMarketplace;
    nft.deployed();
    await marketplace.initialize();
    await marketplace.updateTransactableNft(nft.address, true);
  });

  it("prove the erc2981", async () => {
    const royaltyRate = 5000;
    await nft.mint(user1.address, royaltyRecipient.address, royaltyRate);
    expect(await nft.ownerOf(1)).to.equal(user1.address);

    await nft.connect(user1).approve(marketplace.address, 1);
    const askPrice = BigNumber.from("1000000000000000000");
    await marketplace.connect(user1).createAsk(nft.address, 1, askPrice);

    const ask = await marketplace.asks(nft.address, 1);
    expect(ask.seller).to.equal(user1.address);
    expect(ask.askPrice).to.equal(askPrice);

    const balanceBef = await royaltyRecipient.getBalance();

    const value = utils.parseEther("1.0");
    const options = { value: value };
    await marketplace.connect(user2).buyNft(nft.address, 1, options);

    const balanceAft = await royaltyRecipient.getBalance();

    const expectedRoyalty = utils.parseEther("1.0").mul(royaltyRate).div(10000);
    expect(balanceAft).to.equal(balanceBef.add(expectedRoyalty));
  });
});
