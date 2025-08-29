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


    /**
     * @notice Test that swapTokens functionality works correctly 
     */
    function testSwapTokensCorrectly() public {
        vm.startPrank(user);
        uint256 amountIn = 5 * 1e6; //  1e6 decimal numbers of usdt token in arbitrum network
        IERC20(USDT).approve(address(app), amountIn); 
        
        uint256 amountOutMin = 1 * 1e18; // 1e18 decimal numbers of dai token in arbitrum network
        uint256 deadline = 1747815058 + 1000000000;
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = DAI;

        uint256 usdtBalanceBefore = IERC20(USDT).balanceOf(user); 
        uint256 daiBalanceBefore = IERC20(DAI).balanceOf(user);
        app.swapTokens(amountIn, amountOutMin, path, user, deadline); 
        uint256 usdtBalanceAfter = IERC20(USDT).balanceOf(user);
        uint256 daiBalanceAfter = IERC20(DAI).balanceOf(user);

        assert(usdtBalanceAfter == usdtBalanceBefore - amountIn);
        assert(daiBalanceAfter > daiBalanceBefore);
        vm.stopPrank();
    }


    /**
     * @notice Check if liquidity can be added correctly
     */
    function testCanAddLiquidityCorrectly() public {
        vm.startPrank(user);
        uint256 amountIn_ = 6 * 1e6; 
        uint256 amountOutMin_ = 1 * 1e18;
        address[] memory path_ = new address[](2);
        path_[0] = USDT; 
        path_[1] = DAI;
        uint256 amountAMin_ = 0; 
        uint256 amountBMin_ = 0;  
        uint256 deadline_ = 1747815058 + 1000000000;        

        IERC20(USDT).approve(address(app), amountIn_);
        app.addLiquidity(amountIn_, amountOutMin_, path_, amountAMin_, amountBMin_, deadline_);

        vm.stopPrank();
    }

    /**
     * @notice Check if liquidity can be removed correctly
     */
    function testCanRemoveLiquidityCorrectly() public {
        vm.startPrank(user);
        
        // Adding liquidity first
        uint256 amountIn_ = 6 * 1e6; 
        uint256 amountOutMin_ = 2 * 1e18;
        address[] memory path_ = new address[](2);
        path_[0] = USDT;
        path_[1] = DAI;
        uint256 amountAMin_ = 0; 
        uint256 amountBMin_ = 0; 
        uint256 deadline_ = 1747815058 + 1000000000;        

        IERC20(USDT).approve(address(app), amountIn_);
        app.addLiquidity(amountIn_, amountOutMin_, path_, amountAMin_, amountBMin_, deadline_);

        // Getting the LP token address
        address lpTokenAddress = IFactory(uniswapV2FactoryAddress).getPair(USDT, DAI);
        
        uint256 lpTokenBalance = IERC20(lpTokenAddress).balanceOf(user);
        assertGt(lpTokenBalance, 0, "Usuario debe tener LP tokens");
        
        // Saving initial balances of USDT and DAI for later comparison
        uint256 initialUSDTBalance = IERC20(USDT).balanceOf(user);
        uint256 initialDAIBalance = IERC20(DAI).balanceOf(user);
        
        // Transfering LP tokens to the contract
        IERC20(lpTokenAddress).transfer(address(app), lpTokenBalance);
        
        // Removing liquidity
        uint256 liquidityAmount_ = lpTokenBalance; // Remover toda la liquidez
        uint256 amountAMinRemove_ = 0; 
        uint256 amountBMinRemove_ = 0; 
        address to_ = user; 
        uint256 deadlineRemove_ = 1747815058 + 1000000000;
        
        app.removeLiquidity(liquidityAmount_, amountAMinRemove_, amountBMinRemove_, to_, deadlineRemove_);
        
        uint256 finalLpTokenBalance = IERC20(lpTokenAddress).balanceOf(user);
        assertEq(finalLpTokenBalance, 0, "Usuario no tiene LP tokens despues de remover liquidez");
        
        uint256 finalUSDTBalance = IERC20(USDT).balanceOf(user);
        uint256 finalDAIBalance = IERC20(DAI).balanceOf(user);
        
        assertGt(finalUSDTBalance, initialUSDTBalance, "Usuario recibe USDT de vuelta");
        assertGt(finalDAIBalance, initialDAIBalance, "Usuario recibe DAI de vuelta");
        
        vm.stopPrank();
    }
    
}
