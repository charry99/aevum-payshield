# Aevum PayShield — Progress Log

## 2026-11-16 ~15:15 IST — M1 prep: compile + gas + faucet probe + Remix package (NO deploy)

**User decision (15:10 IST): "I'll deploy via Remix from my main wallet."** No throwaway deployer.
Deploy wallet: main `0x2DB8be71CCdAa91f578721378fbA05F6EE198686`.

### Build + tests (re-run)
- `forge build`: clean (one benign `block.timestamp` lint warning, as before).
- `forge test`: **9 passed, 0 failed**.
- Bytecode: init code **5,950 bytes**, runtime **5,450 bytes**, deploy data with args 5,982 bytes.
  Compiler solc 0.8.20, optimizer OFF (foundry.toml — Remix must match for verification).
- Deploy gas (forge script dry-run on live RPC): **1,632,358 gas** (CREATE tx, gas `0x18e866`).
  Live gasPrice ~1 gwei → deploy costs ≈ **0.00163 tQDAY**. Recommend gas limit 2,000,000 in Remix.

### Faucet — tQDAY claim for main wallet: BLOCKED on captcha (user-side step)
- Main wallet on Aevum: tQDAY **0**, tUSD8 **0** — faucet claim is required before the deploy.
- Faucet flow reverse-engineered from the live page JS: claim is `POST https://faucet.qday.info/gasapi/claim`
  with body `{address, captchaToken}` where the token comes from **Cloudflare Turnstile**
  (site key `0x4AAAAAAFbHzhwWSPHWtco1`, loaded from challenges.cloudflare.com). **Cannot be
  claimed via curl — needs the user's browser.**
- Backend `/info`: faucet funded, tUSD8 enabled, drip 1 tUSD8; `gasDrip` 0.0002 tQDAY top-up;
  page advertises 5 tQDAY per claim, 24h cooldown.
- **Eligibility pre-check says `{"eligible":false,"via":null}` for the main wallet** — reason
  unknown from the backend. On-chain state contradicts a real block: faucet contract holds
  **705 tQDAY**, gas wallet holds **6,250.89 tQDAY**, `lastClaim(main wallet) = 0` (never claimed),
  `cooldown() = 86,400` (24h). Most likely the shared-VM IP is rate-limited, or a backend quirk.
  User should try the claim in his own browser first; fallback is Discord office hours.
- tUSD8 claim (1/day) needs Trellis Wallet sign-in — not needed for the deploy, claim after.

### Remix deploy package (DONE)
- **`REMIX-DEPLOY.md`** (42,666 bytes): network add steps, faucet steps, Remix compile
  (0.8.20, optimizer OFF), deploy steps (constructor arg tUSD8, gas limit 2,000,000),
  explorer verification steps (constructor args ABI-encoded), troubleshooting. Flattened
  source embedded verbatim in the doc.
- **`PayShieldHub.flattened.sol`** (35,559 bytes): `forge flatten` output, OZ v5.4.0, same
  content as in the doc. Both files committed + pushed.
- Repo now at commit (see git log): REMIX-DEPLOY.md + PayShieldHub.flattened.sol + PROGRESS.md.

### Still open (user steps)
- Claim tQDAY on faucet.qday.info from his browser (Turnstile), confirm ~5 tQDAY landed.
- Deploy via Remix from the main wallet following REMIX-DEPLOY.md; report contract address + tx hash.
- Demo-video format + Discord join still open.

## 2026-11-16 ~15:05–15:10 IST — Repo + recon (no deploy)

### Repo (DONE)
- Created via `gh repo create aevum-payshield --public` (gh logged in as charry99).
- **https://github.com/charry99/aevum-payshield** — public, master branch.
- Pushed scaffold, commit `f1483fb` (17 files): contracts/PayShieldHub.sol, test/PayShieldHub.t.sol, script/Deploy.s.sol, frontend/, server.py, Dockerfile, docs/, PLAN.md, README.md, foundry.lock, foundry.toml, .gitmodules + forge-std / openzeppelin-contracts submodules.
- Verified remote: HEAD = `f1483fb`, 23 tree entries, homepage = https://dorahacks.io/hackathon/qday/detail, topics: solidity, foundry, stablecoin, escrow, aevum, qday, hackathon, confirmation-of-payee.
- No secrets in history (`.env` gitignored; only `.env.example` committed).

### Aevum RPC (FIXED — was timing out, now works)
- 2026-11-16 ~12:30 IST: all JSON-RPC POSTs timed out from this VM (rc=28, 8–15 s), GET 200.
- 2026-11-16 ~15:07 IST retry: `eth_chainId` → `0xabe5` (44005) in 5.2 s; `eth_blockNumber` → `0x32838a` (3,293,578) in 1.3 s. **POSTs work now** — the block was transient. Re-test again at deploy time.

### tUSD8 (VERIFIED ON-CHAIN, chain 44005)
- Address `0x456569838f1d43009A91ebA4263147Afd7233483` — code exists.
- `decimals()` = 6, `symbol()` = "tUSD8", `name()` = "tUSD8", `totalSupply()` = 206,000 tUSD8.
- Safe to hardcode in the deploy script.

### Faucet (read live 2026-11-16 ~15:09 IST, https://faucet.qday.info/en, HTTP 200)
- **tQDAY: 5 per claim, once every 24h per recipient address.** Relay sends it, no gas/signing needed; tops up a tiny amount first if the address has no gas.
- **tUSD8: 1 per claim, same 24h limit shared with Trellis app claims.** Requires Trellis Wallet sign-in (email + code) and an activated Main Wallet; tokens go only to that wallet.
- Faucet address on the live page: `0x33d19Bde2e1798c13808f17BfBa1780b28e4bACC` — differs from the wiki/Medium address `0xE5074CBbd046AFb491EB8692abD6cF7ECCC6dEE5`; both have code on-chain, page address is current.
- Caveat: the page carries a "tUSD8 faucet is temporarily unavailable" state string — availability unconfirmed until the user signs in.

### Tests
- `forge test` re-run 2026-11-16 ~15:10 IST: **9 passed, 0 failed**.

### NOT done (blocked on the user)
- **No deploy.** Deploy wallet choice still open (main EVM wallet vs fresh). Nothing deployed, no wallet connected, nothing signed, $0 spent.
- **No faucet claim.** Needs the user's wallet address (+ Trellis sign-in for tUSD8). Claim early — 24h cooldown per address.
- Demo-video format (voice + screen vs silent + captions) and Discord join still open.

## Next concrete steps
1. User picks deploy wallet (main vs fresh) → faucet claims (tQDAY 5 + tUSD8 1) to that address.
2. M1: deploy PayShieldHub to Aevum testnet via Foundry (RPC works from this VM now, re-test first), verify source on explorer-test.qday.info, record contract address + deploy tx.
3. M2: frontend end-to-end (wallet connect, create/claim/cancel, lookalike checker, receipts).
4. M3–M5: demo + docs, video, submit early (Dec 1–4) — hard close Dec 11 13:30 IST.
