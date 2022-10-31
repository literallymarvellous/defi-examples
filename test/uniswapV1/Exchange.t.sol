// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../../src/uniswapv1/Exchange.sol";
import "../../src/uniswapv1/Token.sol";

contract UniswapV1Test is Test {
    Exchange public exchange;
    Token public token;
    address public alice;

    function setUp() public {
        token = new Token("Dai", "DAI", 1000000 ether);
        exchange = new Exchange(address(token));
        alice = vm.addr(1);
        token.transfer(alice, 1 ether);
    }

    function testAddLiquidity() public {
        token.approve(address(exchange), 2000 wei);
        exchange.addLiquidity{value: 10 wei}(2000 wei);

        assertEq(address(exchange).balance, 10 wei);
        assertEq(exchange.getReserve(), 2000 wei);

        uint256 tokenReserve = exchange.getReserve();
        uint256 etherReserve = address(exchange).balance;

        // Eth for token
        assertEq(exchange.getTokenAmount(1), 180);
        assertEq(exchange.getTokenAmount(100), 1816);
        assertEq(exchange.getTokenAmount(1000), 1980);

        // token for eth
        assertEq(exchange.getEthAmount(2), 0);
        assertEq(exchange.getEthAmount(100), 0);
        assertEq(exchange.getEthAmount(2000), 4);
        assertEq(exchange.getEthAmount(4000), 6);
    }

    function testAll() public {
        vm.deal(alice, 1 ether);

        token.approve(address(exchange), 200);

        // add liquidity 100 eth * 200 token = 20_000
        exchange.addLiquidity{value: 100}(200);

        vm.startPrank(alice);
        token.approve(address(exchange), 200);
        // swap 10 eth for token, expecting ~18 tokens
        exchange.ethToTokenSwap{value: 10}(18);

        vm.stopPrank();

        // remove lidiquity
        exchange.removeLiquidity(100);
    }

    receive() external payable {}
}
