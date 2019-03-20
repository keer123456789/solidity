pragma solidity ^0.4.24 <0.6.0;

import "./ownable.sol";

contract Power is Ownable{
    struct power{
        uint powerID;
        bool isUse;
        string powerName;
    }
    mapping(uint => power) powerIDTOpower;
     
    function Power() public{
        powerIDTOpower[1].powerID=1;
        powerIDTOpower[1].powerName="root";
        powerIDTOpower[1].isUse=true;
    }
    
    
   
    modifier exit(uint _powerID){
        require(powerIDTOpower[_powerID].powerID == _powerID);
        _;
    }
    
    modifier unExit(uint _powerID){
        require(powerIDTOpower[_powerID].powerID != _powerID);
        _;
    } 
   
    modifier use(uint _powerID){
         require(powerIDTOpower[_powerID].isUse);
        _;
    }
    modifier unUse(uint _powerID){
         require(!powerIDTOpower[_powerID].isUse);
        _;
    }
   
    function addPower(uint _powerID, string _powerName) public unExit(_powerID){
        powerIDTOpower[_powerID].powerID = _powerID;
        powerIDTOpower[_powerID].powerName = _powerName;
        powerIDTOpower[_powerID].isUse = true;
    }
    
    function changePowername(uint _powerID,string _newName)public exit(_powerID) use(_powerID){
        powerIDTOpower[_powerID].powerName = _newName;
    }
    
    function changeUnUse(uint _powerID)public exit(_powerID) use(_powerID){
         powerIDTOpower[_powerID].isUse = false;
    }
    
    
}