// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../../src/uniswapv1/Exchange.sol";
import "../../src/uniswapv1/Token.sol";

contract ExchangeV1Test is Test {
    Exchange public exchange;
    Token public token;
    address public alice;
    address public bob;

    function setUp() public {
        token = new Token("Dai", "DAI", 1000000 ether);
        exchange = new Exchange(address(token));

        alice = vm.addr(1);
        bob = vm.addr(2);

        // send tokens to address
        token.transfer(bob, 1 ether);
        token.transfer(alice, 1 ether);

        // send eth to address
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function testExchangeDeployment() public {
        assertEq(exchange.name(), "MuniV1");
        assertEq(exchange.symbol(), "MUNIV1");
        assertEq(exchange.totalSupply(), 0);
    }

    function testAddLiquidityNoReserves() public {
        vm.startPrank(alice);
        token.approve(address(exchange), 200 wei);
        exchange.addLiquidity{value: 100 wei}(200 wei);
        vm.stopPrank();

        // added liquidity checks
        assertEq(address(exchange).balance, 100 wei);
        assertEq(exchange.getReserve(), 200 wei);

        // lp tokens minted check
        assertEq(exchange.balanceOf(alice), 100);
        assertEq(exchange.totalSupply(), 100);

        // uint256 tokenReserve = exchange.getReserve();
        // uint256 etherReserve = address(exchange).balance;

        // // Eth for token
        // assertEq(exchange.getTokenAmount(1), 180);
        // assertEq(exchange.getTokenAmount(100), 1816);
        // assertEq(exchange.getTokenAmount(1000), 1980);

        // // token for eth
        // assertEq(exchange.getEthAmount(2), 0);
        // assertEq(exchange.getEthAmount(100), 0);
        // assertEq(exchange.getEthAmount(2000), 4);
        // assertEq(exchange.getEthAmount(4000), 6);
    }

    function testAddLiquidityWithReserves() public {
        vm.startPrank(alice);
        token.approve(address(exchange), 200 wei);
        exchange.addLiquidity{value: 100 wei}(200 wei);
        vm.stopPrank();

        // liquidity check for alice
        assertEq(exchange.balanceOf(alice), 100);

        // additional liquidity
        vm.startPrank(bob);
        token.approve(address(exchange), 200 wei);
        exchange.addLiquidity{value: 50}(200);

        // preserves exchange rate check
        assertEq(address(exchange).balance, 150);
        assertEq(exchange.getReserve(), 300);

        // liquidity token mint checks
        // bob's liquidity should be 50
        assertEq(exchange.balanceOf(bob), 50);
        // alice's liquidity should remain same
        assertEq(exchange.balanceOf(alice), 100);
        assertEq(exchange.totalSupply(), 150);

        // fails if token amount doesn't match reserves ratio
        vm.expectRevert("insufficient token amount");
        exchange.addLiquidity{value: 50}(50);
    }

    // function testAll() public {
    //     vm.deal(alice, 1 ether);

    //     token.approve(address(exchange), 200);

    //     // add liquidity 100 eth * 200 token = 20_000
    //     exchange.addLiquidity{value: 100}(200);

    //     vm.startPrank(alice);
    //     token.approve(address(exchange), 200);
    //     // swap 10 eth for token, expecting ~18 tokens
    //     exchange.ethToTokenSwap{value: 10}(18);

    //     vm.stopPrank();

    //     // remove lidiquity
    //     exchange.removeLiquidity(100);
    // }
}
