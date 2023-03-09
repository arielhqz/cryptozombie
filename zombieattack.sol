pragma solidity ^0.4.25;

import "./zombiehelper.sol";

contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;
  //随机数使用次数
  uint attackVictoryProbability = 70;
  //设置胜率

  function randMod(uint _modulus) internal returns(uint) {
    //生成随机数，用来判断战斗结果
    randNonce = randNonce.add(1);
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  } //返回小于输入值的随机数

  function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
    //攻击
    Zombie storage myZombie = zombies[_zombieId];
    //设置指针，该指针名为‘myZombie’,在名为‘zombies’的数组中索引为_zombieId所指向的值
    Zombie storage enemyZombie = zombies[_targetId];
    uint rand = randMod(100);
    //定义随机数范围
    if (rand <= attackVictoryProbability) {
      //判断随机数与胜利范围
      myZombie.winCount = myZombie.winCount.add(1);
      //如果结果是true，胜利数+1
      myZombie.level = myZombie.level.add(1);
      //等级+1
      enemyZombie.lossCount = enemyZombie.lossCount.add(1);
      //对手失败数+1
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
      //输入自己和对手僵尸获得新僵尸，种类为普通"zombie"
    } else {
      myZombie.lossCount = myZombie.lossCount.add(1);
      //否则就是失败，自己失败数+1
      enemyZombie.winCount = enemyZombie.winCount.add(1);
      //对手胜利数+1
      _triggerCooldown(myZombie);
      //启动冷却
    }
  }
}
