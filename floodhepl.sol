// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct Request {
    uint id;
    address author;
    string title;
    string description;
    string contact;
    uint timestamp;//seg
    uint goal;//wei
    uint balance;
    bool open;
}

contract FloodHepl{

    uint public lastId = 0;
    mapping(uint => Request) public request;

    function openRequest(string memory title, string memory description, string memory contact, uint goal) public{
        lastId++;
        request[lastId] = Request({
          id: lastId,
          title: title,
          description: description,
          contact: contact,
          goal: goal,
          balance: 0,
          timestamp: block.timestamp,
          author: msg.sender,
          open: true
        });
    }

    function closeRequest(uint id) public {
        address author = request[id].author;
        uint balance = request[id].balance;
        uint goal = request[id].goal;
        require(request[id].open && msg.sender == author || balance >=goal, unicode"Você não pode fechar este pedido");

        request[id].open = false;
        
        if(balance > 0){
           request[id].balance = 0;
           payable(author).transfer(balance);

        }
    }

    function donate(uint id) public payable {
        request[id].balance += msg.value;
        if(request[id].balance >= request[id].goal){
            closeRequest(id);
        }
    }

    function getOpenRequest(uint startId, uint quantity) public view returns(Request[] memory) {
        Request[] memory result = new Request[](quantity);
        uint id = startId;
        uint count = 0;

        do {
            if(request[id].open){
                result[count] = request[id];
                count++;
            }
             id++;
        } 
        while (count < quantity && id <= lastId);

        return result;
    }

}
