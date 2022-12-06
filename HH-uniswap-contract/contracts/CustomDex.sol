// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000 * 10 ** 18); //1000 tkns
    }
}

contract CustomDex {
    // Custom tokens to be initialiazed
    string[] public tokens = ["CoinA", "CoinB", "CoinC"];

    // map to maintain the tokens and its instances
    mapping(string => ERC20) public tokenInstanceMap;

    // 1 CoinA/CoinB/COinC = 0.0001 eth
    uint256 ethValue = 100000000000000;

    // 0.0001 eth = 1 CoinA/CoinB/CoinC
    // 1 CoinA/CoinB/CoinC = 1 CoinA/CoinB/CoinC

    constructor() {
        //since we ve this loop in constructor our coins will deploy along with the contract
        for (uint i = 0; i < tokens.length; i++) {
            CustomToken token = new CustomToken(tokens[i], tokens[i]); //the constructor/ tkn name, tkn symbol
            tokenInstanceMap[tokens[i]] = token;
        }
    }

    //get the tkn balance of the wallet addr
    function getBalance(
        string memory tokenName,
        address _address
    ) public view returns (uint256) {
        return tokenInstanceMap[tokenName].balanceOf(_address);
    }

    //get the total supply of the tkn
    function getTotalSupply(
        string memory tokenName
    ) public view returns (uint256) {
        return tokenInstanceMap[tokenName].totalSupply();
    }

    //get the name of the tkn
    function getName(
        string memory tokenName
    ) public view returns (string memory) {
        return tokenInstanceMap[tokenName].name();
    }

    //get the token addr
    function getTokenAddress(
        string memory tokenName
    ) public view returns (address) {
        return address(tokenInstanceMap[tokenName]);
    }

    //get the eth bal of this contract
    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //1.let swap the eth to the cust tokns[]
    function swapEthToToken(
        string memory tokenName
    ) public payable returns (uint256) {
        uint256 inputValue = msg.value;
        uint256 outputValue = (inputValue / ethValue) * 10 ** 18; // Convert to 18 decimal places
        require(tokenInstanceMap[tokenName].transfer(msg.sender, outputValue)); //make sure that transfer to the sender happens
        return outputValue;
    }

    //2.for swapping b/w the cust tkn to eth
    function swapTokenToEth(
        string memory tokenName,
        uint256 _amount
    ) public returns (uint256) {
        // Convert the token amount (ethValue) to exact amount (10)
        uint256 exactAmount = _amount / 10 ** 18;
        uint256 ethToBeTransferred = exactAmount * ethValue;
        require(
            address(this).balance >= ethToBeTransferred,
            "Dex is running low on balance."
        );

        payable(msg.sender).transfer(ethToBeTransferred);
        require(
            tokenInstanceMap[tokenName].transferFrom(
                msg.sender,
                address(this),
                _amount
            )
        ); //make sure the traansfer from sender to contract, with amt
        return ethToBeTransferred;
    }

    //3. swapping b/w the cust tkn to cust tkn
    function swapTokenToToken(
        string memory srcTokenName,
        string memory destTokenName,
        uint256 _amount
    ) public {
        require(
            tokenInstanceMap[srcTokenName].transferFrom(
                msg.sender,
                address(this),
                _amount
            )
        );
        require(tokenInstanceMap[destTokenName].transfer(msg.sender, _amount));
    }
}
