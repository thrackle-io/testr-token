import "@fortefoundation/forte-rules-engine/src/client/RulesEngineClient.sol";

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

/**
 * @title Template Contract for Testing the Rules Engine
 * @author @mpetersoCode55, @ShaneDuncan602, @TJ-Everett, @VoR0220
 * @dev This file serves as a template for dynamically injecting custom Solidity modifiers into smart contracts.
 *              It defines an abstract contract that extends the RulesEngineClient contract, providing a placeholder
 *              for modifiers that are generated and injected programmatically.
 */
abstract contract RulesEngineClientCustom is RulesEngineClient {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    function setCallingContractAdmin(
        address callingContractAdmin
    ) public override onlyOwner {
        super.setCallingContractAdmin(callingContractAdmin);
    }

    modifier checkRulesBeforeTransfer(
        address to,
        uint256 value,
        uint256 senderBalance,
        address sender
    ) {
        bytes memory encoded = abi.encodeWithSelector(
            msg.sig,
            to,
            value,
            senderBalance,
            sender
        );
        _invokeRulesEngine(encoded);
        _;
    }

    modifier checkRulesAfterTransfer(address to, uint256 value) {
        bytes memory encoded = abi.encodeWithSelector(msg.sig, to, value);
        _;
        _invokeRulesEngine(encoded);
    }

    modifier checkRulesBeforeApprove(address to, uint256 value) {
        bytes memory encoded = abi.encodeWithSelector(msg.sig, to, value);
        _invokeRulesEngine(encoded);
        _;
    }

    modifier checkRulesAfterApprove(address to, uint256 value) {
        bytes memory encoded = abi.encodeWithSelector(msg.sig, to, value);
        _;
        _invokeRulesEngine(encoded);
    }

    modifier checkRulesBeforeTransferFrom(
        address from,
        address to,
        uint256 value,
        uint256 fromBalance
    ) {
        bytes memory encoded = abi.encodeWithSelector(
            msg.sig,
            from,
            to,
            value,
            fromBalance
        );
        _invokeRulesEngine(encoded);
        _;
    }

    modifier checkRulesAfterTransferFrom(
        address from,
        address to,
        uint256 value
    ) {
        bytes memory encoded = abi.encodeWithSelector(msg.sig, from, to, value);
        _;
        _invokeRulesEngine(encoded);
    }
}
