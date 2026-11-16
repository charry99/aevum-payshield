# Aevum Builder Challenge #1 — Build Plan: PayShield on Aevum

**Status:** scaffold only (research + skeleton). Nothing submitted, nothing deployed, no wallet connected.
**Last updated:** 2026-11-16 ~12:30 IST (research day 1 of build window).

## 1. The challenge (verified)

| Item | Fact | Source |
|---|---|---|
| Event | Aevum Builder Challenge #1, DoraHacks, free, online, solo or teams of 2–4 | DoraHacks detail page + starter kit PDF |
| Build window | Nov 16 – Dec 11, 2026 | DoraHacks / starter kit |
| Submissions close | **Dec 11, 2026 16:00 HKT = 08:00 UTC = 13:30 IST** (firm, late not accepted) | DoraHacks / starter kit |
| Judging | Dec 12–14 | DoraHacks / starter kit |
| Demo Day / winners | **Dec 15, 2026 14:00 HKT = 06:00 UTC** — Top 5 give a 3–5 min live video-call demo | DoraHacks / starter kit |
| Prize pool | **$1,500 USDT: 1st $800 / 2nd $500 / 3rd $200** | DoraHacks / starter kit |
| User status | **REGISTERED, solo, free** (Nov 16 ~11:39 IST, DoraHacks charry99) | own record |
| Track | Stablecoin payments on Aevum testnet using **tUSD8** | DoraHacks / starter kit |
| Fast track | Winners/participants get fast track into mainnet builder program ahead of QDay mainnet launch (Feb 2027) | DoraHacks |
| Starter kit | Google Drive PDF (8 pages) — `https://drive.google.com/file/d/1YL574BFJTnZ9Z-WzkZMyuQnWNUOgUJ6l/view?usp=sharing` (local copy: `/tmp/aevum-starter-kit.zip`, text extracted) | moonhub mirror of DoraHacks page |

### Submission requirements (DoraHacks page + starter kit pre-submit checklist)
1. Public GitHub repo link (clean, readable code; opens logged-out).
2. Aevum blockchain integration — evidence the app uses QDay infra (smart contracts, ERC-8004, QDay dapps).
3. Live deployment — functional demo / prototype interface, or a packaged Docker image.
4. Video pitch & demo (link works without login). Top 5 present live 3–5 min.
5. Project docs — problem, architecture, core workflows, technologies used.
6. No malicious code. All contracts on Aevum testnet, test tokens only. All code written inside the build window.
7. No private keys / .env / API keys in the repo or its history.

### Judging weights (starter kit — these drive the plan)
| Criterion | Weight |
|---|---|
| Innovation and originality | 20 |
| User experience & presentation | 15 |
| Technical quality & platform integration | 15 |
| Real-world utility & market potential | 15 |
| Safety, trust and controls | 15 |
| Demo clear and well-structured | 10 |
| Comprehensive documentation | 10 |
| **Total** | **100** |

## 2. The network (verified from official sources)

| Item | Value | Source |
|---|---|---|
| Network | QDay Aevum testnet | qday.io / wiki.qday.info FAQ |
| Chain ID | **44005** (`0xABE5`) | wiki FAQ, MetaMask guide, starter kit |
| RPC | `https://rpc-test.qday.info` (WS `wss://rpc-test.qday.info`) | wiki FAQ, starter kit |
| Explorer | `https://explorer-test.qday.info` | wiki FAQ, starter kit |
| Native gas token | **tQDAY**, 18 decimals (testnet only, no value) | wiki FAQ |
| Stablecoin | **tUSD8** `0x456569838f1d43009A91ebA4263147Afd7233483`, ERC-20, **6 decimals** | qday.io/official-links (last verified Nov 10, 2026), wiki FAQ §3.8, starter kit |
| Faucet | `https://faucet.qday.info/en` — gives tQDAY and/or tUSD8. Faucet contract `0xE5074CBbd046AFb491EB8692abD6cF7ECCC6dEE5` | wiki FAQ, Medium guide, starter kit |
| EVM compatibility | Full — Solidity, Foundry, Hardhat, Remix, ethers.js, viem, wagmi all work; only the RPC changes | wiki FAQ §4.1, qday.io |
| Gas model | EIP-1559 (base fee + priority fee), paid in tQDAY | wiki FAQ §3.7 |

