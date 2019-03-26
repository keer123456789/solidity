pragma solidity ^0.4.24;

import "./Role.sol";
contract User is Role{
   uint private userCount;
    struct user{
        uint8 status;
        address add;
        string roleName;
		string email;
        string userId;
        string fUserId;
    }
    
    mapping (address => user) addToUser;
    mapping (string => address) userIdToAddress;
    address[] private adds;
    
    function () public{
        addToUser[msg.sender].status = 2;
        addToUser[msg.sender].add = msg.sender;
        addToUser[msg.sender].roleName = "root";
        addToUser[msg.sender].userId = "admin";
        addToUser[msg.sender].email = "1073441240@qq.com";
        addToUser[msg.sender].fUserId = "root";
        userIdToAddress["admin"] = msg.sender;
        adds.push(msg.sender);
        userCount++;
    }
    
    //检查角色和上级用户的角色是否匹配
    modifier checkSame(string _roleName, string _fUserId){
        require(_compaireString(addToUser[userIdToAddress[_fUserId]].roleName,nameToRole[_roleName].fName));
        _;
    }
    
    modifier notAddress(address _address){
        require(addToUser[_address].add!= msg.sender);
        _;
    }
    
    event newRegisterUser(string _userId, string _fUserId, address add, uint8 status);
    event userChange(address _address, uint8 status );
    
    
    //用户注册,等待管理员同意
    function registerUser(string _userId,string _email) public  notAddress(msg.sender) returns(address, string, uint8){
        addToUser[msg.sender].add = msg.sender;
        addToUser[msg.sender].userId = _userId;
        addToUser[msg.sender].status = 1;
		addToUser[msg.sender].email = _email;
        adds.push(msg.sender);
        userIdToAddress[_userId] = msg.sender;
        emit newRegisterUser(addToUser[msg.sender].userId, "",addToUser[msg.sender].add, addToUser[msg.sender].status);
        userCount++;
        return (addToUser[msg.sender].add, addToUser[msg.sender].userId, addToUser[msg.sender].status);
    }
    
    //管理员通过注册申请
    function enroll(address _address, string _roleName, string _fUserId) public onlyOwner notAddress(_address) checkSame(_roleName, _fUserId) returns(address, string, string, uint8) {
        require(addToUser[_address].status == 1);
        addToUser[_address].roleName = _roleName;
        addToUser[_address].status = 2 ;
        addToUser[_address].fUserId = _fUserId;
        emit userChange(_address, addToUser[_address].status);
        return (addToUser[_address].add, addToUser[_address].userId, addToUser[_address].roleName, addToUser[_address].status);    
    }
    
    //管理员注销用户
    function deleteUser(address _address)public onlyOwner notAddress(_address)  returns( uint8){
        require(addToUser[_address].status == 2);
        addToUser[_address].status = 3 ;
        emit userChange(_address,addToUser[_address].status);
        return ( addToUser[_address].status); 
    }
    
    //改变用户ID
    function changeUserId(address _address, string _newUserId) public onlyOwner returns(string ){
        require(addToUser[_address].status == 2);
        addToUser[_address].userId = _newUserId;
        emit changeStatus(true);
        return (addToUser[_address].userId);
    }
    //修改用户的角色
    function changeRoleName(address _address, string _roleName)onlyOwner public returns(string){
        require(addToUser[_address].status == 2);
        address add = userIdToAddress[addToUser[_address].fUserId];
        string storage fRoleName = addToUser[add].roleName;
        require(_compaireString(fRoleName,nameToRole[_roleName].fName));
        addToUser[_address].roleName = _roleName;
        return (addToUser[_address].roleName);
    }
    //修改用户的上级用户
    function changeFUserID(address _address, string _fUserId) onlyOwner public returns(string){
        require(addToUser[_address].status == 2);
        address a = userIdToAddress[_fUserId];
        require(_compaireString(nameToRole[addToUser[a].roleName].name,nameToRole[addToUser[_address].roleName].fName));
        addToUser[_address].fUserId = _fUserId;
        emit changeStatus(true);
        return (addToUser[_address].fUserId); 
    }
    
    function changeEmail(address _address, string _email)public returns(string){
        addToUser[_address].email = _email;
        emit changeStatus(true);
        return (addToUser[_address].email);
    }
    
    //比较两个字符串是否相等
    function _compaireString(string s1, string s2)private pure returns(bool){
        if(keccak256(bytes(s1)) == keccak256(bytes(s2))){
            return true;
        }else{
            return false;
        }
    }
    
    //查询用户的信息
    function getUserInfo(string userId) public view returns(string, string, string, address, uint8){
        return (addToUser[userIdToAddress[userId]].userId, addToUser[userIdToAddress[userId]].fUserId, addToUser[userIdToAddress[userId]].roleName, userIdToAddress[userId],addToUser[userIdToAddress[userId]].status);
    }
    
    //获得用户的权限
    function getPower(string userId)public view returns(uint[]){
        return nameToRole[addToUser[userIdToAddress[userId]].roleName].roleId;
    }
    //获得所有用户地址 
    function getUserCount()public view returns(address[]){
        return adds;
    }
    function getUserInfoByAddress(address _address)public view returns(string, string,string, string, address, uint8 ){
        return (addToUser[_address].userId, addToUser[_address].fUserId, addToUser[_address].roleName, addToUser[_address].email, addToUser[_address].add, addToUser[_address].status);
    }
}
    