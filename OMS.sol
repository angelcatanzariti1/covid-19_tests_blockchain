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


}