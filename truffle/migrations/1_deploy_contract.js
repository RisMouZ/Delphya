const DPT = artifacts.require("DPT");
const Dapp = artifacts.require("Dapp");

module.exports = async function (deployer) {
  await deployer.deploy(DPT);
  const dpt = await DPT.deployed();
  await deployer.deploy(Dapp, dpt.address);
  const dapp = await Dapp.deployed();
};
