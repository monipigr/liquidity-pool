## 💧 LiquidityPool

## 📝 Overview

**LiquidityPool** is a secure and composable smart contract that enables users to swap tokens and manage liquidity with USDT and DAI tokens in the Arbitrum network with UniswapV2 protocol. The contract exposes safe interfaces for token swaps, liquidity provision, and liquidity removal, handling ERC-20 approvals and transfers internally. Built with OpenZeppelin’s `SafeERC20` and tested using Foundry, it is designed for reliability and ease of integration.

## ✨ Features

- 🔁 **Token Swapping:** Swap USDT/DAI tokens using Uniswap V2’s router with custom parameters.
- 💦 **Add Liquidity**: Seamlessly provide liquidity to the USDT/DAI pool, including internal swap and optimal approvals.
- 💧 **Remove Liquidity**: Withdraw liquidity from the pool and receive underlying tokens.
  -🛡️ **Safe Transfers**: Utilizes OpenZeppelin’s SafeERC20 for secure token operations.
  -📢 **Event Emission**: Emits SwapTokens and AddLiquidity events for transparency and integration.

## 🧩 Smart Contract Architecture and Patterns

- **Design**: Stateless contract interacting with Uniswap V2 router and factory via custom interfaces.
- **Events**:
  - `SwapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut)`
  - `AddLiquidity(address token0, address token1, uint256 lpTokenAmount)`
- **Libraries**:
  - OpenZeppelin `SafeERC20` and `IERC20` for safe token handling.
- **Patterns**:
  - CEI (Checks-Effects-Interactions)
  - No persistent storage except for router, factory, and token addresses.
- **Security Practices**:
  - All token transfers and approvals use `safeTransferFrom` and `approve`.
  - No unlimited approvals, minimizing risk.

## 🛠 Technologies Used

- **Solidity**: `^0.8.24`
- **Smart Contract Tools**: [Foundry](https://book.getfoundry.sh/)
- **Libraries**:
  - OpenZeppelin `SafeERC20`, `IERC20`
  - Custom interfaces: `IV2Router02`, `IFactory`

## 🧪 Testing

The contract is thoroughly tested using Foundry on a forked Arbitrum mainnet. Real token addresses (USDT, DAI) and Uniswap router/factory addresses are used to simulate actual swaps and liquidity operations.

| Test Function                     | Purpose                                                        |
| --------------------------------- | -------------------------------------------------------------- |
| `testHasBeenDeployedCorrectly`    | Asserts correct initialization of router and factory addresses |
| `testSwapTokensCorrectly`         | Validates token swap between USDT and DAI                      |
| `testCanAddLiquidityCorrectly`    | Ensures liquidity can be added to the USDT/DAI pool            |
| `testCanRemoveLiquidityCorrectly` | Ensures liquidity can be removed and tokens returned           |

## 💻 How to Run the Project Locally

### Prerequisites

- Install [Foundry](https://book.getfoundry.sh/)

### Setup

```bash
git clone https://github.com/your-username/liquidity-pool.git
cd swap-app
forge install
```

### Testing

```bash
forge test --fork-url https://arb1.arbitrum.io/rpc -vvvv
```

## 📜 License

This project is licensed under the MIT License.
