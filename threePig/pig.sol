pragma solidity >=0.4.22 <0.6.0;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


///����ERC721Э��Ľӿ�
contract ERC721 {
    // Required methods
    //���ص�ǰtoken������
    function totalSupply() public view returns (uint256 total);
    //���ػ��ĳ��������ַӵ�еĴ�������
    function balanceOf(address _owner) public view returns (uint256 balance);
    //����ĳ���ҵ������ߵĵ�ַ
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    //���������߽�����ҷ��͸���һ���û��ĵ�ַ
    function transfer(address _to, uint256 _tokenId) external;

    // Events
    event Log_transfer(address from, address to, uint256 tokenId, int8 status);

    function tokensOfOwner(address _owner) external view returns (uint256[] memory tokenIds);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}



//Ownable ��ͬ���������ߵ�ַ�����ṩ������Ȩ���ƹ��ܣ�����ˡ��û�Ȩ�ޡ���ʵ��
contract Ownable{
    address public owner;

    //�ù��캯������Լ�������ߡ�����Ϊ�����Լ�ĵ�ַ��
    constructor()public{
        owner = msg.sender;
    }

    //������������������κ��ʻ����á�
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    //����ǰ�����߽���ͬ�Ŀ���Ȩת�Ƹ�newOwner��
    function transferOwnership(address newOwner)public onlyOwner{
        if(newOwner != address(0)){
            owner = newOwner;
        }
    }
}



contract pigAccessControl is Ownable{

    /**
     *government�������·���������ɫ��
     *���������Ϊ��pigcore���캯���д������ܺ�Լ�ĵ�ַ��
     */
     
    //��ɫ 
    enum Role{sell, buy}
    //ִ��ÿ����ɫ��Э���ַ
    User public user;

    struct User{
        address roleAddress;
        uint256 roleId;
        string location;
        Role role;
    }


    mapping (address => User) public SellMap;
    mapping (address => User) public BuyMap;


    //����sell���ܵķ������η�
    modifier onlySell(){
        require(msg.sender == user.roleAddress);
        _;
    }

    //����buy���ܵķ������η�
    modifier onlyBuy(){
        require(msg.sender == user.roleAddress);
        _;
    }


    function newUser(uint256 ID, string memory location, Role role)public returns(bool, address,Role, string memory){
        if(role == Role.sell){
            user.roleAddress = msg.sender;
            user.roleId = ID;
            user.location = location;
            user.role = role;
            SellMap[msg.sender] = user;
        }else if(role == Role.buy){
            user.roleAddress = msg.sender;
            user.roleId = ID;
            user.location = location;
            user.role = role;
            BuyMap[msg.sender] = user;
        }else{
            return (false,user.roleAddress, user.role,"the actor is not belong");
        }
        if(user.roleId != 0x0){
            return (true, user.roleAddress, user.role,"this ID has been occupied!");
        }
    }

}



/// ����pig��ʲô��������pig�Ļ�������
contract pigBase is pigAccessControl{
    
    using SafeMath for uint256;
    
    //ֻҪ�µ�����֣��ͻᴥ��Birth�¼���
    event Birth(uint256 pigID, address owner, uint64 birthTime, uint256 breed, uint256 weight,  uint256 id,int8 status);
    //ÿ��ת��������Ȩʱ���ᴥ����
    event Transfer(address from, address to, uint256 tokenId, int8 status);

    /**
     * pig�ṹ��
     */
    struct pig{
        //�����ߵ�ַ
        address currentAddress;
        //����ʱ��
        uint64 birthTime;
        //Ʒ��
        uint256 breed;
        //����
        uint256 weight;
        //bigchaindb �еĵ�721ID
        uint256 id;
        // ״̬   0������ 1��ȷ�Ϲ���  2���ѷ��� 3�����ջ� 4�����ܹ��� 
        int8 status;
        //����
        int8 pigHouse;
    }

    //������������pig�ṹ������,ÿֻpig��ID�Ǵ������������
    pig[] pigs;

    //��pigID�����˵ĵ�ַ��ӳ�䡣
    mapping(uint256 => address) public pigIndexToOwner;
    //�����˵�ַ����ӵ�е���ĸ�����ӳ��
    mapping(address => uint256) public ownershipTokenCount;


    //����һֻ������˵�ַ
    function _transfer(address _from, address _to, uint256 _tokenId)internal{
        ownershipTokenCount[_to]++;
        // ��������
        pigIndexToOwner[_tokenId] = _to;
        // ��Ҫ���ԭ��������0x0�����
        if(_from != address(0)){
            ownershipTokenCount[_from]--;
        }
    }

    /**
     * һ�ִ���newpig���洢�����ڲ�������
     * �˷����������κμ�飬ֻӦ����֪����������Чʱ����,�����������Ҫ��֤��ȷ��
     * ������Birth�¼���Transfer�¼���
     */
    function createPig (
        uint256 _breed,
        uint256 _weight,
        uint256 _id,
        int8 _pigHouse
    ) external returns (uint256) {
        for(int8 i = 0; i <= 9; i++){
            pig memory i = pig({
            currentAddress : msg.sender,
            birthTime : uint64(now),
            breed : _breed,
            weight : _weight,
            id : _id,
            status : 0,
            pigHouse : _pigHouse
            }); 

        uint256 newPigID = pigs.push(i) - 1;

        // ����Birth�¼�
        emit Birth(newPigID, msg.sender,uint64(now), _breed, _weight, _id,0);

        // �������ˣ����ҷ���Transfer�¼�
        // ��ѭERC721�ݰ�
        _transfer(address(0), msg.sender, newPigID);
        emit Transfer(address(0), msg.sender, newPigID, i.status);
        }
        
    }
}

