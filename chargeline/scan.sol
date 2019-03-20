pragma solidity ^0.4.24 <0.6.0;
contract scan{
    uint private sum =0;
    struct ScanInfo{
        uint id;
        string ipadd;
        string macvalue;
        string date;
    }  
    
    mapping(uint => ScanInfo) public ScanInfoMap;
    // mapping(Id, index)
    mapping(uint => uint) private IDWithIndex;             // mapping(SharedLine_id, SharedLineIdList_id)
    uint[] private idIndexList;

    
    event addInfoEvent(uint id,string ipadd,string macvalue,string date);
   
    function isExist(uint _id) public view returns(uint){
        if(0 != idIndexList.length) {
            return IDWithIndex[_id];
        }
        return 0;
    }
    function AddInfo(string _ipadd,string _macvalue,string _date)public returns(bool result){
        sum=sum+1;
        uint length = idIndexList.length;
        uint index;
        if (0 == length){
            index = 1;
        }else{
            uint lastIndex = idIndexList[length-1];
            index = lastIndex+1;
        }
        idIndexList.push(index);
        IDWithIndex[sum] = index;
        ScanInfoMap[sum].ipadd = _ipadd;
        ScanInfoMap[sum].id = sum;
        ScanInfoMap[sum].macvalue =  _macvalue;
        ScanInfoMap[sum].date= _date;
        emit addInfoEvent(ScanInfoMap[sum].id,ScanInfoMap[sum].ipadd,ScanInfoMap[sum].macvalue,ScanInfoMap[sum].date);
        return (true);
    }
    
    function getInfoTotal()public view returns(uint result){
        return idIndexList.length;
    }
    
    function getInfoByID(uint _id)public view returns(bool result,string message,string _ipadd,string _macvalue,string _date){
        if ( 0 == isExist(_id)){
            return (false,"line not exist", "", "", "");
        }
        return(true,"success",ScanInfoMap[_id].ipadd,ScanInfoMap[_id].macvalue,ScanInfoMap[_id].date);
    }
    
}
