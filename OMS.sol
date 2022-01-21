// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <=0.8.11;
pragma experimental ABIEncoderV2;

//------------------------------------- OMS ---------------------------------------------

contract OMS_COVID{

    //Owner address
    address public OMS;

    //Constructor
    constructor(){
        OMS = msg.sender;
    }

    //Authorization status for health centers to create their own smart contract
    mapping(address => bool) public HealthCentersStatus;

    //Mapping to store each Health Center's address
    mapping(address => address) public health_centers_contracts;

    //Events
    event NewHealthCenter(address);
    event NewContract(address, address); //contract, owner
    event NewAccessRequest(address);
    
    //Modifier to allow only the owner to call certain functions
    modifier OwnerOnly(address _address){
        require(_address == OMS, "Forbidden.");
        _;
    }

    //Array to store access Requests
    address[] requests;

    //Request access
    function RequestAccess() public{
        //Store request
        requests.push(msg.sender);

        //Event
        emit NewAccessRequest(msg.sender);
    }

    //View Access Requests (OMS only)
    function ViewRequests() public view OwnerOnly(msg.sender) returns(address[] memory){
        return requests;
    }

    //Authorize new Health Centers
    function HealthCenters(address _healthCenter) public OwnerOnly(msg.sender){
        //Set status to HC
        HealthCentersStatus[_healthCenter] = true;

        //Emit event
        emit NewHealthCenter(_healthCenter);
    }

    //Check authorization status
    function AuthorizationStatus() public view returns(bool){
        return HealthCentersStatus[msg.sender];
    }

    //Factory to create smart contracts for each health center
    function FactoryHealthCenter() public{
        //Only authorized HC must be able to run this
        require(HealthCentersStatus[msg.sender], "Health Center not authorized.");

        //Generate smart contract
        address HC_contract = address(new HealthCenter(msg.sender));

        //Store contract address in array
        health_centers_contracts[msg.sender] = HC_contract;

        //Event
        emit NewContract(HC_contract, msg.sender);

    }
}

//------------------------------------- HEALTH CENTERS ---------------------------------

contract HealthCenter{

    //Initial declarations
    address public HC_address;
    address public ContractAddress;

    //Constructor
    constructor(address _address){
        HC_address = _address;
        ContractAddress = address(this);
    }

    //Results struct
    struct COVIDTestResults{
        uint256 testID;
        uint256 date;
        bool result;
        string file_IPFS;
    }

    /*
        Patient => results array
        A patient's address hash is stored.
        a single patient can have multiple tests stored, identified by ID and date
        dates are managed as timestamps, a conversion is needed in frontend
    */
    mapping(bytes32 => COVIDTestResults[]) PatientResults;

    //Events
    event NewResult(bool, string);

    //Restrict functions to health center
    modifier HCOnly(address _address){
        require(_address == HC_address, "Forbidden.");
        _;
    }

    //Test results (date in unix timestamp, convert in frontend)
    function LoadCOVIDTestResults(uint256 _testID, uint256 _testDate, string memory _patientID, bool _testResult, string memory _IPFScode) public HCOnly(msg.sender){
        //Patient's ID hash
        bytes32 hash_patientID = keccak256(abi.encodePacked(_patientID));

        //Patient -> result
        PatientResults[hash_patientID].push(COVIDTestResults(_testID, _testDate, _testResult, _IPFScode));

        //Event
        emit NewResult(_testResult, _IPFScode);
    }

    //View a patien't result
    function MyResults(string memory _patientID) public view returns(COVIDTestResults[] memory){
        //Patient's ID hash
        bytes32 hash_patientID = keccak256(abi.encodePacked(_patientID));

        //Check if the patient's results were loaded
        require(PatientResults[hash_patientID].length > 0, "No results available.");

        return(PatientResults[hash_patientID]);        
    }



}