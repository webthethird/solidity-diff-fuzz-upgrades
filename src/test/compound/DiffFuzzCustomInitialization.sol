// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.10;

import "./DiffFuzzUpgrades.sol";
import "../../implementation/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../implementation/@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../../implementation/compound/master-contracts/WhitePaperInterestRateModel.sol";


contract DiffFuzzCustomInitialization is DiffFuzzUpgrades {

    constructor() DiffFuzzUpgrades() public {
        // Below is custom, not auto-generated
        compV1 = IComp(address(new Comp(address(unitrollerV1))));
        compV2 = IComp(address(new Comp(address(unitrollerV2))));
        IComptrollerV1(address(unitrollerV1)).setCompAddress(address(compV1));
        IComptrollerV2(address(unitrollerV2)).setCompAddress(address(compV2));

        ERC20PresetFixedSupply underlyingV1 = new ERC20PresetFixedSupply("UnderlyingV1", "UV1", 10e18, address(msg.sender));
        ERC20PresetFixedSupply underlyingV2 = new ERC20PresetFixedSupply("UnderlyingV2", "UV2", 10e18, address(msg.sender));
        InterestRateModel interestModel = new WhitePaperInterestRateModel(0, 5e16);

        hevm.prank(cErc20V1.admin());
        cErc20V1.initialize(
            address(underlyingV1),
            address(unitrollerV1),
            address(interestModel),
            0.02e28,
            "cTokenV1",
            "CV1",
            8
        );
        hevm.prank(cErc20V1.admin());
        cErc20V1._setReserveFactor(0.15e18);
        hevm.prank(cErc20V2.admin());
        cErc20V2.initialize(
            address(underlyingV2),
            address(unitrollerV2),
            address(interestModel),
            0.02e28,
            "cTokenV2",
            "CV2",
            8
        );
        hevm.prank(cErc20V2.admin());
        cErc20V2._setReserveFactor(0.15e18);
        // Allowances
        hevm.prank(msg.sender);
        underlyingV1.approve(
            address(cErc20V1),
            type(uint256).max
        );
        hevm.prank(msg.sender);
        underlyingV2.approve(
            address(cErc20V2),
            type(uint256).max
        );
        // Support markets
        IComptrollerV1(address(unitrollerV1))._supportMarket(address(cErc20V1));
        IComptrollerV2(address(unitrollerV2))._supportMarket(address(cErc20V2));
        // Enter markets
        address[] memory marketsV1 = new address[](1);
        marketsV1[0] = address(cErc20V1);
        hevm.prank(msg.sender);
        IComptrollerV1(address(unitrollerV1)).enterMarkets(marketsV1);
        address[] memory marketsV2 = new address[](1);
        marketsV2[0] = address(cErc20V2);
        hevm.prank(msg.sender);
        IComptrollerV2(address(unitrollerV2)).enterMarkets(marketsV2);
    }

    function CErc20_approve_underlying() public {
        ERC20 underlyingV1 = ERC20(cErc20V1.underlying());
        ERC20 underlyingV2 = ERC20(cErc20V2.underlying());
        require(underlyingV1.balanceOf(msg.sender) > 0 && underlyingV2.balanceOf(msg.sender) > 0);
        // Allowances
        hevm.prank(msg.sender);
        underlyingV1.approve(
            address(cErc20V1),
            type(uint256).max
        );
        hevm.prank(msg.sender);
        underlyingV2.approve(
            address(cErc20V2),
            type(uint256).max
        );
    }

    function upgradeV2() external override {
        unitrollerV2._setPendingImplementation(address(comptrollerV2));
        comptrollerV2._become(address(unitrollerV2));
        IComptrollerV2(address(unitrollerV2)).setCompAddress(address(compV2));
    }

    function Comptroller__supportMarket(address a) public override {
        bool listedV1 = IComptrollerV1(address(unitrollerV1)).markets(a).isListed;
        bool listedV2 = IComptrollerV2(address(unitrollerV2)).markets(a).isListed;
        require(!listedV1 && !listedV2);
        super.Comptroller__supportMarket(a);
    }

    function Comptroller_claimComp() public {
        address[] memory marketsV1 = IComptrollerV1(address(unitrollerV1)).getAssetsIn(msg.sender);
        address[] memory marketsV2 = IComptrollerV2(address(unitrollerV2)).getAssetsIn(msg.sender);
        require(marketsV1.length > 0 && marketsV2.length > 0);
        super.Comptroller_claimComp(msg.sender);
    }

    function Comptroller__setCompSpeeds(uint8 a, uint32 b) public {
        require(b > 0);
        address _a1 = address(cErc20V1);
        address _a2 = address(cErc20V2);
        address[] memory a2 = new address[](1);
        a2[0] = _a2;
        uint256[] memory b2 = new uint256[](1);
        uint256[] memory c2 = new uint256[](1);
        b2[0] = c2[0] = b;

        bool success2;
        bytes memory output2;
        if(unitrollerV2.comptrollerImplementation() == address(comptrollerV2)) {
            (success2, output2) = address(unitrollerV2).call(
                abi.encodeWithSelector(
                    comptrollerV2._setCompSpeeds.selector, a2, b2, c2
                )
            );
        } else {
            (success2, output2) = address(unitrollerV2).call(
            abi.encodeWithSelector(
                comptrollerV1._setCompSpeed.selector, _a2, b
            )
        );
        }
        (bool success1, bytes memory output1) = address(unitrollerV1).call(
            abi.encodeWithSelector(
                comptrollerV1._setCompSpeed.selector, _a1, b
            )
        );
        assert(success1 == success2);
        assert((!success1 && !success2) || keccak256(output1) == keccak256(output2));
    }

    function CErc20_mint(uint256 a) public override {
        require(a > 0);
        ERC20 underlyingV1 = ERC20(cErc20V1.underlying());
        ERC20 underlyingV2 = ERC20(cErc20V2.underlying());
        require(underlyingV1.balanceOf(msg.sender) > 0 && underlyingV2.balanceOf(msg.sender) > 0);
        super.CErc20_mint(a);
    }
}
