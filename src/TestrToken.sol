// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/RulesEngineIntegration.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TestrToken is RulesEngineClientCustom, ERC20, AccessControl {
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    constructor(address _tokenAdmin) ERC20("Testr Token", "$TSTR") {
        _grantRole(TOKEN_ADMIN_ROLE, _tokenAdmin);
        _setRoleAdmin(TOKEN_ADMIN_ROLE, TOKEN_ADMIN_ROLE);
    }

    function mint(
        address to,
        uint256 amount
    ) public onlyRole(TOKEN_ADMIN_ROLE) {
        _mint(to, amount);
    }

    function transfer(
        address to,
        uint256 value
    )
        public
        override
        checkRulesBeforeTransfer(to, value, balanceOf(msg.sender), msg.sender)
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function approve(
        address spender,
        uint256 value
    ) public override checkRulesBeforeApprove(spender, value) returns (bool) {
        return super.approve(spender, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        checkRulesBeforeTransferFrom(from, to, value)
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }
}
