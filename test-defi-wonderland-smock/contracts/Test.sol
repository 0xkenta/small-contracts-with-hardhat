pragma solidity  0.8.17;

contract Test {
    uint256 public number;
    mapping(address => uint256) public numbers;

    event NumberUpdated(uint256 previousNr, uint256 newNr);

    function setNumber(uint256 _newNumber) external {
        uint256 previousNumber = number;
        number = _newNumber;

        numbers[msg.sender] = _newNumber;
        
        emit NumberUpdated(previousNumber, _newNumber);
    }

    function getNumber() external view returns (uint256) {
        return number;
    }
}