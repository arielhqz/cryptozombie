pragma solidity ^0.4.25;

import "./zombiefactory.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  ); //用"；"结束，而不是"{}"表示这是一个接口
}

contract ZombieFeeding is ZombieFactory { //继承自factory

  KittyInterface kittyContract;
  //把kiity接口命名为kittycontract

  modifier onlyOwnerOf(uint _zombieId) {
    //设置所有权修饰函数，不能使用"ownerOf"，因为ERC721标准合约中有个函数，且普遍使用
    require(msg.sender == zombieToOwner[_zombieId]);
    //mapping里查匹配关系
    _;
  }

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  } //留个口子，用于修改接口合约的地址； //‘onlyOwner’，只有该合约的拥有者可以修改
  //external只能从合约外部调用

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  } //启动冷却，冷却完成时间点为，唤起时间+冷却时间

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      //设置‘return（bool）’，正确返回true，否返回false
      return (_zombie.readyTime <= now);
  } //冷却完成时间点小于现在时间，即为true，冷却完成
  

  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal onlyOwnerOf(_zombieId) {
    //输入新DNA与原有僵尸DNA混合，获得新僵尸DNA，‘onlyOwnerOf’只允许该僵尸所有者调用
    Zombie storage myZombie = zombies[_zombieId];
    //设置指针，该指针名为‘myZombie’,在名为‘zombies’的数组中索引为_zombieId所指向的值
    require(_isReady(myZombie));
    //要求冷却完成
    _targetDna = _targetDna % dnaModulus;
    //保证输入新DNA不超过原DNA长度（16位）（防止溢出攻击）
    uint newDna = (myZombie.dna + _targetDna) / 2;
    //混合，把两者DNA相加除2，获得新DNA
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99; //‘%100’为除以100取余数，就是最后两位
    } //如果输入的物种为“Kitty”，则DNA结尾为99
    _createZombie("NoName", newDna);
    //输出新僵尸，把名字和ID推入数组，打log
    _triggerCooldown(myZombie);
    //再次启动冷却
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    //public可以从任何地方调用
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    //调用接口合约的接口函数
    //传回genes数据，为数据列的第10个，所以前面都用逗号省略
    feedAndMultiply(_zombieId, kittyDna, "kitty");
    //最后一个是specie tag，没有特殊的就写zombie
  }
}
