// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract TokenBondingCurve_Exponential is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint256 private _tax;

    uint256 private constant _exponent = 2;

    uint256 private _loss_fee_percentage;

    uint256 private mintCap;
    uint256 private supplyCap;

    event tokensBought(address indexed buyer, uint amount, uint total_supply, uint newPrice);
    event tokensSold(address indexed seller, uint amount, uint total_supply, uint newPrice);
    event withdrawn(address from, address to, uint amount, uint time);

    function initialize() public initializer {
        ERC20Upgradeable.__ERC20_init("Popper", "POP"); // Do not forget this call!
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        supplyCap = 1000000;
        _loss_fee_percentage = 1000;
        mintCap = 100;
        supplyCap = 1000000000;
    }

    function buy(uint256 _amount) external nonReentrant payable {
        require(totalSupply() + _amount <= supplyCap, "Exceeds supply cap");
        uint price = _calculatePriceForBuy(_amount);
        require(msg.value>=price,"Send Price is low");
        require(_amount <= mintCap , "Value Exceed MintCap");
        _mint(msg.sender, _amount);
        
        (bool sent,) = payable(msg.sender).call{value: msg.value - price}("");
        require(sent, "Failed to send Ether");

        emit tokensBought(msg.sender, _amount, totalSupply(), getCurrentPrice());
    }

    function sell(uint256 _amount) external nonReentrant {
        require(balanceOf(msg.sender) >= _amount,"Not enough tokens");
        uint256 _price = _calculatePriceForSell(_amount);
        uint tax = _calculateLoss(_price);
        _burn(msg.sender, _amount);
        _tax += tax;

        (bool sent,) = payable(msg.sender).call{value: _price - tax}("");
        require(sent, "Failed to send Ether");

        emit tokensSold(msg.sender, _amount, totalSupply(), getCurrentPrice());
    }

    function withdraw() external onlyOwner nonReentrant {
        require(_tax > 0,"Low On Ether");
        uint amount = _tax;
        _tax = 0;
        
        (bool sent,) = payable(owner()).call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit withdrawn (address(this), msg.sender, amount, block.timestamp);
    }

    function getCurrentPrice() public view returns (uint) {
        return _calculatePriceForBuy(1);
    }

    function calculatePriceForBuy(
        uint256 _tokensToBuy
    ) external view returns (uint256) {
        return _calculatePriceForBuy(_tokensToBuy);
    }

    function calculatePriceForSell(
        uint256 _tokensToSell
    ) external view returns (uint256) {
        return _calculatePriceForSell(_tokensToSell);
    }

    function _calculatePriceForBuy(
        uint256 _tokensToBuy
    ) private view returns (uint256) {
        uint ts = totalSupply();
        uint tsa = ts + _tokensToBuy;
        return area_under_the_curve(tsa) - area_under_the_curve(ts);
    }

    function _calculatePriceForSell(
        uint256 _tokensToSell
    ) private view returns (uint256) {
        uint ts = totalSupply();
        uint tsa = ts - _tokensToSell;
        return area_under_the_curve(ts) - area_under_the_curve(tsa);
    }

    function area_under_the_curve(uint x) internal pure returns (uint256) {
        return (x **(_exponent + 1)) / _exponent + 1 ;
    }

    function _calculateLoss(uint256 amount) private view returns (uint256) {
        return (amount * _loss_fee_percentage) / (1E4);
    }

    function viewTax() external view onlyOwner returns (uint256) {
        return _tax;
    }
    
    function setLoss(uint _loss) external onlyOwner returns (uint256) {
        require(_loss_fee_percentage < 5000, "require loss to be >= 1000 & < 5000");
        _loss_fee_percentage = _loss;
        return _loss_fee_percentage;
    }
    
    function setMintCap(uint _mintCap) external onlyOwner returns (uint256) {
        require(mintCap >= 10, "value should be greater than 10");
        mintCap = _mintCap;
        return mintCap;
    }
    
    function setSupplyCap(uint _cap) external onlyOwner returns (uint256) {
        require(_cap >= totalSupply(), "value cannot be less than total supply");
        supplyCap = _cap;
        return supplyCap;
    }

    function builtwith() external pure returns(string memory){
        return "BuildMyToken_v2.0";
    }

}
