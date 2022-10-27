// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title A ontract for Delphya Prediction Tokens

contract DPT is ERC20 {
    constructor() ERC20("Delphya Prediction Token", "DPT") {}

    function faucet(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}
