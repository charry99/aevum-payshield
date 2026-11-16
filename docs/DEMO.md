# Demo script — PayShield on Aevum (target: 2–3 min video; Top 5 live pitch: 3–5 min)

## 1. The problem (30 s)
- Address poisoning: scammers send dust from lookalike addresses; victims copy the wrong address from history and lose stablecoins in one click. Wallets show no warning.

## 2. The fix (30 s)
- PayShield is Confirmation of Payee for tUSD8: check the recipient before you pay, then settle through an on-chain escrow with a payer refund safety net.

## 3. Live flow (90 s, all on Aevum testnet — show explorer links)
1. Connect wallet (Aevum 44005), faucet tUSD8 already claimed.
2. Create a payment: recipient + 10 tUSD8 + memo "Invoice #1".
3. Show the check: paste a lookalike address → DANGER verdict, create blocked. Paste the real address → SAFE.
4. Approve exact 10 tUSD8 → createPayment → show the PaymentCreated tx on the explorer.
5. Switch to the recipient view → claimPayment → show funds arriving + Claim tx on the explorer.

## 4. Edge cases (30 s, recorded separately if time is short)
- Payer refunds a pending payment → funds return (show tx).
- Double-claim attempt reverts.
- Wrong-network wallet → plain-language error.

## 5. Close (15 s)
- One contract, one page, verified source, testnet only. Roadmap: mainnet on QDay launch; spend caps + session keys when the SDK publishes.

## Recording checklist
- [ ] Faucet funded before recording (tQDAY for gas + tUSD8 for the demo)
- [ ] Contract deployed + source verified; address in the video description
- [ ] Each tx hash visible on screen + linked in the description
- [ ] Video link works logged-out (unlisted YouTube or Drive)
- [ ] Captions or voiceover in plain language, no hype
