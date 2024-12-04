pragma solidity ^0.4.24;

import "./ERC721.sol";

contract Item is ERC721{
    
    struct GameItem{
        string name; // Name of the Item
        uint level; // Item Level
        uint rarityLevel;  // 1 = normal, 2 = rare, 3 = epic, 4 = legendary
    }
    
    GameItem[] public items; // First Item has Index 0
    address public owner;



    uint public mintPrice = 0.01 ether; // 每次铸造的费用
    mapping(address => bool) public whiteList; // 白名单存储



    constructor () public {
        owner = msg.sender; // The Sender is the Owner; Ethereum Address of the Owner
    }
    
    function createItem(string _name, address _to) public{
        require(owner == msg.sender); // Only the Owner can create Items
        uint id = items.length; // Item ID = Length of the Array Items
        items.push(GameItem(_name,5,1)); // Item ("Sword",5,1)
        _mint(_to,id); // Assigns the Token to the Ethereum Address that is specified
    }
    
    function changeOwner(address newOwner,uint tokenId) public{
        require(
        ownerOf(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender),
        "Caller is not owner nor approved"
        ); // Only the Owner Approved and Operator can change
        require(_exists(tokenId), "Token ID not exists"); // 确保代币 ID 存在

        safeTransferFrom(owner, newOwner, tokenId);
     }

     function batchMintByOwner(address[] users, uint[] tokenIds) public{
        require(msg.sender == owner, "Only the contract owner can mint tokens"); // 确保只有合约所有者可以调用
        require(users.length == tokenIds.length, "Users and tokenIds arrays must have the same length"); // 确保数组长度一致

        for (uint i = 0; i < users.length; i++) {
            require(users[i] != address(0), "Cannot mint to the zero address"); // 检查接收者地址是否有效
            require(!_exists(tokenIds[i]), "Token ID already exists"); // 确保代币 ID 未被铸造过

            _mint(users[i], tokenIds[i]); // 铸造并分配代币
    }

     }

     function mint(uint tokenId) payable public{ //修饰函数允许接受以太币
        require(msg.value >= mintPrice, "Insufficient funds to mint"); //要设定一个最小铸造价格 

        _mint(msg.sender,tokenId); // Assigns the Token to the Ethereum Address that is specified
     }

     function mintByWhiteList(uint tokenId)  public{
        require(whiteList[msg.sender], "You are not on the whitelist");

        _mint(msg.sender,tokenId); // Assigns the Token to the Ethereum Address that is specified
     }

     function addWhiteList(address[] users)  public{
         require(msg.sender == owner, "Only the contract owner can add to the whitelist");

        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = true;
        }
     }
     function removeWhiteList(address[] users)  public{
         require(msg.sender == owner, "Only the contract owner can remove from the whitelist");

        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = false;
        }
     }

    function owner(address user)  public view returns (uint[]){
        uint balance = balanceOf(user); // 获取用户拥有的代币数量
        uint[] memory ownedTokenIds = new uint[](balance); // 用于返回的拥有物品数组
        uint counter = 0;

        for (uint i = 0; i < items.length; i++) {
            if (ownerOf(i) == user) {
                ownedTokenIds[counter] = i;
                counter++;
            }
        }
        return ownedTokenIds;
     }
}

