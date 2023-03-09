pragma solidity ^0.4.25;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;
  //设定升级费用

  modifier aboveLevel(uint _level, uint _zombieId) {
    //设定修饰符
    require(zombies[_zombieId].level >= _level);
    _; //修饰符结束用"_;"
  } 

  function withdraw() external onlyOwner {
    //拿出合约收到的钱
    address _owner = owner();
    //把接收者地址定为合约拥有者
    _owner.transfer(address(this).balance);
    //把地址中的全部余额转到合约拥有者
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    //修改升级费用
    levelUpFee = _fee;
    //修改升级费用为新的数字
  }

  function levelUp(uint _zombieId) external payable {
    //升级； //payable函数才能收钱，钱是收到合约地址
    require(msg.value == levelUpFee);
    //0.001以太升级费用发送到合约来运行函数
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    //该僵尸升一级
  }

  function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  } //2级以上能改名

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  } //20级以上能自定义DNA

  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    //返回owner的所有僵尸
    //"external view"调用不花费GAS，意味着只是一个owner地址查看一下这个合约，但如果是其他"view"，尤其是其他合约调用，那还是会花费GAS，因为运行其他合约会产生花费
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    //新建一个uint类型的memory（内存数组），只在本电脑，不同于storage存储在链上
    //内存命名为"result"
    //通过mapping获得该owner拥有几个僵尸，存储于result
    uint counter = 0;
    //设置计数器
    for (uint i = 0; i < zombies.length; i++) {
      //for循环遍历，从DNA为0开始，i为DNA，遍历次数小于总储存僵尸数
      if (zombieToOwner[i] == _owner) {
        //mapping查询该僵尸是否属于该owner
        result[counter] = i;
        //该DNA放入数组，并记次序
        counter++;
        //找到一个，计数器+1
      }
    }
    return result;
    //返回所有僵尸结果
  }

}
