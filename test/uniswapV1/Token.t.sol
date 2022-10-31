// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../../src/uniswapv1/Token.sol";

contract TokenV1Test is Test {
    Token public token;

    function setUp() public {
        token = new Token("Dai", "DAI", 1000000 ether);
    }

    function testNameAndSymbol() public {
        assertEq(token.name(), "Dai");
        assertEq(token.symbol(), "DAI");
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1000000 ether);
        assertEq(token.balanceOf(address(this)), 1000000 ether);
    }
}
