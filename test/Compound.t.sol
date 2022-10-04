// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/CompoundERC20.sol";
import "../src/interfaces/Compound.sol";

contract CompoundTest is Test {
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;

    address public WBTC_WHALE;
    address public DAI_WHALE;

    address public WETH_10 = 0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9F;

    // compound
    address public CDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address public CUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address public CWBTC = 0xccF4429DB6322D5C611ee964527D42E5d685DD6a;
    address public CETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;

    address public CWBTCG = 0x6CE27497A64fFFb5517AA4aeE908b1E7EB63B9fF;
    address public WBTCG = 0xC04B0d3107736C32e19F1c62b2aF67BE61d63a05;

    IERC20 public token;
    CErc20 public cToken;
    CompoundERC20 public comp;

    uint256 deposit = 100000000;
    address public wbtcholder;

    // string GOERLI_RPC_URL = vm.envString("GOERLI_RPC_URL");

    function setUp() public {
        comp = new CompoundERC20(WBTCG, CWBTCG);
        token = IERC20(WBTCG);
        cToken = CErc20(CWBTCG);

        wbtcholder = vm.addr(
            0xe2d0e9561848b56f89253fa63e244fcb825e0520f7486119e06e1bb9549dd10c
        );

        vm.label(address(this), "sender");
        vm.label(wbtcholder, "wbtcholder");

        console2.log("token balance", token.balanceOf(wbtcholder));
    }

    function testSupplyAndRedeem() public {
        vm.startPrank(wbtcholder);
        token.approve(address(comp), deposit);
        uint256 result = comp.supply(deposit);
        vm.stopPrank();

        assert(result == 0);

        console2.log("-- supply --");

        console2.log("token balance", token.balanceOf(address(comp)));
        console2.log("ctoken balance", cToken.balanceOf(address(comp)));
        console2.log("estimateBalance", comp.estimateBalanceOfUnderlying());
        console2.log("balanceOfUnderlying", comp.balanceOfUnderlying());

        (uint256 exchangeRate, uint256 supplyRate) = comp.getInfo();
        console2.log("exchangeRate", exchangeRate);
        console2.log("supplyRateBerBlock", supplyRate);

        console2.log("block time", block.timestamp);

        skip(1000);

        console2.log("-- after block skip --");

        console2.log("block time", block.timestamp);

        console2.log("balanceOfUnderlying", comp.balanceOfUnderlying());

        uint256 cTokenAmount = cToken.balanceOf(address(comp));
        vm.startPrank(wbtcholder);
        uint256 res = comp.redeem(cTokenAmount);

        console2.log("result", res);

        console2.log("-- redeem --- ");

        console2.log("balanceOfUnderlying", comp.balanceOfUnderlying());
        console2.log("token balance", token.balanceOf(address(comp)));
        console2.log("ctoken balance", cToken.balanceOf(address(comp)));
    }

    function testRedeem() public {}
}
