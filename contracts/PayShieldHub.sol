// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title PayShieldHub — Confirmation of Payee escrow for tUSD8 on QDay Aevum testnet
/// @notice A payer locks tUSD8 in escrow for a named recipient. The recipient claims it;
///         the payer can refund any time before the claim; after EXPIRY the payer can
///         reclaim. One clear flow, no admin, no fees, no unlimited approvals.
/// @dev tUSD8 is 6 decimals. Amounts are raw token units. Testnet only.
contract PayShieldHub is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    uint256 public nextPaymentId;

    /// @notice Payments expire after 7 days; after that the payer may reclaim.
    uint256 public constant EXPIRY = 7 days;

    enum Status {
        Pending,
        Claimed,
        Refunded
    }

    struct Payment {
        address payer;
        address recipient;
        uint256 amount;
        string memo;
        uint256 createdAt;
        Status status;
    }

    mapping(uint256 => Payment) public payments;

    event PaymentCreated(
        uint256 indexed id,
        address indexed payer,
        address indexed recipient,
        uint256 amount,
        string memo
    );
    event PaymentClaimed(uint256 indexed id, address indexed recipient, uint256 amount);
    event PaymentRefunded(uint256 indexed id, address indexed payer, uint256 amount);

    error ZeroAddress();
    error ZeroAmount();
    error NotRecipient();
    error NotPayer();
    error NotPending();

    /// @param _token tUSD8 on Aevum: 0x456569838f1d43009A91ebA4263147Afd7233483
    constructor(address _token) {
        if (_token == address(0)) revert ZeroAddress();
        token = IERC20(_token);
    }

    /// @notice Lock `amount` of tUSD8 for `recipient`. Caller must approve this
    ///         contract for exactly `amount` first (least privilege — never infinite).
    /// @return id The new payment id.
    function createPayment(address recipient, uint256 amount, string calldata memo)
        external
        nonReentrant
        returns (uint256 id)
    {
        if (recipient == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        id = nextPaymentId++;
        payments[id] = Payment({
            payer: msg.sender,
            recipient: recipient,
            amount: amount,
            memo: memo,
            createdAt: block.timestamp,
            status: Status.Pending
        });

        token.safeTransferFrom(msg.sender, address(this), amount);
        emit PaymentCreated(id, msg.sender, recipient, amount, memo);
    }

    /// @notice Recipient pulls the escrowed funds. Only the named recipient, only once.
    function claimPayment(uint256 id) external nonReentrant {
        Payment storage p = payments[id];
        if (p.status != Status.Pending) revert NotPending();
        if (msg.sender != p.recipient) revert NotRecipient();

        p.status = Status.Claimed;
        token.safeTransfer(p.recipient, p.amount);
        emit PaymentClaimed(id, p.recipient, p.amount);
    }

    /// @notice Payer cancels a pending payment and gets the funds back.
    ///         Allowed any time before the claim; the recipient can never
    ///         trigger a refund. EXPIRY is the documented window after which
    ///         a payment is considered stale (see isExpired); it does not
    ///         block an earlier cancel.
    function refundPayment(uint256 id) external nonReentrant {
        Payment storage p = payments[id];
        if (p.status != Status.Pending) revert NotPending();
        if (msg.sender != p.payer) revert NotPayer();

        p.status = Status.Refunded;
        token.safeTransfer(p.payer, p.amount);
        emit PaymentRefunded(id, p.payer, p.amount);
    }

    /// @notice True once a pending payment is past its expiry window.
    function isExpired(uint256 id) external view returns (bool) {
        Payment storage p = payments[id];
        return p.status == Status.Pending && block.timestamp >= p.createdAt + EXPIRY;
    }
}