### Scaffold verification (2026-11-16 ~12:45 IST)
- `forge build` + `forge test`: **9/9 tests pass** (create/claim/refund, double-claim revert, only-recipient, refund rules, zero-value reverts, expiry flag). One benign lint warning: `block.timestamp` comparison in `isExpired` — a 7-day window, validator drift of seconds is irrelevant; left as is.
- Local `git init` done in the scaffold dir only (for the Foundry submodules); **no GitHub repo created, nothing pushed**.
- **RPC JSON-RPC POSTs TIME OUT from this VM** (3 attempts: `eth_chainId`, `eth_blockNumber`, `web3_clientVersion` — all 8–15 s timeouts, rc=28/000). **GET to the RPC root returns HTTP 200**, and the explorer, faucet and wiki all return HTTP 200 in ~2 s. So the host is alive but JSON-RPC POSTs hang from this egress. **Deploy/verify steps must be retried from the user's machine, another network, or Remix in the browser** — do not assume the VM can deploy. Re-test before milestone 2.
- tUSD8 contract **code not yet verified live** (could not read it — same RPC block). Verify `eth_getCode` + `decimals()`/`symbol()` on a working connection before trusting the address in code; the address itself is confirmed by three official sources.

### Not verified / not available (do NOT build the core on these)
- **QDay SDK (`@qday-io/sdk`) and CLI are NOT published** — planned Q1 2027 (wiki wallet-integration page). No npm package to install.
- **x402 facilitator / stablecoin paymaster**: FAQ says live on testnet (Phase 1.5); the QDay getting-started guide says x402 testing, agent wallets and agent registration are "coming, with docs/tools/examples to be published when each one launches". Mixed signals — treat x402 as **unverified, stretch only**.
- **ERC-4337 smart accounts**: wiki says live on testnet; EntryPoint/bundler details for testnet "will be published in the docs". No usable addresses found. Stretch only.
- **ERC-8004 registry on Aevum**: named in the starter kit as the standard for the Confirmation of Payee track, but **no registry address found** in official docs. Stretch only — the core must not depend on it.
- **tUSD8 faucet amounts / cooldowns**: not stated anywhere official; the kit only warns about "try again later" rate limits. Claim early, expect cooldowns.
- **Discord**: https://discord.gg/bYPhjmrSfK, office hours Mon–Fri 10:00–18:00 HKT (02:00–10:00 UTC). Not joined, nothing posted (needs user ask).

## 3. App concept: PayShield on Aevum — Confirmation of Payee for tUSD8

**Track:** Confirmation of Payee (explicit starter-kit track) + Decentralized Payments.
**One-line pitch:** Before you pay anyone in tUSD8, PayShield confirms the payee is who you think they are — then settles the payment through an on-chain escrow so a mistake or a scam address can't drain you in one click.

### The problem (real, documented)
Address poisoning: scammers send dust from lookalike addresses (`0xAb…1234` vs `0xAb…1235`) so the victim copies the wrong address from their transaction history and sends real funds to the scammer. Stablecoin payments make this a one-click, irreversible loss. Existing wallets show no warning.

### The one flow (end to end, on Aevum testnet)
1. **Create:** payer enters recipient address + tUSD8 amount + memo. PayShield runs the Confirmation of Payee check:
   - **Lookalike check** — recipient vs the payer's known counterparties (address book + recent on-chain counterparties): flags addresses that share the first/last characters but differ in the middle (the poisoning pattern), with a plain-language warning and a "this is NOT your usual address" verdict.
   - **Contract check** — warns if the recipient is a contract (read on-chain code) rather than an EOA.
   - **Link check** — for shared payment links, the deterministic URL checks reused from PayShield (`linkcheck.py`): obfuscation, typosquat, shorteners.
   - Verdict shown as Safe / Caution / Danger with reasons — same UX as PayShield.
