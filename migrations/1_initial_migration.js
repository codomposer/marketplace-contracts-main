const Migrations = artifacts.require('./Migrations.sol')

module.exports = function(deployer) {
    deployer.deploy(Migrations)
}

// const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

// const Marketplace = artifacts.require('Box');
// // const BoxV2 = artifacts.require('BoxV2');

// module.exports = async function (deployer) {
//   const instance = await deployProxy(Marketplace, [42], { deployer });
//   // const upgraded = await upgradeProxy(instance.address, BoxV2, { deployer });
// }
// const Marketplace = artifacts.require("Marketplace");

// module.exports = function (deployer) {
//   deployer.deploy(Marketplace);
// };
