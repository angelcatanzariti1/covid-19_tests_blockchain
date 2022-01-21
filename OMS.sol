// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <=0.8.11;
pragma experimental ABIEncoderV2;

contract OMS_COVID{

    //Owner address
    address public OMS;

    //Constructor
    constructor(){
        OMS = msg.sender;
    }

    //Authorization status for health centers to create their own smart contract
    mapping(address => bool) HealtCentersStatus;

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








}