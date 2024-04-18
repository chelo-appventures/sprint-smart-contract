pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Sprint {
    address customer;
    address provider;
    address agente;
    bytes32 public hashDocument;
    uint256 public amount;
    uint256 startDate;
    uint256 endDate;
    bool public customerApprove;
    bool public providerApprove;

    enum Status {
        InProcess,
        Complete,
        Cancel
    }
    Status status;

    event DepositFunds(address depositor, uint256 amount);
    event WithdrawFunds(address withdrawer, uint256 amount);
    event CancelSprint(address cancelator);
    event StartDateMet();
    event EndDateMet();
    event isCustomerApproved(bool vote);
    event isProviderApproved(bool vote);
    event VerifyDocumentHash(bool verified);

    modifier onlyCustomer() {
        require(
            msg.sender == customer,
            "Only the Cusomer can call this function"
        );
        _;
    }

    modifier onlyProvider() {
        require(
            msg.sender == provider,
            "Only the provider can call this function"
        );
        _;
    }

    constructor(
        address _customer,
        address _provider,
        address _agente,
        uint256 _amount,
        uint256 _startDate,
        uint256 _endDate,
        bytes32 _hashDocument
    ) {
        customer = _customer;
        provider = _provider;
        agente = _agente;
        amount = _amount;
        startDate = _startDate;
        endDate = _endDate;
        hashDocument = _hashDocument;
        status = Status.InProcess;
        customerApprove = false;
        providerApprove = false;
    }

    function deposit() external payable {
        require(
            msg.sender == customer &&
                msg.value == amount &&
                block.timestamp < startDate,
            "Only the Customer can deposit the exact Amount before the startDate"
        );
        emit DepositFunds(msg.sender, msg.value);
    }

    function withdraw() external {
        require(
            status == Status.Complete && block.timestamp >= endDate,
            "The Sprint is not complete or the endDate is not met yet"
        );
        if (customerApprove && providerApprove) {
            payable(provider).transfer(address(this).balance);
            status = Status.Complete;
            emit WithdrawFunds(provider, address(this).balance);
        } else if (!customerApprove && !providerApprove) {
            payable(customer).transfer(address(this).balance);
            status = Status.Cancel;
            emit CancelSprint(customer);
        } else {
            payable(agente).transfer(address(this).balance);
            status = Status.Complete;
            emit WithdrawFunds(agente, address(this).balance);
        }
    }

    function cancel() external onlyCustomer {
        require(
            status == Status.InProcess && block.timestamp > endDate,
            "The Sprint is not InProcess or the endDate is not met yet"
        );
        payable(customer).transfer(address(this).balance);
        status = Status.Cancel;
        emit CancelSprint(customer);
    }

    function approveFromCustomer(bool _vote) external onlyCustomer {
        require(status == Status.Complete, "The Sprint is not complete yet");
        customerApprove = _vote;
        emit isCustomerApproved(_vote);
    }

    function approveFromProvider(bool _vote) external onlyProvider {
        require(status == Status.Complete, "The Sprint is not complete yet");
        providerApprove = _vote;
        emit isProviderApproved(_vote);
    }

    function verifyDocumentHash(bytes32 _hash) external view returns (bool) {
        return _hash == hashDocument;
    }

    function getStatus() external view returns (Status) {
        return status;
    }

    function getStartDate() external view returns (uint256) {
        return startDate;
    }

    function getEndDate() external view returns (uint256) {
        return endDate;
    }

    function verifyStartDateMet() external {
        require(block.timestamp >= startDate, "The start date is not met yet");
        emit StartDateMet();
    }

    function verifyEndDateMet() external {
        require(block.timestamp >= endDate, "The end date is not met yet");
        emit EndDateMet();
    }
}
