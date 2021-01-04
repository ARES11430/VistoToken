
const Token = artifacts.require('Token')

module.exports = async function(deployer, accounts) {
  // Deploy Token
  await deployer.deploy(Token)
  const token = await Token.deployed()

  // Transfer all tokens to TokenFarm (1 million)
  await token.transfer(taccounts[0], '1000000000')
}
