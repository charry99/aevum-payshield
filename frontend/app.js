// PayShield on Aevum — frontend skeleton (M2 fills in the wiring).
// Stack: ethers.js v6 (CDN) + MetaMask. No build step, no framework.
// Network constants (verified — see PLAN.md §2).
const AEVUM_CHAIN_ID = 44005;
const AEVUM_RPC = "https://rpc-test.qday.info";
const EXPLORER = "https://explorer-test.qday.info";
const TUSD8_ADDRESS = "0x456569838f1d43009A91ebA4263147Afd7233483";
const TUSD8_DECIMALS = 6;
// Set after deploy (M1):
const HUB_ADDRESS = ""; // e.g. "0x..."

const HUB_ABI = [
  "function createPayment(address recipient, uint256 amount, string memo) returns (uint256 id)",
  "function claimPayment(uint256 id)",
  "function refundPayment(uint256 id)",
  "function payments(uint256 id) view returns (address payer, address recipient, uint256 amount, string memo, uint256 createdAt, uint8 status)",
  "function isExpired(uint256 id) view returns (bool)",
  "event PaymentCreated(uint256 indexed id, address indexed payer, address indexed recipient, uint256 amount, string memo)",
  "event PaymentClaimed(uint256 indexed id, address indexed recipient, uint256 amount)",
  "event PaymentRefunded(uint256 indexed id, address indexed payer, uint256 amount)",
];
const ERC20_ABI = [
  "function approve(address spender, uint256 amount) returns (bool)",
  "function balanceOf(address a) view returns (uint256)",
  "function allowance(address o, address s) view returns (uint256)",
  "function decimals() view returns (uint8)",
];

// --- Confirmation of Payee: lookalike (address-poisoning) check ---
// Port of the Levenshtein idea from PayShield's linkcheck.py: a recipient that
// shares the first/last characters with a known counterparty but differs in the
// middle is the classic poisoning pattern. Known counterparties come from a
// local address book (localStorage) — M2 adds "recent on-chain counterparties".
function hexDistance(a, b) {
  // Levenshtein over lowercase hex, no 0x prefix.
  a = a.toLowerCase().replace(/^0x/, "");
  b = b.toLowerCase().replace(/^0x/, "");
  const m = a.length, n = b.length;
  const dp = Array.from({ length: m + 1 }, (_, i) => [i, ...Array(n).fill(0)]);
  for (let j = 0; j <= n; j++) dp[0][j] = j;
  for (let i = 1; i <= m; i++)
    for (let j = 1; j <= n; j++)
      dp[i][j] = Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
  return dp[m][n];
}

function lookalikeCheck(recipient, knownAddresses) {
  // Returns { verdict: "safe"|"caution"|"danger", reasons: [] }.
  const reasons = [];
  let verdict = "safe";
  const r = recipient.toLowerCase();
  for (const known of knownAddresses) {
    const k = known.toLowerCase();
    if (r === k) return { verdict: "safe", reasons: ["Exact match with a known counterparty."] };
    const d = hexDistance(r, k);
    const sameEnds = r.slice(2, 6) === k.slice(2, 6) && r.slice(-4) === k.slice(-4);
    if (sameEnds && d <= 6) {
      verdict = "danger";
      reasons.push(`Looks like ${known} (same start/end, ${d} characters differ) — this is the classic address-poisoning pattern. Do NOT pay until you verify the full address with the recipient out of band.`);
    } else if (d <= 4) {
      verdict = verdict === "danger" ? verdict : "caution";
      reasons.push(`Very close to known address ${known} (${d} characters differ). Double-check the full address.`);
    }
  }
  if (reasons.length === 0) reasons.push("No lookalike match in your known counterparties. Still verify the full address with the recipient.");
  return { verdict, reasons };
}

// --- Wiring (M2) ---
// TODO M2: connect wallet + wallet_addEthereumChain (44005) + switch; read
// HUB_ADDRESS; approve exact amount; createPayment; claim/refund; isExpired;
// contract-code check on recipient (eth_getCode) -> warn if contract; receipts
// list with explorer tx links; address book in localStorage; recent
// counterparties via explorer API.
document.getElementById("checkBtn").addEventListener("click", () => {
  const recipient = document.getElementById("recipient").value.trim();
  const box = document.getElementById("verdict");
  if (!/^0x[0-9a-fA-F]{40}$/.test(recipient)) {
    box.style.display = "block";
    box.className = "danger";
    box.textContent = "That is not a valid address. Paste the full 0x address.";
    return;
  }
  const known = JSON.parse(localStorage.getItem("payshield-known") || "[]");
  const result = lookalikeCheck(recipient, known);
  box.style.display = "block";
  box.className = result.verdict;
  box.innerHTML = "<strong>Verdict: " + result.verdict.toUpperCase() + "</strong><ul>" +
    result.reasons.map((r) => "<li>" + r + "</li>").join("") + "</ul>";
  document.getElementById("createBtn").disabled = result.verdict === "danger";
});