2. **Fund:** payer approves tUSD8 and calls `PayShieldHub.createPayment(recipient, amount, memo)` — funds lock in escrow, a payment ID is emitted, and a shareable payment link is produced.
3. **Claim:** recipient opens the link, sees the same confirmation screen (payer, amount, memo, tx hash), and calls `claimPayment(id)` — funds release to them.
4. **Safety net:** payer can `refundPayment(id)` any time before claim; after a 7-day expiry the payer can reclaim. Every step emits an event — full on-chain audit trail with explorer links on the receipts page.

### Why this concept (judging fit)
- **Innovation (20):** address-poisoning Confirmation of Payee for stablecoins is a fresh, non-template angle, and the escrow safety net is a real mechanism, not a demo prop.
- **Safety/trust (15):** the whole app IS a safety control — least-privilege (approve exact amount only), payer cancel, expiry, verifiable receipts.
- **Technical quality (15):** real Foundry-tested contract, verified source on the explorer, retries/async handling in the frontend.
- **Real-world utility (15):** every stablecoin user faces this risk; fits merchant/agent payment workflows; path to mainnet is the same contract on QDay mainnet.
- **UX (15) / Demo (10) / Docs (10):** one flow, plain language, reproducible on testnet, full README.

### Deliberately NOT in the core
- x402, ERC-4337 session keys, ERC-8004 registry, AI agent auto-pay — all unverified tooling. If the docs publish EntryPoint/bundler/registry addresses mid-window, the stretch goal is: payer sets a per-link spend cap + expiry enforced on-chain (already in the contract design as `EXPIRY`), and a short "stretch" note in docs. The core ships without them.

## 4. What reuses from PayShield vs what is new

PayShield repo: https://github.com/charry99/payshield — "AI pay-link safety checker", Python, MIT, built for the PayPal AI Hackathon (Devpost 1295416, submitted Nov 11). Files: `server.py`, `linkcheck.py`, `paypal_sandbox.py`, `public/index.html`, `render.yaml`, `README.md`, `LICENSE`.

| PayShield piece | Reuse? | Notes |
|---|---|---|
| `linkcheck.py` — deterministic URL checks (obfuscation, raw IPs, punycode, suspicious TLDs, shorteners, redirect chains, TLS, typosquat via Levenshtein) | **Yes, reuse** | Port the typosquat/Levenshtein logic to the address lookalike checker (same idea, hex addresses instead of domains). Keep the Python module for the link-safety check on shared payment links. |
| `server.py` — Python stdlib-only HTTP server, zero dependencies | **Yes, reuse pattern** | Serves the static frontend; add a tiny JSON API for the check (runs `linkcheck` server-side). Zero-dep keeps the Docker image small and the Render deploy free. |
| `public/index.html` — single-page UI, verdict display | **Yes, reuse pattern** | Rebuild the UI around create → confirm → claim; keep the plain-language verdict style. Add ethers.js v6 via CDN for wallet + contract calls. |
| `README.md` "Honest limits" style | **Yes** | Same honesty: this is a check, not a guarantee; testnet only; no real money. |
| `render.yaml` — free Render deploy | **Yes, reuse** | Same free-tier static/web deploy for the live demo. |
| `LICENSE` (MIT) | **Yes** | Copy into the new repo. |
| `paypal_sandbox.py` — PayPal sandbox API | **No — replace** | The PayPal verification layer is replaced by on-chain verification on Aevum (contract code check, events, explorer links). Do not carry PayPal code into this repo. |
| Otari DeepSeek AI explainer | **No for core** | Optional stretch only, and only if a free key path exists; the deterministic checks carry the demo. Do not invent an AI dependency. |

