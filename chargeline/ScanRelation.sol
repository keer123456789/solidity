pragma solidity >=0.4.24 <0.6.0;

contract ScanRelation{
    struct Relation {
        uint id;
        string scanDate;    //  to confirm
        uint lineId;
        uint adId;
        uint siteId;
        // uint account;  // user who scan the line, don not expose
    }
     // mapping(relation id, Relation) 
    mapping(uint => Relation) public RelationMap;
    // mapping(relation id, relationIndexList index)
    mapping(uint => uint) private relationWithIndex;     
     // list of all relation index, to statistic record length
    uint[] private relationIndexList;                                
     // record relation which scan the same lineId, mapping(lineId, Relation id[])
    mapping(uint=>uint[]) public LineScanStatistic;        
    
    // para: exist, lineId, relationId, index
    event AddScanRelationEvent(bool, uint, uint, uint);  
    
    // if not exist, it will return 0 as default, otherwise return index
    function isRelationExist(uint id) public view returns (uint) {
        if(0 != relationIndexList.length){
            return relationWithIndex[id];  
        }
        return 0;
    }

    //  add scan relation record
    function AddScanRelation(uint id, string scanTime, uint lineId, uint adId, uint siteId) public returns(bool, string) {
        if(0 != isRelationExist(id)){
            // the record has exist
            emit AddScanRelationEvent(false, lineId, id, 0);
            return (false, "failed with relation has exist.");
        }
        // find index to record it 
        uint length = relationIndexList.length;
        uint index;
        if (0 == length){
            index = 1;
        } else {
            uint lastIndex = relationIndexList[length-1];
            index = lastIndex+1;
        }
        relationIndexList.push(index);
        relationWithIndex[id] = index;
        RelationMap[id].id = id;
        RelationMap[id].scanDate = scanTime;
        RelationMap[id].lineId = lineId;
        RelationMap[id].adId = adId;
        RelationMap[id].siteId = siteId;
        LineScanStatistic[lineId].push(id);

        emit AddScanRelationEvent(true, lineId, id, index);
        return (true, "successfully");
    }

    function GetSumScansForLined(uint lineId) public view returns(uint){
        return LineScanStatistic[lineId].length;
    }

    function GetSumScanRelations() public view returns(uint){
        return  relationIndexList.length;
    }
}