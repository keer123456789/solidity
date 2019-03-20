pragma solidity ^0.4.24 <0.6.0;
import "./ownable.sol";
import "./power.sol";

contract Role is Power{
    
    struct role{
        uint[] roleId;        //roleID
        string fName;       //father role ID 
        string name;        // role name
    }
    
    uint private roleCount; //角色个数 
    uint private minPower;  //最小权限 
    mapping (string => role) nameToRole;  //角色对应结构体
    
  
   
    event newCreateEvent(uint _roleId, string  _fName, string _name);
   
    function Role() public {
        nameToRole["root"].roleId.push(1);
        nameToRole["root"].fName = "root";
        nameToRole["root"].name = "root";
        roleCount++;
        minPower = 1;
        
    }
    /**
	 * 判断此角色是否存在
	 */
    modifier isExitRole(string _name){
        require(nameToRole[_name].roleId.length>0);
        _;
    }
    
    
    /**
	 * 创建角色，根据父id创建角色id（++），
	 * 如果父id不存在，抛出异常
	 * 如果不是合约创建者调用方法，抛出异常
	 */
    function createRole(uint _roleId, string _fName, string _name) public isExitRole(_fName)  onlyOwner() {
        // require(nameToRole[_name] );
    
        nameToRole[_name].roleId.push(_roleId);
        nameToRole[_name].fName =  _fName;
        nameToRole[_name].name = _name;
        if(_roleId > minPower){
            minPower = _roleId;
        }
        roleCount++;

        emit newCreateEvent(_roleId,  _fName, _name);
    }

    
     //修改角色权限
    function changeRoleId(string _name, uint _newRoleId) onlyOwner() public{
        nameToRole[_name].roleId.push( _newRoleId);
    }
    
    //修改角色的上级角色
    function changeFName(string _name, string _newFName)onlyOwner() isExitRole(_newFName) public{
        nameToRole[_name].fName = _newFName;
    }
    //修改角色的权限和上级角色
    function changeRoleIdAndFNameId(string _name, uint _newRoleId, string _newFName) isExitRole(_newFName) onlyOwner() public{
        nameToRole[_name].roleId.push( _newRoleId);
        nameToRole[_name].fName = _newFName;
    }
    
    
     //获取角色权限信息
    function getRoleInfo(string _name) view public returns(uint[], string, string){
        return (nameToRole[_name].roleId, nameToRole[_name].fName, nameToRole[_name].name);
    }
    
    
    function getRoleCount() view public returns (uint){
        return roleCount;
    }
    
    function getMinPower() view public returns(uint){
        return minPower;
    }
    
  
   
 
    
    
}