pragma solidity ^0.6.6;

import './UniswapV2Library.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Router.sol';
import './interfaces/IERC20.sol';
//defining vairables like factory of Uniswap 4 info about liq. pools 
//and pointer to sushi router to exec trade in sushiswap liq poolz 
contract MohamArbitrage {
    address public factory;
    uint constant deadline = 10 days;
    IUniswapV2Router public sushiRouter;
//init the value of the uniswap factory and sushi router
    constructor(address _factory, address sushiRouter) public {
        factory = _factory;
        sushiRouter = IUniswapRouter02(_sushiRouter)'        
    }
    //here i start the arbritrage funct, so the trader can execute it, its up to trader to monitor price diff
    //args are address of the 2 tokenz we want to borrow
    function startArbitrage(
        address token0,
        address token1,
        uint amount0,
        uint amount1,        
    )   external {
        address pairAddress = IUniswapV2Factory(factory).getPair(token0, token1);
        require(pairAddress != address(0), 'This pool dont exist fool!);
        IUniswapV2Pair(pairAddress).swap(
            amount0,
            amount1,
            address(this),
            bytes('not empty')
        );
    }

    function uniswapV2Call(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
    )   external {
        address[] memory path = new address[](2);
        uint amountToken = _amount0 == 0 ? _amount1 : _amount0;

        address token0 = IUniswapV2Pair(msg.sender).token0;
        address token1 = IUniswapV2Pair(msg.sender).token1;
        require(
            msg.sender == UniswapV2Library.pairFor(factory, token0, token1),
            'Unauthorized'
        );
        require(_amount0 == || _amount1 == 0);
        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;
        IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);

        token.approve(address(sushiRouter), amountToken);
        uint amountRequired == UniswapV2Library.getAmountsIn(
            factory,
            amountToken,
            path
        )   [0];
        uint amountReceived = sushiRouter.swapExactTokensForTokens(
            amountToken,
            amountRequired,
            path,
            msg.sender,
            deadline
        )   [1];
        token.transfer(tx.origin, amountReceieved - amountRequired);
    }
}