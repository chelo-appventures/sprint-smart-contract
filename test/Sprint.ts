import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("Sprint", function () {
  async function deployOneSprint() {
    // Contracts are deployed using the first signer/account by default
    const [comprador, vendedor, agente] = await hre.ethers.getSigners();
    const ONE_DAY_IN_SECS = 24 * 60 * 60;
    const TEN_DAY_IN_SECS = 10 * 24 * 60 * 60;
    const amount = "1000000000000000000"; // 1 ether
    const start = (await time.latest()) + ONE_DAY_IN_SECS;
    const end = start + TEN_DAY_IN_SECS;
    const hashDocument =
      "0xd283f3979d00cb5493f2da07819695bc299fba34aa6e0bacb484fe07a2fc0ae0";
    const Sprint = await hre.ethers.getContractFactory("Sprint");
    const sprint = await Sprint.deploy(
      comprador,
      vendedor,
      agente,
      amount,
      start,
      end,
      hashDocument
    );

    return {
      sprint,
      comprador,
      vendedor,
      agente,
      amount,
      start,
      end,
      hashDocument,
    };
  }

  describe("Deployment", function () {
    it("Should set voteCustomer to false", async function () {
      const { sprint } = await loadFixture(deployOneSprint);
      expect(await sprint.customerApprove()).to.equal(false);
    });
    it("Should set voteProvider to false", async function () {
      const { sprint } = await loadFixture(deployOneSprint);
      expect(await sprint.providerApprove()).to.equal(false);
    });
    it(`Should set monto to 1 ether`, async function () {
      const { sprint, amount } = await loadFixture(deployOneSprint);
      expect(await sprint.amount()).to.equal(amount);
    });
    it(`the interval of time need to be 10 days`, async function () {
      const { sprint, start, end } = await loadFixture(deployOneSprint);
      const TEN_DAY_IN_SECS = 10 * 24 * 60 * 60;
      const _start = await sprint.getStartDate();
      const _end = await sprint.getEndDate();
      const intervalo = _end - _start;
      expect(intervalo)
        .to.equal(end - start)
        .to.equal(TEN_DAY_IN_SECS);
    });
  });
});
