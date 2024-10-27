// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Disperse.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock ERC20 token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}

contract DisperseTest is Test {
    Disperse public disperse;
    MockToken public token;
    address public alice = address(1);
    address public bob = address(2);
    address public charlie = address(3);
    
    function setUp() public {
        disperse = new Disperse();
        token = new MockToken();
        
        // Fund test addresses with ETH
        vm.deal(alice, 100 ether);
        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);
        
        // Fund alice with tokens
        token.transfer(alice, 1000 * 10**18);
    }
    
    // ETH dispersion tests
    function test_DisperseEth() public {
        address[] memory recipients = new address[](3);
        recipients[0] = bob;
        recipients[1] = charlie;
        recipients[2] = address(4);
        
        uint256 initialBobBal = bob.balance;
        uint256 initialCharlieBal = charlie.balance;
        uint256 disperseAmount = 3 ether;
        
        vm.prank(alice);
        disperse.disperseEth{value: disperseAmount}(recipients);
        
        assertEq(bob.balance, initialBobBal + disperseAmount/3);
        assertEq(charlie.balance, initialCharlieBal + disperseAmount/3);
    }
    
    function testFail_DisperseEthNoValue() public {
        address[] memory recipients = new address[](2);
        recipients[0] = bob;
        recipients[1] = charlie;
        
        vm.prank(alice);
        disperse.disperseEth{value: 0}(recipients);
    }
    
    function testFail_DisperseEthEmptyRecipients() public {
        address[] memory recipients = new address[](0);
        
        vm.prank(alice);
        disperse.disperseEth{value: 1 ether}(recipients);
    }
    
    // Token dispersion tests
    function test_DisperseTokens() public {
        address[] memory recipients = new address[](2);
        recipients[0] = bob;
        recipients[1] = charlie;
        
        uint256 amount = 100 * 10**18;
        
        vm.startPrank(alice);
        token.approve(address(disperse), amount);
        disperse.disperseTokens(address(token), recipients, amount);
        vm.stopPrank();
        
        assertEq(token.balanceOf(bob), amount/2);
        assertEq(token.balanceOf(charlie), amount/2);
    }
    
    function testFail_DisperseTokensInsufficientBalance() public {
        address[] memory recipients = new address[](2);
        recipients[0] = bob;
        recipients[1] = charlie;
        
        uint256 amount = 2000 * 10**18; // More than Alice has
        
        vm.startPrank(alice);
        token.approve(address(disperse), amount);
        disperse.disperseTokens(address(token), recipients, amount);
        vm.stopPrank();
    }

    receive() external payable {} // Allow contract to receive ETH
}