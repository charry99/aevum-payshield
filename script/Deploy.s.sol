// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {PayShieldHub} from "../contracts/PayShieldHub.sol";

/// @notice Deploy PayShieldHub to QDay Aevum testnet (chain 44005).
/// @dev Run: forge script script/Deploy.s.sol --rpc-url $AEVUM_RPC_URL --broadcast --verify
///      (verification needs the explorer's API; if --verify fails, verify manually on
///      https://explorer-test.qday.info with the flattened source.)
///      tUSD8 on Aevum: 0x456569838f1d43009A91ebA4263147Afd7233483 (6 decimals).
///      NEVER put a real private key in the repo — use --private-key from env / cast wallet.
contract Deploy is Script {
    address constant TUSD8 = 0x456569838f1d43009A91ebA4263147Afd7233483;

    function run() external {
        require(block.chainid == 44005, "Deploy: wrong chain, expected Aevum 44005");
        vm.startBroadcast();
        PayShieldHub hub = new PayShieldHub(TUSD8);
        vm.stopBroadcast();
        console.log("PayShieldHub deployed at:", address(hub));
        console.log("tUSD8:", TUSD8);
    }
}