### New (must be built)
- `contracts/PayShieldHub.sol` — tUSD8 escrow: create / claim / refund / expiry, events, `ReentrancyGuard` + `SafeERC20` (OpenZeppelin).
- `test/PayShieldHub.t.sol` — Foundry tests with a mock 6-decimal ERC-20 (happy path, double-claim, refund-before-claim, refund-after-claim reverts, expiry, wrong-caller reverts).
- `script/Deploy.s.sol` — Foundry deploy script for Aevum (chain 44005).
- `frontend/` — wallet connect (MetaMask, Aevum network add via EIP-3085), create/claim/cancel UI, lookalike checker (JS port of the Levenshtein check), receipts page with explorer links.
- `Dockerfile` — serves the app (Python stdlib server) for the "packaged Docker image" submission option.
- `docs/ARCHITECTURE.md`, `docs/DEMO.md` — architecture diagram (text), demo script, known limits, roadmap.

## 5. Architecture

```
User (MetaMask, Aevum 44005)
   │  ethers.js v6 (CDN)
   ▼
Frontend (static, served by Python stdlib server — same pattern as PayShield)
   │  1. Confirmation-of-Payee check (local JS: lookalike vs address book + recent counterparties)
   │  2. Link-safety check (server-side linkcheck.py port, for shared payment links)
   ▼
PayShieldHub.sol (Aevum testnet, verified source)
   │  createPayment(recipient, amount, memo)  — pulls tUSD8 via transferFrom (exact approve only)
   │  claimPayment(id)                        — recipient pulls funds
   │  refundPayment(id)                       — payer cancels before claim / after expiry
   │  events: PaymentCreated / PaymentClaimed / PaymentRefunded
   ▼
tUSD8 (0x4565…3483, 6 decimals) — the only token the contract touches
Explorer links on every receipt: https://explorer-test.qday.info/tx/<hash>
```

Deployment targets (all free): frontend on Render free tier (same as PayShield) or GitHub Pages; contract on Aevum testnet via Foundry; Docker image as the packaged fallback.

## 6. Milestones (Nov 16 → Dec 11)

| # | Dates | Work | Done when |
|---|---|---|---|
| M0 | Nov 16–17 | **Setup.** Create GitHub repo `aevum-payshield` (user step — browser). Claim faucet tQDAY + tUSD8. Re-test RPC POST from a working network; verify tUSD8 `decimals()`/`symbol()`/`getCode` live. Foundry project compiles; OZ deps installed. | Repo exists, wallet funded on testnet, contract compiles |
| M1 | Nov 18–20 | **Contract + tests.** Finish `PayShieldHub.sol`, Foundry tests green (incl. mock token), deploy to Aevum, **verify source on explorer**. Record contract address + deploy tx. | Verified contract on explorer, tests passing |
| M2 | Nov 21–24 | **Frontend.** Wallet connect + network add, create/claim/cancel UI, lookalike checker, receipts page. CLI script fallback (`scripts/pay.js`) if the UI slips. | Full flow works end-to-end on testnet in the browser |
| M3 | Nov 25–27 | **Demo + docs.** Record a clean end-to-end testnet run (create → claim, plus a lookalike warning + a refund). Write README + ARCHITECTURE + DEMO docs. Dockerfile builds and runs. Frontend deployed (Render free). | Live demo URL works; docs complete |
| M4 | Nov 28–30 | **Video + polish.** Record the pitch/demo video (2–3 min), edge-case pass (wrong network, insufficient tUSD8, double-claim, expired payment), security self-review (reentrancy, approvals, no unlimited allowance). | Video link works logged-out; no known crash paths |
| M5 | Dec 1–4 | **Submit early.** Submit on DoraHacks (repo link + video + deployment + docs). Confirm submission shows correctly. | Submitted, confirmation saved |
| M6 | Dec 5–11 | **Buffer + Demo Day prep.** Fix anything the submission page flags; prepare the 3–5 min live pitch (problem → flow → live tx → why it wins). | Pitch rehearsed; repo frozen except fixes |

