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
    mapping(address => bool) HealthCentersStatus;

    //Address array to store validated health centers contracts
    address[] public health_centers_contracts;

    //Events
    event NewHealthCenter(address);
    event NewContract(address, address); //contract, owner
    
    //Modifier to allow only the owner to call certain functions
    modifier OwnerOnly(address _address){
        require(_address == OMS, "Forbidden.");
        _;
    }


    //Authorize new Health Centers
    function HealthCenters(address _healthCenter) public OwnerOnly(msg.sender){
        //Set status to HC
        HealthCentersStatus[_healthCenter] = true;

        //Emit event
        emit NewHealthCenter(_healthCenter);
    }

    //Factory to create smart contracts for each health center
    function FactoryHealthCenter() public{
        //Only authorized HC must be able to run this
        require(HealthCentersStatus[msg.sender], "Health Center not authorized.");

        //Generate smart contract
        address HC_contract = address(new HealthCenter(msg.sender));

        //Store contract address in array
        health_centers_contracts.push(HC_contract);

        //Event
        emit NewContract(HC_contract, msg.sender);

    }
}

//------------------------------------- HEALTH CENTERS ---------------------------------

contract HealthCenter{

    address public HC_address;
    address public ContractAddress;

    //Constructor
    constructor(address _address){
        HC_address = _address;
        ContractAddress = address(this);
    }

}