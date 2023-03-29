# Simplified Compound Contracts

The contracts in this directory are reduced versions of the Compound protocol contracts found in [`../compound-0.8.10`](https://github.com/webthethird/solidity-diff-fuzz-upgrades/tree/main/contracts/test/compound/compound-0.8.10). The core contracts, prefixed with `Simple`, have had some functionality removed to simplify evaluation and testing, with the Comp token distribution bug in mind.

## Core Contracts
------------
### __SimpleComptrollerV1__
- The main brains of the protocol, before the upgrade that introduces the bug. Stores the state of all active markets, reward distribution rates and all liquidity providers for each market. 
  - New markets can be added by the admin with `_supportMarket(CToken cToken)`, which in turn calls `_addMarketInternal(address cToken)`. 
  - The admin can set the rate at which suppliers are rewarded with `_setCompSpeed(CToken cToken, uint compSpeed)`. 
  - Suppliers can claim their Comp rewards for all markets by calling `claimComp()`, which calls `updateCompSupplyIndex(address cToken)` and `distributeSupplierComp(address cToken, address supplier)` for each market in `allMarkets`, followed by a call to `grantCompInternal(address user, address amount)`.
    - `updateCompSupplyIndex(address cToken)` updates the state of the market, determining the amount of Comp accrued to the market based on the Comp speed and the time that has passed since the last update.
    - `distributeSupplierComp(address cToken, address supplier)` determines how much Comp an individual supplier has accrued for a market, based on the total Comp accrued to the market itself and the proportion of the market's CTokens held by the supplier.
    - `grantCompInternal(address user, address amount)` transfers Comp tokens from the Comptroller to the user, in the amount of `compAccrued[user]`.
  - Borrowing functionality has been removed, as have functions related to liquidating or seizing borrow positions, as these functions are all essentially more complicated versions of the supply logic, i.e., `distributeBorrowerComp` was very similar to `distributeSupplierComp`.
  - During an upgrade, the admin must call `._become(Unitroller unitroller)`, which calls `unitroller._acceptImplementation()`.

### __SimpleComptrollerV2__
- The upgraded brains of the protocol, based on the upgrade that introduces the token distribution bug.
  - In addition to `_addMarketInternal(address cToken)`, the `_supportMarket(CToken cToken)` function also calls a new internal function, `_initializeMarket(address cToken)`.
    - If the market has not yet accrued any Comp rewards, `_initializeMarket` will set the index to `compSupplyState[cToken].index = compInitialIndex = 1e36`.
  - In addition to `unitroller._acceptImplementation()`, the `_become(Unitroller unitroller)` function also calls `_upgradeSplitCompRewards()`.
    - This function was added because the original upgraded Comptroller switched from a single Comp speed per market to two speeds, one for suppliers and one for borrowers (this has been left out of the simplified contract).
    - Besides setting `compBorrowSpeeds` and `compSupplySpeeds` (commented out here), this function does the same thing as `_initializeMarket` for every market in `allMarkets`, setting `compSupplyState[cToken].index = 1e36` if `compSupplyState[cToken].index == 0`.
  - `distributeSupplierComp(address cToken, address supplier)` has roughly the same logic as before, but because of the new market initialization, it does not behave as expected when `compSupplierIndex[cToken][supplier] == 0` and `compSupplyState[cToken].index == compInitialIndex`.
    - The condition `if (supplierIndex == 0 && supplyIndex > compInitialIndex)`, which is meant to cover the case where users supplied tokens before the market's supply state was set, evaluates to false, so the line that sets `supplierIndex = compInitialIndex` is not reached (it should have been `supplyIndex >= compInitialIndex`).
    - The amount of Comp distributed is based on the delta between `supplyIndex` and `supplierIndex`, which would be 0 if the condition above evaluated to true, but turns out to be `1e36` due to the market initialization. Therefore far too much Comp is accrued to the user when they call `claimComp()`.

### __SimpleUnitroller__
- The proxy contract for the Comptroller. 
  - To upgrade, the admin must call `_setPendingImplementation(address newPendingImplementation)` before calling `Comptroller._become(Unitroller unitroller)`.
  - `_acceptImplementation()` can only be called by the new Comptroller contract in response to a call to `_become`.

### __SimpleCToken__
- The base contract for a Compound market token. Real-world cTokens are either `CErc20`s representing an underlying ERC20 token or `CEther`, the market for ETH. Stores the cToken balance per user, an exchange rate for the underlying asset, an interest rate model and a pointer to the Unitroller.
  - Has the typical token `transfer`, `transferFrom`, `approve`, `allowance` and `balanceOf`.
  - `accrueInterest()` calculates interest accrued since the last checkpointed block.
  - Internal functions `mintInternal(uint mintAmount)` for minting cTokens, `redeemInternal(uint redeemTokens)` and `redeemUnderlyingInternal(uint redeemAmount)` for redeeming them for underlying tokens, both accrue interest before calling `mintFresh` and `redeemFresh`.
    - `mintFresh(address minter, uint mintAmount)` calls `Comptroller.mintAllowed`, which in turn calls `updateCompSupplyIndex` and `distributeSupplierComp`, and then calls `doTransferIn` which is implemented in the `CErc20` sub-class.
    - `redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn)` calls `Comptroller.redeemAllowed`, which in turn calls `updateCompSupplyIndex` and `distributeSupplierComp`, and then calls `doTransferOut` which is implemented in the `CErc20` sub-class.
  - `borrowInternal`, `repayBorrowInternal`, `liquidateBorrowInternal` and `seize` have been removed.

### __SimpleCErc20__
- Inherits `SimpleCToken`, stores the address of the underlying token, implements external `mint` and `redeem` functions as well as internal `doTransferIn` and `doTransferOut`.
  - `mint(uint mintAmount)` calls `mintInternal`, `redeem(uint redeemTokens)` and `redeemUnderlying(uint redeemAmount)` call `redeemInternal` and `redeemUnderlyingInternal` respectively.
  - `doTransferIn(address from, uint amount)` calls `underlying.transferFrom(from, address(this), amount)`.
  - `doTransferOut(address payable to, uint amount)` calls `underlying.transfer(to, amount)`.
  - `borrow`, `repayBorrow`, `repayBorrowBehalf`, `liquidateBorrow` and `sweepToken` have been removed.

### __SimpleComp__
- Really just a typical token, since all governance related functionality has been removed.
  - The Unitroller maintains a balance of Comp for distributing rewards.
  - Typically the Comp token address is hardcoded in the Comptroller, but if it needs to be deployed to a different address, we can use the `ComptrollerHarness` contracts defined at the bottom of `SimpleComptrollerV1.sol` and `SimpleComptrollerV2.sol`, which adds a new `compAddress` variable with getter/setter.
