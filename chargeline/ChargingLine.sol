pragma solidity >=0.4.24 <0.6.0;

contract ChargingLine{

    struct Line{
        uint lineId;             // key
        string macAddr;
    }

    // mappping(lineId, Line)
    mapping(uint => Line) public LinesMap;
    // mapping(lineId, index)
    mapping(uint => uint) private lineWithIndex;             // mapping(SharedLine_id, SharedLineIdList_id)
    uint[] private lineIndexList;

    event AddLineEvent(bool status, uint lineId, string macAddr, string errors);
    event UpdateLineEvent(uint lineId, string macAddr);

    function isExist(uint lineId) public view returns(uint){
        if(0 != lineIndexList.length) {
            return lineWithIndex[lineId];
        }
        return 0;
    }
    
    function AddLine(uint lineId, string macAddr) public returns(bool result,  string error) {
        if ( 0 != isExist(lineId)){
            emit AddLineEvent(false, lineId, macAddr, "failed with line record has exist.");
            return (false,  "line record has exist.");
        }
        
        uint length = lineIndexList.length;
        uint index;
        if (0 == length){
            index = 1;
        }else{
            uint lastIndex = lineIndexList[length-1];
            index = lastIndex+1;
        }
        lineIndexList.push(index);
        lineWithIndex[lineId] = index;
        LinesMap[lineId].lineId = lineId;
        LinesMap[lineId].macAddr = macAddr;
        
        emit AddLineEvent(true, lineId, macAddr, "successfully");
        return (true, "successfully" );
    }

    function GetSharedLine(uint lineId) public view returns (bool result, uint linesId, string macAddr, string errors){
        if ( 0 == isExist(lineId)){
            return (false, lineId, "", "line not exist");
        }
        return (true, LinesMap[lineId].lineId, LinesMap[lineId].macAddr, "successfully");
    }
    
    function SharedLineNumber() public view returns(uint){
        return lineIndexList.length;
    }

    function updateSharedLine(uint lineId, string macAddr) public returns(bool result, string error){
        if ( 0 == isExist(lineId)){
            return (false, "line not exist");
        }
        LinesMap[lineId].macAddr = macAddr;
        emit UpdateLineEvent(lineId, macAddr);
        return (true, "");
    }
}