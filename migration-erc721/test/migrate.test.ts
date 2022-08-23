import { ethers } from "hardhat";
import chai, { expect } from "chai";
import { constants } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { Migration, TestNewNft, TestOldNft } from "../types";
import { solidity } from "ethereum-waffle";

chai.use(solidity);

describe("Migration", function () {
  let oldContract: TestOldNft;
  let newContract: TestNewNft;
  let migration: Migration;

  let deployer: SignerWithAddress;
  let user1: SignerWithAddress;
  let other: SignerWithAddress;

  const tokenId1 = 1;

  before(async () => {
    [deployer, user1, other] = await ethers.getSigners();

    oldContract = (await (
      await ethers.getContractFactory("TestOldNft")
    ).deploy()) as TestOldNft;
    oldContract.deployed();

    migration = (await (
      await ethers.getContractFactory("Migration")
    ).deploy(oldContract.address)) as Migration;

    newContract = (await (
      await ethers.getContractFactory("TestNewNft")
    ).deploy(migration.address)) as TestNewNft;
    newContract.deployed();

    await migration.setNewContract(newContract.address);
  });

  describe("TestOldNft", () => {
    it("should mint a NFT", async () => {
      expect(await oldContract.balanceOf(user1.address)).to.equal(0);

      await oldContract.mint(user1.address, tokenId1);

      expect(await oldContract.balanceOf(user1.address)).to.equal(tokenId1);
      expect(await oldContract.ownerOf(tokenId1)).to.equal(user1.address);
    });
    it("should pause the mint function", async () => {
      expect(await oldContract.paused()).to.equal(false);

      await oldContract.pause();

      expect(await oldContract.paused()).to.equal(true);
      await expect(oldContract.mint(user1.address, 2)).to.be.revertedWith(
        "Pausable: paused"
      );
    });
  });
  describe("Migration", async () => {
    it("should be reverted if the msg.sender is neither owner nor migrator", async () => {
      await expect(migration.connect(other).migrate(1)).to.be.revertedWith(
        "NoPermission()"
      );
    });
    it("should migrate from the old to the new contract(transfer the old token to the migration contract and mint a new token in the new contract)", async () => {
      expect(await oldContract.ownerOf(tokenId1)).to.equal(user1.address);
      expect(await newContract.balanceOf(user1.address)).to.equal(0);

      await oldContract.connect(user1).approve(migration.address, tokenId1);
      await migration.connect(user1).migrate(1);

      expect(await oldContract.ownerOf(tokenId1)).to.equal(migration.address);
      expect(await newContract.balanceOf(user1.address)).to.equal(1);
      expect(await newContract.ownerOf(tokenId1)).to.equal(user1.address);
    });
  });
});
