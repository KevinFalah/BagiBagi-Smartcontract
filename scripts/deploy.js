
const hre = require("hardhat");

async function main() {

  const BagiBagi = await hre.ethers.deployContract("BagiBagi");

  await BagiBagi.waitForDeployment();

  console.log(`Success deployed to ${BagiBagi.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
