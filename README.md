# PayShield on Aevum — Confirmation of Payee for tUSD8
> **Status: scaffold.** Contract + tests + frontend skeleton exist. Not yet deployed, not submitted. See [PLAN.md](PLAN.md) for the full build plan, verified facts, and milestones.

## What it is
Before you pay anyone in tUSD8 on the QDay Aevum testnet, PayShield confirms the payee is who you think they are — then settles through an on-chain escrow so a mistake can't drain you in one click.

1. **Create** — enter recipient + amount + memo. PayShield checks the recipient: lookalike-address warning (address poisoning), contract-vs-EOA warning, and link-safety checks. Verdict: Safe / Caution / Danger.
2. **Fund** — approve exactly the amount, `createPayment()` locks tUSD8 in escrow, you get a shareable payment link.
3. **Claim** — the recipient opens the link, sees payer/amount/memo/tx hash, and claims. The payer can refund any time before the claim; payments expire after 7 days.

## Network (QDay Aevum testnet)
- Chain ID: **44005** · RPC: `https://rpc-test.qday.info` · Explorer: `https://explorer-test.qday.info`
- tUSD8: `0x456569838f1d43009A91ebA4263147Afd7233483` (ERC-20, 6 decimals)
- Faucet: `https://faucet.qday.info/en`

## Run it (after the M0 setup)
```bash
forge install OpenZeppelin/openzeppelin-contracts foundry-rs/forge-std
forge test
# deploy (needs a funded wallet — never commit keys; use env)
forge script script/Deploy.s.sol --rpc-url https://rpc-test.qday.info --broadcast --verify
# frontend
python3 server.py   # http://localhost:8000
```

## Honest limits
- This is a **check, not a guarantee**. The lookalike warning catches the common poisoning pattern; it cannot prove an address belongs to a person.
- **Testnet only.** tUSD8 has no value. Nothing here touches real money.
- The QDay SDK / x402 / ERC-4337 tooling is not published yet — this app deliberately does not depend on it.

## License
MIT — see `LICENSE` (to be copied from PayShield on repo creation).
