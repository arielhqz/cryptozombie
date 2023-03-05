pragma solidity ^0.4.25;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable { //起点合约

  using SafeMath for uint256;
  using SafeMath32 for uint32;
  using SafeMath16 for uint16;

  event NewZombie(uint zombieId, string name, uint dna);
  //定义事件，设定三个需要返回的值，打log用

  uint dnaDigits = 16; //设定位数
  uint dnaModulus = 10 ** dnaDigits; //16个0
  uint cooldownTime = 1 days;

  struct Zombie { //定义结构体，该结构体数据类型为下列
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  Zombie[] public zombies; //新建一个名为zombies的结构体，类型为Zombie

  mapping (uint => address) public zombieToOwner; //用僵尸ID查owner
  mapping (address => uint) ownerZombieCount; //用owner查有几个僵尸

  function _createZombie(string _name, uint _dna) internal { 
    //一般内部函数前置"_"; //该函数创造僵尸，需输入名字和DNA
    uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
    //把创造的僵尸推入结构体数组zombies，
    zombieToOwner[id] = msg.sender; 
    //把新创造的僵尸定义为信息发送者的
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1); 
    //信息发送者拥有的僵尸数量+1
    emit NewZombie(id, _name, _dna);
    //发送事件log
  }

  function _generateRandomDna(string _str) private view returns (uint) {
    //该函数生产一个随机DNA，需输入字符串； //view是只读
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    //用keccak256算法生成伪随机数（16位），转化为uint类型（32位），放在"rand"
    return rand % dnaModulus; //取前一行算术结果的余数，保证只有16位
  }

  function createRandomZombie(string _name) public {
    //输入字符串，调用上一个函数生产DNA； //该函数主要验证调用条件是否符合
    require(ownerZombieCount[msg.sender] == 0);
    //需要信息发送者未拥有任何一个僵尸，相当于第一个僵尸是通过发名字生成的
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createZombie(_name, randDna);
  }

}
