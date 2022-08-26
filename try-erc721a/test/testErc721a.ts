import { ethers } from "hardhat";
import { expect } from "chai";
import { TestERC721a } from "../types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signers";
import { BigNumber } from "ethers";
import chai from "chai";
import { solidity } from "ethereum-waffle";

chai.use(solidity);

describe("TestERC721a", () => {
  let erc721a: TestERC721a

  let owner: SignerWithAddress
  let safeTransferFromuser1: SignerWithAddress
  let user1: SignerWithAddress
  let user2: SignerWithAddress
  let user3: SignerWithAddress
  let other: SignerWithAddress

  const quantity = 10

  before(async () => {
    [owner, user1, user2, user3, other] = await ethers.getSigners()
    erc721a = await (await ethers.getContractFactory("TestERC721a")).deploy(100) as TestERC721a
    await erc721a.deployed()
  })

  let snapshotId: number

  beforeEach(async () => {
    snapshotId = await ethers.provider.send("evm_snapshot", []);
  });

  afterEach(async () => {
    await ethers.provider.send("evm_revert", [snapshotId]);
  });

  const getIds = (idsWithBN: BigNumber[]): number[] => {
      const ids: number[] = []
      for (let i = 0; i < idsWithBN.length; i++) {
          ids.push(idsWithBN[i].toNumber())
      }
      return ids
  }

  describe("constructor()", () => {
    it("should be initialized", async () => {
      expect(await erc721a.name()).to.equal("test")
      expect(await erc721a.symbol()).to.equal("TEST")
      expect(await erc721a.maxSupplyPerDay()).to.equal(100)
    })
  })
  describe("mint()", () => {
    describe("fail", () => {
      it("should be reverted if the msg.sender does not have MINTER_ROLE", async () => {
        await expect(erc721a.connect(other).mint(user1.address, 1)).to.be.reverted
      })  
    })
    describe("success", () => {
      it("should mint tokens", async () => {
        expect(await erc721a.balanceOf(user1.address)).to.equal(0)

        await erc721a.mint(user1.address, quantity)

        expect(await erc721a.totalSupply()).to.equal(quantity)
        expect(await erc721a.balanceOf(user1.address)).to.equal(quantity)
        for (let i = 0; i < quantity; i++) {
          expect(await erc721a.ownerOf(i)).to.equal(user1.address)
        }
      })
    })
  })

  describe("burn", () => {
    describe("fail", () => {
      it("should be reverted if the msg.sender does not have the BURNER_ROLE", async () => {
        await erc721a.mint(user1.address, 1)
        await expect(erc721a.connect(other).burn([1])).to.be.reverted
      })
    })
    describe("success", () => {
      it("should burn tokens", async () => {
        await erc721a.mint(user1.address, quantity)

        expect(await erc721a.totalSupply()).to.equal(quantity)
        expect(await erc721a.balanceOf(user1.address)).to.equal(quantity)

        const tokenIds: number[] = []
        for (let i = 0; i < quantity; i++) {
          tokenIds.push(i)
        }
        
        await erc721a.burn(tokenIds)

        expect(await erc721a.totalSupply()).to.equal(0)
        expect(await erc721a.balanceOf(user1.address)).to.equal(0)
      })
    })
  })

  describe("transfer", () => {
    describe("success", () => {
      it("should transfer a token to the other user", async () => {
        await erc721a.mint(user1.address, quantity)
        expect(await erc721a.ownerOf(5)).to.equal(user1.address)
        
        await erc721a.connect(user1)["safeTransferFrom(address,address,uint256)"](user1.address, user2.address, 5)

        expect(await erc721a.ownerOf(5)).to.equal(user2.address)
      })
    })
  })

  describe("tokensOfOwner", () => {
    describe("success", () => {
      it("should return the array of ids that a user has", async () => {
        const firstMintForUser1 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        const firstMintForUser2 = [10, 11, 12]
        const firstMintForUser3 = [13, 14, 15, 16, 17, 18]
        const secondMintForUser1 = [19, 20, 21, 22, 23, 24, 25, 26, 27]
        const secondMintForUser2 = [28, 29, 30]

        await erc721a.mint(user1.address, firstMintForUser1.length)  
        await erc721a.mint(user2.address, firstMintForUser2.length)  
        await erc721a.mint(user3.address, firstMintForUser3.length)  
        await erc721a.mint(user1.address, secondMintForUser1.length)
        await erc721a.mint(user2.address, secondMintForUser2.length)

        const user1TokenIds = await erc721a.tokensOfOwner(user1.address)
        const user2TokenIds = await erc721a.tokensOfOwner(user2.address)
        const user3TokenIds = await erc721a.tokensOfOwner(user3.address)

        const user1Ids = getIds(user1TokenIds)
        const user2Ids = getIds(user2TokenIds)
        const user3Ids = getIds(user3TokenIds)

        expect(user1Ids).to.include.members(firstMintForUser1)
        expect(user2Ids).to.include.members(firstMintForUser2)
        expect(user3Ids).to.include.members(firstMintForUser3)
        expect(user1Ids).to.include.members(secondMintForUser1)
        expect(user2Ids).to.include.members(secondMintForUser2)
      })
    })
  })

  describe("setRoyalty", () => {
    const royalty = 5000;
    const price = 10000
    describe("fail", () => {
      it("should be reverted if the msg.sender is not the admin", async () => {
        await expect(erc721a.connect(other).setRoyalty(other.address, royalty)).to.be.reverted
      })
    })
    describe("success", () => {
      it("should set the default royalty", async () => {    
        await erc721a.setRoyalty(other.address, royalty)
        const result = await erc721a.royaltyInfo(1, price)
        expect(result[0]).to.equal(other.address)
        expect(result[1]).to.equal(price * 0.5)
      })
    })
  })

  describe("tokenURI", () => {
    it("should return the token URI", async () => {
      await erc721a.mint(user1.address, 1)
      expect(await erc721a.tokenURI(0)).to.equal("ipfs://KIICHI")
    })
  })
});
