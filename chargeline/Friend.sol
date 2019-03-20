pragma solidity ^0.4.24 <0.6.0;
contract Friend{
     uint private sum =0;
    struct FriendInfo{
        uint id;
        string username;
        string useropenid;
        string date;
    }  
    //mapping(id,Friend)
    mapping(uint => FriendInfo) private FriendMap;
    // mapping(id, index)
    mapping(uint => uint) private openIdWithIndex;             // mapping(SharedLine_id, SharedLineIdList_id)
    uint[] private openIndexList;

    
    event addFriendEvent(string openid,string username,string date,string result);
   
    function isExist(string _openid) public view returns(bool){
        uint total = openIndexList.length;
        if(total==0){
            return(false);
        }else{
            for(uint i = 1; i <= total; i++){
                if(compareString(FriendMap[i].useropenid , _openid)){
                    return (true);
                }
            }
        }
      
    }
    function addFriend(string _useropenid,string _username,string _date)public  returns(bool result) {
        if(isExist(_useropenid)){
            emit addFriendEvent("","","", "Friend has exit!!");
            return (false);
        }
        sum=sum+1;
         
        uint length = openIndexList.length;
        uint index;
        if (0 == length){
            index = 1;
        }else{
            uint lastIndex = openIndexList[length-1];   
            index = lastIndex+1;
        }
        openIndexList.push(index);
        openIdWithIndex[sum] = index;
        FriendMap[sum].useropenid = _useropenid;
        FriendMap[sum].username = _username;
        FriendMap[sum].date = _date;
        FriendMap[sum].id = sum;
        
        emit addFriendEvent(_useropenid,_username,_date, "successfully");
        return (true);

    }
    
    function getFriendTotal()public view returns(uint result){
        return openIndexList.length;
    }
    
    function getFriendById(uint id)public view returns(bool result,string message,string _openid,string _username,string _date){
        return(true,"success",FriendMap[id].useropenid,FriendMap[id].username,FriendMap[id].date);
    }
    //=true
    function compareString(string a, string b) internal returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(a) == keccak256(b);
        }
    }
}