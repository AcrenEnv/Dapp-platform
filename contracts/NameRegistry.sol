pragma solidity >=0.4.21 <0.7.0;
import "./openzeppelin-solidity/contracts/ownership/Ownable.sol";
//SPDX-License-Identifier: MIT

contract NameRegistry is Ownable {
   struct ContractDetails {
 //     address owner;
      address contractAddress;
 //     uint16 version;
   }
   mapping(string => ContractDetails) registry;

   function registerName(string memory name, address addr/*, uint16 ver*/)
   public
   onlyOwner
   returns (bool) {
      // versions should start from 1
      //require(ver >= 1);
      ContractDetails memory info = registry[name];
      //require(info.owner == msg.sender);
      // create info if it doesn't exist in the registry
       if (info.contractAddress == address(0)) {
          info = ContractDetails({
             //owner: msg.sender,
             contractAddress: addr
             //version: ver
          });
       } else {
          //info.version = ver;
          info.contractAddress = addr;
       }
       // update record in the registry
       registry[name] = info;
       return true;
   }

    function getContractDetails(string memory name)
    public 
    view returns(address) {
      return (registry[name].contractAddress/*, registry[name].version*/);
   }
}