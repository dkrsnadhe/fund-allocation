// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {FundAllocation} from "../src/FundAllocation.sol";

contract FundAllocationTest is Test {
    FundAllocation public fundAllocation;

    function setUp() public {
        fundAllocation = new FundAllocation();
    }

    receive() external payable {}

    function testDeployContract() public {
        assertEq(fundAllocation.owner(), address(this));
    }

    function testSetAllocation() public {
        string memory _productName = "Motorcycle";
        uint256 _targetFund = 1;
        uint256 convertTargetFund = _targetFund * 10 ** 18;
        fundAllocation.setAllocation(_productName, _targetFund);
        (
            string memory productName,
            uint256 targetFund,
            uint256 totalFund
        ) = fundAllocation.allocations(0);
        assertEq(productName, _productName);
        assertEq(targetFund, convertTargetFund);
        assertEq(totalFund, 0);
    }

    function testAddFund() public {
        // setFund() 1
        string memory _productName1 = "Motorcycle";
        uint256 _targetFund1 = 1;
        fundAllocation.setAllocation(_productName1, _targetFund1);
        // setFund() 2
        string memory _productName2 = "Car";
        uint256 _targetFund2 = 2;
        fundAllocation.setAllocation(_productName2, _targetFund2);

        // addFund() 1
        fundAllocation.addFund{value: 1 ether}(0);
        // addFund() 2
        fundAllocation.addFund{value: 2 ether}(1);

        // assert
        (, , uint256 totalFund1) = fundAllocation.allocations(0);
        (, , uint256 totalFund2) = fundAllocation.allocations(1);
        assertEq(totalFund1, 1 ether);
        assertEq(totalFund2, 2 ether);
    }

    function testWithdrawFund() public {
        string memory _productName = "Motorcycle";
        uint256 _targetFund = 1;
        fundAllocation.setAllocation(_productName, _targetFund);
        fundAllocation.addFund{value: 1 ether}(0);
        uint256 balanceBefore = address(this).balance;
        fundAllocation.withdrawFund(0);
        uint256 balanceAfter = address(this).balance;
        assert(balanceBefore < balanceAfter);
        (
            string memory productName,
            uint256 targetFund,
            uint256 totalFund
        ) = fundAllocation.allocations(0);
        assertEq(productName, "");
        assertEq(targetFund, 0);
        assertEq(totalFund, 0);
    }

    function testErrorOnlyOwner() public {
        vm.expectRevert("You're not the owner for this allocation");
        vm.startPrank(msg.sender);
        fundAllocation.setAllocation("Motorcycle", 2);
    }

    function testErrorSetAllocation() public {
        vm.expectRevert("Target fund must greater than 0");
        fundAllocation.setAllocation("Motorcycle", 0);
    }

    function testErrorAddFund1() public {
        // Error "index not found"
        vm.expectRevert("index not found");
        fundAllocation.addFund{value: 1 ether}(5);
    }

    function testErrorAddFund2() public {
        string memory _productName = "Motorcycle";
        uint256 _targetFund = 1;
        fundAllocation.setAllocation(_productName, _targetFund);
        // Error "Fund must greater than 0"
        vm.expectRevert("Fund must greater than 0");
        fundAllocation.addFund{value: 0}(0);
    }

    function testErrorWithdrawFund1() public {
        // Error "index not found"
        vm.expectRevert("index not found");
        fundAllocation.withdrawFund(5);
    }

    function testErrorWithdrawFund2() public {
        string memory _productName = "Motorcycle";
        uint256 _targetFund = 1;
        fundAllocation.setAllocation(_productName, _targetFund);
        // Total fund less than target fund
        vm.expectRevert("Total fund less than target fund");
        fundAllocation.withdrawFund(0);
    }
}
