import { ethers, upgrades } from "hardhat";

async function main() {
  const Contract = await ethers.getContractFactory("TokenBondingCurve_Exponential");
  const contract = await upgrades.deployProxy(Contract);
  await contract.deployed();
  console.log("Contract deployed to:", contract.address, " by ", await contract.owner());
  console.log(await contract.builtwith());

  await contract.buy(3, {value: 100});

  console.log("**************************CONTRACT***UPGRADATION***************************");

  const ContractV2 = await ethers.getContractFactory("TokenBondingCurve_ExponentialV2");
  const contractV2 = await upgrades.upgradeProxy(contract.address, ContractV2);
  console.log("Upgraded deployed to:", contractV2.address, " by ", await contractV2.owner());
  console.log(await contractV2.builtwith());

  await contractV2.buy(3, {value: 100});

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
