pragma solidity ^0.4.24 <0.6.0;

import "./ownable.sol";

contract Power is Ownable{
    struct power{
        uint powerID;
        bool isUse;
        string powerName;
        string powerInfo;
    }
    mapping(uint => power) powerIDTOpower;
    uint private powerCount;
    uint[] private powerIds;
    function Power() public{
        powerIDTOpower[1].powerID=1;
        powerIDTOpower[1].powerName="root";
        powerIDTOpower[1].isUse=true;
        powerIDTOpower[1].powerInfo="root";
        powerIds.push(1);
        powerCount++;
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
   
    function addPower(uint _powerID, string _powerName,string _powerInfo) external unExit(_powerID) {
        powerIDTOpower[_powerID].powerID = _powerID;
        powerIDTOpower[_powerID].powerName = _powerName;
        powerIDTOpower[_powerID].isUse = true;
        powerIDTOpower[_powerID].powerInfo = _powerInfo;
        powerIds.push(_powerID);
        powerCount++;
    }
    
    function changePowername(uint _powerID,string _newName)external exit(_powerID) use(_powerID){
        powerIDTOpower[_powerID].powerName = _newName;
    }
    
    function changeUnUse(uint _powerID)external exit(_powerID) use(_powerID){
         powerIDTOpower[_powerID].isUse = false;
    }
    function changePowerInfo(uint _powerID,string _powerInfo)external exit(_powerID) use(_powerID){
         powerIDTOpower[_powerID].powerInfo = _powerInfo;
    }
    function getPowerInfoBypowerId(uint _powerID)external view returns(uint _powerId, string _powerName, string _powerInfo, bool _use){
        return (powerIDTOpower[_powerID].powerID,powerIDTOpower[_powerID].powerName, powerIDTOpower[_powerID].powerInfo, powerIDTOpower[_powerID].isUse);
    }
    
    function getPowerTotal()external view returns(uint){
        return powerCount;
    }
    
    function getAllPowerID()external view returns(uint[]){
        return (powerIds);
    }
    
    
}