pragma solidity ^0.4.25;

import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";

contract ZombieOwnership is ZombieAttack, ERC721 {
//同时继承自"ZombieAttack"和"ERC721"，用"，"分隔

  using SafeMath for uint256;

  mapping (uint => address) zombieApprovals;
  //定义新映射，存储被允许转走的token，和目标地址

  function balanceOf(address _owner) external view returns (uint256) {
    //查询账户余额
    return ownerZombieCount[_owner];
    //返回该地址拥有多少只僵尸
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    //查询该token的所有者地址
    return zombieToOwner[_tokenId];
  }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      //由token拥有者唤起，放入允许被转走的token和接受地址
      zombieApprovals[_tokenId] = _approved;
      //存储进映射
      emit Approval(msg.sender, _approved, _tokenId);
      //发送已被允许事件的log，发送者，接收者，token
    }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      //从外部唤起token转移
      require (zombieToOwner[_tokenId] == msg.sender || zombieApprovals[_tokenId] == msg.sender);
      //两种token转移方式
      //第一种，由token拥有者直接调用，传入目标和token
      //第二种，分两步，第一步由token拥有者唤起，把目标和token存入approve，第二步由接受目标唤起，要求转入
      //该require条件：1.发送信息是token拥有者；或者2.发送信息是已被允许的代币接收者
      _transfer(_from, _to, _tokenId);
      //发起转移
    }
    
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    //转移操作
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    //目标拥有token数+1，"add(1)"比起"++"会自动经过safemath检测溢出或下溢 
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
    //发送者拥有token数-1
    zombieToOwner[_tokenId] = _to;
    //映射zombieToOwner中，该token持有者改成目标address
    emit Transfer(_from, _to, _tokenId);
    //发送事件log，事件在"ERC721"合约中已定义
  } 
}
