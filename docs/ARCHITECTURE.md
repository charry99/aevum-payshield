# Architecture — PayShield on Aevum (scaffold; fill in contract address + deploy tx in M1)

## Components
- **PayShieldHub.sol** (`contracts/`) — tUSD8 escrow. `createPayment` / `claimPayment` / `refundPayment`, 7-day expiry flag, events for every step. OpenZeppelin `SafeERC20` + `ReentrancyGuard`. No admin, no fees, no upgradeability.
- **Frontend** (`frontend/`) — static page, ethers.js v6 via CDN, MetaMask. No build step.
- **server.py** — Python stdlib static server (same pattern as PayShield). Serves the frontend; no backend state.
- **Tests** (`test/`) — Foundry + mock 6-decimal ERC-20. Run `forge test`.

## Flow (text diagram)
```
Payer ──▶ [Confirmation of Payee check] ──▶ approve exact tUSD8 ──▶ createPayment()
   │            lookalike / contract / link checks              │ escrow locks funds
   │                                                           ▼
   │                                              PaymentCreated event (id, payer,
   │                                              recipient, amount, memo)
   │                                                           │
Recipient ──▶ opens payment link ──▶ sees payer/amount/memo ──▶ claimPayment(id)
   │                                                           │ funds release
   └─ payer can refundPayment(id) any time before claim ───────┘
Receipts page lists every step with explorer tx links.
```

## Trust notes
- The contract never holds approval beyond the exact amount per payment (UI approves exact amounts; the test setup's max approval is test-only).
- The lookalike check runs locally (address book in localStorage); no addresses leave the browser.
- Testnet only: tUSD8 has no value; the contract must never be pointed at a mainnet token.

## Deployment record (fill in M1)
- Hub contract address: _(to be filled)_
- Deploy tx: _(to be filled)_
- Explorer verify link: _(to be filled)_
- Frontend live URL: _(to be filled)_
- Docker image: _(to be filled, if built)_
