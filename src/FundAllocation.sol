// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
    @title FundAllocation
    @author dkrsnadhe
*/

contract FundAllocation {
    address public owner;

    /*
     * @title Constructor
     * @notice Initializes the contract's owner.
     * @dev This constructor is triggered upon deployment and sets the initial owner of the contract
     * to the address that deploys the contract.
     */
    constructor() {
        owner = msg.sender;
    }

    /*
     * @title Allocation
     * @notice Struct to define product allocation details.
     * @dev This struct defines the characteristics of an allocation for a product,
     * including the product's name, target fund, and total fund allocated.
     * It consists of a product name represented as a string, the target fund amount,
     * and the total fund allocated for that product.
     */
    struct Allocation {
        string productName;
        uint targetFund;
        uint totalFund;
    }

    /*
     * @title allocations
     * @notice Array to store multiple instances of Allocation.
     * @dev This array stores multiple instances of the Allocation struct,
     * holding details about various product allocations.
     * It is publicly accessible, allowing external entities to access
     * information about different product allocations.
     */
    Allocation[] public allocations;

    /*
     * @title SetFund
     * @notice Event emitted upon setting fund allocation details for a product.
     * @dev This event is triggered when fund allocation details are set for a specific product.
     * It captures the address of the owner, the product name, target fund amount, and the timestamp.
     * @param owner The address of the entity setting the fund allocation.
     * @param productName The name of the product for which the fund allocation is set.
     * @param targetfund The target fund amount allocated for the product.
     * @param time The timestamp when the fund allocation is set.
     */
    event SetFund(
        address indexed owner,
        string productName,
        uint targetfund,
        uint time
    );

    /*
     * @title AddFund
     * @notice Event emitted upon adding funds to an existing allocation.
     * @dev This event is triggered when additional funds are added to an existing product allocation.
     * It captures the address of the owner, the product name, the additional fund amount, and the timestamp.
     * @param owner The address of the entity adding funds to the allocation.
     * @param productName The name of the product for which the funds are added.
     * @param addfund The amount of additional funds added to the allocation.
     * @param time The timestamp when the funds are added.
     */
    event AddFund(
        address indexed owner,
        string productName,
        uint addfund,
        uint time
    );

    /*
     * @title WithdrawFund
     * @notice Event emitted upon withdrawing funds from an allocation.
     * @dev This event is triggered when funds are withdrawn from a product allocation.
     * It captures the address of the owner, the product name, and the timestamp when the withdrawal occurs.
     * @param owner The address of the entity withdrawing funds from the allocation.
     * @param productName The name of the product from which funds are withdrawn.
     * @param time The timestamp when the funds are withdrawn.
     */
    event WithdrawFund(address indexed owner, string productName, uint time);

    /*
     * @title onlyOwner
     * @notice Modifier to restrict access to the contract's owner.
     * @dev This modifier restricts access to functions by allowing only the contract owner
     * to execute the function. If the caller is not the owner, it reverts with a specific error message.
     */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You're not the owner for this allocation"
        );
        _;
    }

    /*
     * @title receive
     * @notice Fallback function to receive Ether.
     * @dev This function is a special function that is automatically invoked
     * when the contract receives Ether without specifying a function to call.
     * It allows the contract to receive Ether and perform any necessary actions.
     * This function is marked as external and payable, indicating that it can receive Ether.
     */
    receive() external payable {}

    /*
     * @title setAllocation
     * @notice Function to set a new fund allocation for a product.
     * @dev This function allows the contract owner to set a new fund allocation
     * for a specific product. It requires the product name and the target fund amount,
     * which must be greater than 0. The target fund amount is converted to the smallest
     * unit of Ether (wei) and stored in the Allocation struct. It emits a SetFund event
     * with details about the owner, product name, converted target fund, and timestamp.
     * @param _productName The name of the product for fund allocation.
     * @param _targetFund The target fund amount for the product.
     */
    function setAllocation(
        string calldata _productName,
        uint _targetFund
    ) external onlyOwner {
        require(_targetFund > 0, "Target fund must greater than 0");

        uint256 targetFundConverter = _targetFund * 10 ** 18;
        Allocation memory newAllocation = Allocation(
            _productName,
            targetFundConverter,
            0
        );

        allocations.push(newAllocation);

        emit SetFund(
            msg.sender,
            _productName,
            targetFundConverter,
            block.timestamp
        );
    }

    /*
     * @title addFund
     * @notice Function to add funds to an existing fund allocation.
     * @dev This function allows the contract owner to add additional funds
     * to an existing fund allocation for a specific product identified by its index.
     * It requires the index of the product in the allocations array, ensuring
     * the index exists and the target fund is greater than 0. The function also
     * requires the added fund amount to be greater than 0. Upon successful addition
     * of funds, it updates the total fund allocated for that product and emits an
     * AddFund event with details about the owner, product name, added fund amount,
     * and timestamp.
     * @param _index The index of the product in the allocations array.
     */
    function addFund(uint _index) external payable onlyOwner {
        require(_index <= allocations.length, "index not found");
        require(
            allocations[_index].targetFund > 0,
            "Not seen any product in this index"
        );
        require(msg.value > 0, "Fund must greater than 0");

        allocations[_index].totalFund += msg.value;

        emit AddFund(
            msg.sender,
            allocations[_index].productName,
            msg.value,
            block.timestamp
        );
    }

    /*
     * @title withdrawFund
     * @notice Function to withdraw funds from a fund allocation.
     * @dev This function enables the contract owner to withdraw funds from an existing
     * fund allocation for a specific product identified by its index. It requires the
     * index of the product in the allocations array, ensuring the index exists and the
     * total fund allocated for the product is equal to or greater than the target fund.
     * Upon successful withdrawal, the total fund for that product is transferred to the
     * contract owner's address. The allocation entry for that product is then deleted from
     * the allocations array, and an WithdrawFund event is emitted with details about
     * the owner, product name, and timestamp.
     * @param _index The index of the product in the allocations array.
     */
    function withdrawFund(uint _index) external onlyOwner {
        require(_index <= allocations.length, "index not found");
        require(
            allocations[_index].totalFund >= allocations[_index].targetFund,
            "Total fund less than target fund"
        );

        (bool success, ) = msg.sender.call{
            value: allocations[_index].totalFund
        }("");
        require(success, "Transaction failed");

        delete allocations[_index];

        emit WithdrawFund(
            msg.sender,
            allocations[_index].productName,
            block.timestamp
        );
    }

    /*
     * @title getAllocation
     * @notice Function to retrieve allocation details for a product.
     * @dev This function allows external entities to view the allocation details
     * for a specific product identified by its index in the allocations array.
     * It returns the Allocation struct containing details such as the product name,
     * target fund, and total fund allocated for the specified product.
     * @param _index The index of the product in the allocations array.
     * @return Allocation The struct containing allocation details for the specified product.
     */
    function getAllocation(
        uint _index
    ) external view returns (Allocation memory) {
        return allocations[_index];
    }
}
