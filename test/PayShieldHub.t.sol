// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PayShieldHub} from "../contracts/PayShieldHub.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Mock tUSD8: 6 decimals, like the real token on Aevum.
contract MockUSD8 is ERC20 {
    constructor() ERC20("Test USD8", "tUSD8") {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract PayShieldHubTest is Test {
    PayShieldHub hub;
    MockUSD8 token;

    address payer = address(0xA11CE);
    address recipient = address(0xB0B);
    address stranger = address(0xC0FFEE);

    uint256 constant AMOUNT = 10_000_000; // 10 tUSD8 (6 decimals)

    function setUp() public {
        token = new MockUSD8();
        hub = new PayShieldHub(address(token));
        token.mint(payer, 1_000_000_000);
        token.mint(recipient, 0);
        vm.prank(payer);
        token.approve(address(hub), type(uint256).max); // test setup only; UI approves exact amounts
    }

    function testCreateLocksFunds() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "invoice #1");
        assertEq(id, 0);
        assertEq(token.balanceOf(address(hub)), AMOUNT);
        (address p, address r, uint256 a, , , PayShieldHub.Status s) = hub.payments(id);
        assertEq(p, payer);
        assertEq(r, recipient);
        assertEq(a, AMOUNT);
        assertEq(uint256(s), uint256(PayShieldHub.Status.Pending));
    }

    function testClaimReleasesToRecipient() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "invoice #1");
        vm.prank(recipient);
        hub.claimPayment(id);
        assertEq(token.balanceOf(recipient), AMOUNT);
        assertEq(token.balanceOf(address(hub)), 0);
    }

    function testDoubleClaimReverts() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "x");
        vm.prank(recipient);
        hub.claimPayment(id);
        vm.prank(recipient);
        vm.expectRevert(PayShieldHub.NotPending.selector);
        hub.claimPayment(id);
    }

    function testOnlyRecipientCanClaim() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "x");
        vm.prank(stranger);
        vm.expectRevert(PayShieldHub.NotRecipient.selector);
        hub.claimPayment(id);
    }

    function testPayerCanRefundBeforeClaim() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "x");
        vm.prank(payer);
        hub.refundPayment(id);
        assertEq(token.balanceOf(payer), 1_000_000_000);
    }

    function testRefundAfterClaimReverts() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "x");
        vm.prank(recipient);
        hub.claimPayment(id);
        vm.prank(payer);
        vm.expectRevert(PayShieldHub.NotPending.selector);
        hub.refundPayment(id);
    }

    function testZeroAmountReverts() public {
        vm.prank(payer);
        vm.expectRevert(PayShieldHub.ZeroAmount.selector);
        hub.createPayment(recipient, 0, "x");
    }

    function testZeroRecipientReverts() public {
        vm.prank(payer);
        vm.expectRevert(PayShieldHub.ZeroAddress.selector);
        hub.createPayment(address(0), AMOUNT, "x");
    }

    function testExpiryFlag() public {
        vm.prank(payer);
        uint256 id = hub.createPayment(recipient, AMOUNT, "x");
        assertFalse(hub.isExpired(id));
        vm.warp(block.timestamp + 7 days + 1);
        assertTrue(hub.isExpired(id));
    }
}
