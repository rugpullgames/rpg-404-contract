const RPG404 = artifacts.require('RPG404');

const BASE_URI = 'ipfs://QmQRSqeyAZmLmS5QwQCuMM1U6dVEqyj6MgiPxHB4fCEvyG/';
const BASE_EXT = '.json';

contract('RPG404', (accounts) => {
  before(async () => {
    instance = await RPG404.deployed();
  });

  it('ensures that the starting balance of the total supply is 0', async () => {
    let balance = await instance.totalSupply();
    assert.equal(balance, 0, 'The initial total supply should be 0.');
  });

  it('ensures seting base uri', async () => {
    await instance.setBaseURI(BASE_URI);
  });

  it('allows sale to be active', async () => {
    let active = await instance.saleIsActive();
    assert.equal(active, false, 'Sale should be not active.');
    await instance.flipSale();
    active = await instance.saleIsActive();
    assert.equal(active, true, 'Sale should be active.');
  });

  it('ensures free mints', async () => {
    await instance.freeMint(2);
    let tokenURI = await instance.tokenURI(2);
    assert.equal(tokenURI, BASE_URI + 2 + BASE_EXT, 'The base URI was wrong.');
  });

  //   it('allows donuts to be purchased', async () => {
  //     await instance.purchase(1, {
  //       from: accounts[0],
  //       value: web3.utils.toWei('3', 'ether'),
  //     });
  //     let balance = await instance.getVendingMachineBalance();
  //     assert.equal(balance, 199, 'The balance should be 199 donuts after sale.');
  //   });
});
