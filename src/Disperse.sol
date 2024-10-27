// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Disperse  {
    error NO_RECIPIENTS();
    error NO_ETH_SENT();
    error NO_TOKENS_SENT();
    error TRANSFER_FAILED();
    error INSUFFICIENT_BALANCE();
    error INSUFFICIENT_ALLOWANCE();

    // Function to disperse ETH euqally among recipients
    function disperseEth(address[] calldata recipients) external payable {
        uint256 length = recipients.length;
        if (length == 0) revert NO_RECIPIENTS();
        if (msg.value == 0) revert NO_ETH_SENT();

        unchecked {
            uint256 amountPerRecipient = msg.value / length;

            for (uint256 i = 0; i < length;) {
                (bool success, ) = recipients[i].call{value: amountPerRecipient}("");
                if (!success) revert TRANSFER_FAILED();

                // Unchecked increment.
                ++i;
            }
        }
    }

    // Function to disperse tokens equally among recipients.
    function disperseTokens(
        address tokenAddress,
        address[] calldata recipients,
        uint256 amount
    ) external {
        uint256 length = recipients.length;
        if (length == 0) revert NO_RECIPIENTS();
        if (amount == 0) revert NO_TOKENS_SENT();

        IERC20 token = IERC20(tokenAddress);

        unchecked {
            // Validate sender's balance and allowance
            if (token.balanceOf(msg.sender) < amount) revert INSUFFICIENT_BALANCE();
            if (token.allowance(msg.sender, address(this)) < amount) revert INSUFFICIENT_ALLOWANCE();

            uint256 amountPerRecipient = amount / length;

            for (uint256 i = 0; i < length;) {
                bool success = token.transferFrom(msg.sender, recipients[i], amountPerRecipient);
                if (!success) revert TRANSFER_FAILED();

                // Unchecked increment.
                ++i;
            }
        }
    }
}