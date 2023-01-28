import { ethers } from "hardhat";
import { Contract } from "ethers"
import { expect } from "chai";
import { TrySVGGenerator } from "../types"

describe("TrySVGGenerator", function () {
  let generator: Contract
  before(async () => {
    generator = await (await ethers.getContractFactory("TrySVGGenerator")).deploy()
    generator.deployed()
  })
  it("should return URI", async () =>{
    const result = await generator.constructTokenURI(7)
    console.log(result)
  })
});
