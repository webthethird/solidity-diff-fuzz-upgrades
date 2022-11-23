pragma solidity ^0.5.16;

contract Token {
    mapping (address => uint96) internal balances;
    /*-----------------------------------snip-------------------------------------*/
    function balanceOf(address account) external view returns (uint) { return balances[account]; }
    function transfer(address dst, uint amount) external { transfer(msg.sender, dst, amount); }
    function transfer(address src, address dst, uint amount) external {
        if(balances[src] >= amount) {
            balances[src] -= amount;
            balances[dst] += amount;
        }
    }
}

contract SimpleComptroller {
    struct CompMarketState {
        uint224 compAccruedPerUnit;
        uint32 block;
    }
    Token constant COMP = Token(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    Token[] public allMarkets;
    uint224 public constant compInitialAccruedPerUnit = 1e36;
    mapping(address => CompMarketState) public compSupplyState;
    mapping(address => CompMarketState) public compBorrowState;
    mapping(address => mapping(address => uint)) public compSupplierAccruedPerUnit;
    mapping(address => mapping(address => uint)) public compBorrowerAccruedPerUnit;
    mapping(address => uint) public compAccrued;
    /*-----------------------------------snip-------------------------------------*/
    function distributeSupplierComp(address cToken, address supplier) internal {
        CompMarketState storage supplyState = compSupplyState[cToken];
        uint supplyAccruedPerUnit = supplyState.compAccruedPerUnit;
        uint supplierAccruedPerUnit = compSupplierAccruedPerUnit[cToken][supplier];

        compSupplierAccruedPerUnit[cToken][supplier] = supplyAccruedPerUnit;

        if (supplierAccruedPerUnit == 0 && supplyAccruedPerUnit > compInitialAccruedPerUnit) {
            // Covers case where users supplied tokens before the market's supply state compAccruedPerUnit was set.
            // Rewards user with COMP accrued from when supplier rewards were first set for the market.
            supplierAccruedPerUnit = compInitialAccruedPerUnit;
        }
        uint deltaAccruedPerUnit = supplyAccruedPerUnit - supplierAccruedPerUnit;
        uint supplierTokens = Token(cToken).balanceOf(supplier);
        uint supplierDelta = supplierTokens * deltaAccruedPerUnit;
        compAccrued[supplier] = compAccrued[supplier] + supplierDelta;
    }
    /*-----------------------------------snip-------------------------------------*/
    function claimComp(address[] memory holders, CToken[] memory cTokens) public {
        for (uint i = 0; i < cTokens.length; i++) {
            Token cToken = cTokens[i];
            require(markets[address(cToken)].isListed, "market must be listed");
            updateCompBorrowAccrued(address(cToken));
            updateCompSupplyAccrued(address(cToken));
            for (uint j = 0; j < holders.length; j++) {
                distributeBorrowerComp(address(cToken), holders[j]);
                distributeSupplierComp(address(cToken), holders[j]);
            }
        }
        for (uint j = 0; j < holders.length; j++) {
            compAccrued[holders[j]] = grantCompInternal(holders[j], compAccrued[holders[j]]);
        }
    }
    function grantCompInternal(address user, uint amount) internal returns (uint) {
        if (amount > 0 && amount <= COMP.balanceOf(address(this))) {
            COMP.transfer(user, amount);
            return 0;
        }
        return amount;
    }
    /*-----------------------------------snip-------------------------------------*/
    /*---------------------------------new code-----------------------------------*/
    function _initializeMarket(address cToken) internal {
        CompMarketState storage supplyState = compSupplyState[cToken];
        CompMarketState storage borrowState = compBorrowState[cToken];
        if (supplyState.compAccruedPerUnit == 0) {
            // Initialize supply state compAccruedPerUnit with default value
            supplyState.compAccruedPerUnit = compInitialAccruedPerUnit;
        }
        if (borrowState.compAccruedPerUnit == 0) {
            // Initialize borrow state compAccruedPerUnit with default value
            borrowState.compAccruedPerUnit = compInitialAccruedPerUnit;
        }
         supplyState.block = borrowState.block = block.number;
    }
}
