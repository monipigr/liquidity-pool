// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IV2Router02.sol";
import "./interfaces/IFactory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract LiquidityPool {
    using SafeERC20 for IERC20; 

    address public immutable V2Router02Address;
    address public immutable UniswapFactoryAddress; //para coger la address del pool con getPair
    address public USDT;
    address public DAI;
    event SwapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut); 
    event AddLiquidity(address token0, address token1, uint256 lpTokenAmount);
    
    constructor(address V2Router02Address_, address UniswapFactoryAddress_, address USDT_, address DAI_) {
        V2Router02Address = V2Router02Address_;
        UniswapFactoryAddress = UniswapFactoryAddress_;
        USDT = USDT_;
        DAI = DAI_;
    } 

    /**
     * @notice Functions to swap tokens via Uniswap V2
     * @dev swapExactTokensForTokens returns uint[] memory amounts - amounts of both inputs and outputs
     * @param amountIn_ Amount of input tokens to send. The exact amount of tokens we will send to the swap.
     * @param amountOutMin_ Minimum amount of output tokens that must be received for the transaction to not revert.
     * @param path_ Array of token addresses representing the swap path (number of hops required)
     * @param to_ Which wallet will receive the tokens, the recipient of the swap result
     * @param deadline_ Maximum unix timestamp we allow for our transaction to be executed
     * @return uint256 - Amount of output tokens received from the swap
     */  
    function swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, address to_, uint256 deadline_) public returns(uint256) {
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);

        IERC20(path_[0]).approve(V2Router02Address, amountIn_);

        uint256[] memory amountsOuts =  IV2Router02(V2Router02Address).swapExactTokensForTokens(amountIn_, amountOutMin_, path_, to_, deadline_);

        emit SwapTokens(path_[0], path_[path_.length - 1], amountIn_, amountsOuts[amountsOuts.length - 1]);

        return amountsOuts[amountsOuts.length - 1];
    }

    /**
     * @notice Function to add liquidity to the USDT/DAI pool
     * @dev We will first swap half of the tokens sent to DAI and then add liquidity with both tokens
     * @param amountIn_ Amount of USDT tokens to send. The exact amount of tokens we will send to the swap.
     * @param amountOutMin_ Minimum amount of DAI tokens that must be received for the transaction to not revert.
     * @param path_ Array of token addresses representing the swap path (number of hops required)
     * @param amountAMin_ Minimum amount of USDT to add to the liquidity pool (slippage protection)
     * @param amountBMin_ Minimum amount of DAI to add to the liquidity pool (slippage protection)
     * @param deadline_ Maximum unix timestamp we allow for our transaction to be executed
     */
    function addLiquidity(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 amountAMin_, uint256 amountBMin_, uint deadline_) external {
        IERC20(USDT).safeTransferFrom(msg.sender, address(this), amountIn_ / 2); //Sólo transferimos la mitad de USDT??? 
        uint256 swappedAmount = swapTokens(amountIn_ / 2, amountOutMin_, path_, address(this), deadline_);

        IERC20(USDT).approve(V2Router02Address, amountIn_ / 2);
        IERC20(DAI).approve(V2Router02Address, swappedAmount);
        (,,uint256 lpTokenAmount) = IV2Router02(V2Router02Address).addLiquidity(USDT, DAI, amountIn_ / 2, swappedAmount, amountAMin_, amountBMin_, msg.sender, deadline_);

        emit AddLiquidity(USDT, DAI, lpTokenAmount);
    }

    /**
     * @notice Function to remove liquidity from the USDT/DAI pool
     * @dev We need to get the address of the pool with getPair and approve the router to take our LPTokens
     * @param liquidityAmount_ Amount of liquidity tokens to remove from the pool
     * @param amountAMin_ Minimum amount of USDT to receive (slippage protection)
     * @param amountBMin_ Minimum amount of DAI to receive (slippage protection)
     * @param to_ Which wallet will receive the tokens, the recipient of the liquidity removal
     * @param deadline_ Maximum unix timestamp we allow for our transaction to be executed
     */
    function removeLiquidity(uint256 liquidityAmount_, uint256 amountAMin_, uint256 amountBMin_, address to_, uint256 deadline_) external {
        address lpTokenAddress = IFactory(UniswapFactoryAddress).getPair(USDT, DAI);

        IERC20(lpTokenAddress).approve(V2Router02Address, liquidityAmount_);
        IV2Router02(V2Router02Address).removeLiquidity(USDT, DAI, liquidityAmount_, amountAMin_, amountBMin_, to_, deadline_);
    }
}
