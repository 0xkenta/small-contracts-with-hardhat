import { expect } from "chai";
import { ethers } from "hardhat";
import { smock, MockContract, MockContractFactory } from "@defi-wonderland/smock";
import { Test, Test__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";


describe("Test.sol", () => {
    let user1: SignerWithAddress
    let mockContract: MockContract<Test>
    beforeEach(async () => {
        [, user1] = await ethers.getSigners()
        const myMockContractFactory = await smock.mock('Test')
        mockContract = await myMockContractFactory.deploy() as unknown as MockContract<Test>
    })

    it("should set the variable number with smock", async () => {
        expect(await mockContract.number()).to.equal(0)

        const fakeNumber = 100
        await mockContract.setVariable("number", fakeNumber)
        expect(await mockContract.number()).to.equal(fakeNumber)
        
        const fakeNumber2 = 77
        mockContract.number.returns(fakeNumber2);
        expect(await mockContract.number()).to.equal(fakeNumber2)
    })

    it("should set the mapping with smock", async () => {
        expect(await mockContract.numbers(user1.address)).to.equal(0)
        const user1Address = user1.address
        const newNumber = 77
        await mockContract.setVariable('numbers', {
            [user1Address]: newNumber
        });
        expect(await mockContract.numbers(user1.address)).to.equal(newNumber)
    })
})