## 7. Risks (with mitigations)

| Risk | Impact | Mitigation |
|---|---|---|
| RPC JSON-RPC POSTs time out from this VM (verified) | Can't deploy/verify from here | Deploy from the user's machine or Remix in the browser; re-test RPC first (M0). Fallback: use the explorer's contract tools. |
| Faucet rate limits / tUSD8 faucet empty | No test funds, can't demo | Claim on day 1 (M0); ask in Discord office hours if dry; keep amounts tiny (test payments of 1–10 tUSD8). |
| x402 / SDK / ERC-4337 / ERC-8004 docs never publish | Stretch goals die | Core doesn't depend on them; note as roadmap, not as built. |
| tUSD8 address differs from docs (unverified on-chain) | Contract points at the wrong token | Verify `getCode`/`decimals()` live in M0 before deploying; never hardcode an unverified address. |
| Build window collides with other deadlines (ACE Builders Nov 21–22, threejs-fps-01, etc.) | Less build time | The plan is deliberately small (one contract, one page); M5 submits early (Dec 1–4) so a slip still lands before Dec 11. |
| Demo Day is a live video call (Top 5) | User must present | Prep the pitch in M6; nothing here can be delegated to an agent. |
| Render free tier sleeps / slow cold start during the demo | Demo stalls | Pre-warm the URL before the call; Docker image is the backup artifact; a local run is the last resort. |

## 8. Submission checklist (from the starter kit — verify each before submitting)

- [ ] Submitted before Dec 11, 13:30 IST (submit early; portals get slow at the end)
- [ ] Repo is public and opens in a logged-out browser
- [ ] No private keys, .env files or API keys in the repo or commit history
- [ ] README lets a stranger run the project
- [ ] Contract/app is deployed on the official testnet (44005), not another network
- [ ] Demo video link works without login
- [ ] All team members are listed and registered (solo: just him)
- [ ] Live deployment URL works (or Docker image runs)
- [ ] Contract source verified on explorer-test.qday.info
- [ ] Docs: problem, architecture, core workflows, technologies used

## 9. Open questions for the user (decisions only he can make)

1. **Repo name:** `aevum-payshield` (proposed) — okay, or a different name? Repo creation is a browser step (parent agent).
2. **Wallet for deploy:** use his main EVM wallet or a fresh deploy wallet? (Fresh is cleaner for a hackathon; the faucet funds whichever address he pastes. No wallet connection by agents — he connects it himself in MetaMask/Remix.)
3. **Demo video:** he records it (voice + screen), or a silent screen-recording with captions? Needs his voice/face decision for the pitch.
4. **Discord:** join https://discord.gg/bYPhjmrSfK for office-hours help? (Not joined yet — needs his go-ahead.)

## 10. Sources (all official unless noted)

- DoraHacks detail page: https://dorahacks.io/hackathon/qday/detail
- Starter kit PDF (Google Drive, linked from DoraHacks): https://drive.google.com/file/d/1YL574BFJTnZ9Z-WzkZMyuQnWNUOgUJ6l/view?usp=sharing
- QDay wiki FAQ: https://wiki.qday.info/guide/faq
- QDay official links & addresses: https://qday.io/official-links (last verified Nov 10, 2026)
- QDay site: https://qday.io/ · Wiki: https://wiki.qday.info · Faucet: https://faucet.qday.info/en · Explorer: https://explorer-test.qday.info
- Aevum getting-started guide (PQA Labs, Medium, Oct 16, 2026): https://pqalabs.medium.com/aevum-testnet-how-do-i-get-started-qday-4dd0a6d64a34
- PayShield repo: https://github.com/charry99/payshield
- Live probe results (this VM, 2026-11-16 ~12:30 IST): RPC POST timeout ×3; RPC GET 200; explorer/faucet/wiki 200.
