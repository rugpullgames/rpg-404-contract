const VendingMachine = artifacts.require('VendingMachine');

contract('VendingMachine', (account) => {
  before(async () => {
    instance = await VendingMachine.deployed();
  });

  it('ensures that the starting balance of the vending machine is 100', async () => {
    let balance = await instance.getVendingMachineBalance();
    assert.equal(balance, 100, 'The initial balance should be 100 donuts.');
  });
});
