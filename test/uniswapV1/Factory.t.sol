// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../../src/uniswapv1/Exchange.sol";
import "../../src/uniswapv1/Token.sol";
import "../../src/uniswapv1/Factory.sol";

contract FactoryV1Test is Test {
    Factory public factory;
    Token public token;
    address public alice;

    function setUp() public {
        token = new Token("Dai", "DAI", 1000000 ether);
        factory = new Factory();
    }

    function testcreateExchange() public {
        address exchange = factory.createExchange(address(token));

        assertEq(factory.tokenToExchange(address(token)), exchange);

        assertEq(factory.getExchange(address(token)), exchange);
    }

    function testZeroAddressFails() public {
        vm.expectRevert("invalid token address");
        address exchange = factory.createExchange(address(0));
    }

    function testExistingExchangeFails() public {
        address exchange = factory.createExchange(address(token));

        vm.expectRevert("exchange already exists");
        factory.createExchange(address(token));
    }
}
