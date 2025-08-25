// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../lib/forge-std/src/Test.sol";
import "../src/LiquidityPool.sol";

contract LiquidityPoolTest is Test {
    LiquidityPool app;
    address uniswapV2SwappRouterAddress = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address uniswapV2FactoryAddress = 0xf1D7CC64Fb4452F05c498126312eBE29f30Fbcf9;
    address user = 0xBA12222222228d8Ba445958a75a0704d566BF2C8; // Balancer Vault 
    address USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9; // USDT address in Arbitrum mainnet
    address DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1; // DAI address in Arbitrum mainnet

    /**
     * @notice Deploy the LiquidityPool contract before each test
     */
    function setUp() public {
        app = new LiquidityPool(uniswapV2SwappRouterAddress, uniswapV2FactoryAddress, USDT, DAI);
    }

    /**
     * @notice Check if contract has been correctly deployed
     */
    function testHasBeenDeployedCorrectly() public view {
        assert(app.V2Router02Address() == uniswapV2SwappRouterAddress);
    }

}
