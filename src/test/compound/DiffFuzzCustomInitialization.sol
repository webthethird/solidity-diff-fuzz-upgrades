// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.10;

import "./DiffFuzzUpgrades.sol";
import "../../implementation/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../../implementation/compound/master-contracts/WhitePaperInterestRateModel.sol";

contract DiffFuzzCustomInitialization is DiffFuzzUpgrades {

    constructor() DiffFuzzUpgrades() public {
        // Below is custom, not auto-generated
        compV1 = IComp(address(new Comp(address(unitrollerV1))));
        compV2 = IComp(address(new Comp(address(unitrollerV2))));

        ERC20PresetFixedSupply underlyingV1 = new ERC20PresetFixedSupply("UnderlyingV1", "UV1", 10e18, address(this));
        ERC20PresetFixedSupply underlyingV2 = new ERC20PresetFixedSupply("UnderlyingV2", "UV2", 10e18, address(this));
        InterestRateModel interestModel = new WhitePaperInterestRateModel(0, 5e16);

        hevm.prank(cErc20V1.admin());
        cErc20V1.initialize(
            address(underlyingV1),
            address(comptrollerV1),
            address(interestModel),
            0.02e28,
            "cTokenV1",
            "CV1",
            8
        );
        hevm.prank(cErc20V2.admin());
        cErc20V2.initialize(
            address(underlyingV2),
            address(comptrollerV2),
            address(interestModel),
            0.02e28,
            "cTokenV2",
            "CV2",
            8
        );
    }
}