/// ��Լ�̳���KittyBase��ERC721ʵ����ERC721�ӿ��ж���ķ�����������������Լ�����ƺ͵�λ
contract pigOwnership is pigBase,ERC721{

    using SafeMath for uint256;
    
    //����ERC721��Name��symbol���ǲ��ɷָ��Token
    string public constant name = "Pig��s Life";
    string public constant symbol = "PIE";

    bytes4 constant InterfaceSignature_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)')) ^
    bytes4(keccak256('tokenMetadata(uint256,string)'));

    //�ж��Ƿ����Լ�֧�ֵ�ERC721��ERC165�ӿ�
    function supportsInterface(bytes4 _interfaceID)external view returns(bool){
        return((_interfaceID == InterfaceSignature_ERC721) || (_interfaceID == InterfaceSignature_ERC165));
    }

    // �ж�һ����ַ�Ƿ���������ˡ�
    // _currentAddress �жϵ��û��ĵ�ַ
    function _owns(address _currentAddress, uint256 _tokenId) internal view returns (bool){
        return pigIndexToOwner[_tokenId] == _currentAddress;
    }


    //�����ض���ַӵ�е����������
    function balanceOf(address _owner)public view returns(uint256 count){
        return ownershipTokenCount[_owner];
    }

    //���ȷ�Ϲ��򣬲�תǮ 0-1 
    function confirmBuy(uint256 _tokenId)external payable {
        require(pigs[_tokenId].status == 0);
            pigs[_tokenId].status = 1;
            emit Transfer(msg.sender, address(this), _tokenId, pigs[_tokenId].status);
    }
   
    //����ת����һ����ַ��Ҫȷ��ERC-721���ݣ�������ܶ�ʧ��1-2
    function transfer(address _to, uint256 _tokenId) external {
        // ��ֹת�Ƶ�0x0
        require(_to != address(0));
        require(_to !=address(this));
        // ֻ��ת���Լ�����
        require(_owns(msg.sender,_tokenId));
        require(pigs[_tokenId].status == 1);
        
        // �޸����ˣ�����Transfer�¼�
            pigs[_tokenId].status = 2;
            _transfer(msg.sender, _to, _tokenId);
            pig storage Pig = pigs[_tokenId];
            Pig.currentAddress = pigIndexToOwner[_tokenId];
            
            emit Transfer(msg.sender, _to, _tokenId, pigs[_tokenId].status);
       
    }
    
    //��Ҹı�״̬���� 2-3
    function changeStatus(address payable _to,uint256 _tokenId)external payable returns (int8){
        require(pigs[_tokenId].status == 2);
        pigs[_tokenId].status = 3;
        _to.transfer(10 ether);
        emit Transfer(address(this), _to, _tokenId, pigs[_tokenId].status);
        
    }


    //���ص�ǰ�������
    function totalSupply()public view returns(uint){
        return pigs.length;
    }

    //����һ���������
    function ownerOf(uint256 _tokenId)external view returns(address owner){
        owner = pigIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    // ����һ�����˵�����б�
    function tokensOfOwner(address _owner)external view returns(uint256[] memory ownerTokens){
        // ���_ownerӵ�е��������
        uint256 tokenCount = balanceOf(_owner);

        if(tokenCount == 0){
            // ���û������Ϊ��
            return new uint256[](0);
        }else{
            //��������ʼ��һ������ֵresult������ΪtokenCount
            uint256[] memory result = new uint256[](tokenCount);
            // ��ǰ�����������
            uint256 tolalPigs = totalSupply();
            // ѭ���ĳ�ʼֵ
            uint256 resultIndex = 0;
            
            
        // ���ID��1��ʼ����
        uint256 pigID;
        // ��1��ʼѭ���������е�tolalPigs
        for(pigID =0; pigID < tolalPigs; pigID++){
            // �жϵ�ǰpigID��ӵ�����Ƿ�Ϊ_owner
            if(pigIndexToOwner[pigID] == _owner){
                // ����ǣ���pigID����result����resultIndexλ��
                result[resultIndex] = pigID;
                resultIndex++;
            }
        }
        return result;
        }
    }

}


///��Э��
contract pigCoreTest is pigOwnership{
    function ()payable external{
        
    }
    
    function getPig(uint256 _id) external view returns(
        address currentAddress,
        uint64 birthTime,
        uint256 breed,
        uint256 weight,
        uint256 id,
        int8 status,
        int8 pigHouse
    ){

        pig storage Pig = pigs[_id];
        currentAddress = address(Pig.currentAddress);
        birthTime = uint64(Pig.birthTime);
        breed  = uint256(Pig.breed);
        weight = uint256(Pig.weight);
        id  = uint256(Pig.id);
        status = int8(Pig.status);
        pigHouse = int8(Pig.pigHouse);
        
        
    }

}