// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./chainlink/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DealToken is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for int256;
    using SafeERC20 for IERC20;
    ERC20 public _token = ERC20(0xe11A86849d99F524cAC3E7A0Ec1241828e332C62);
    // 0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1);
    AggregatorV3Interface internal priceFeed;

    address payable private admin;
    uint256 finalTokenPrice;
    /**
     * @dev Constructor that mines all of existing tokens.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initial_supply,
        uint256 _tokenPrice,
        uint256 _fees,
        address payable _owner
    ) Ownable() ERC20(_name, _symbol) {
        transferOwnership(_owner);
        _mint(_owner, _initial_supply * (10**uint256(decimals())));
        finalTokenPrice = _tokenPrice.add(_fees);
        // SafeERC20(derc).balanceOf(msg.sender);
        approve(address(this), _initial_supply);
        admin = _owner;
        // 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0
        priceFeed = AggregatorV3Interface(
            0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        ); // Matic - USD Price Feed
    }

    function withdrawBalance() external onlyOwner {
        admin.transfer(address(this).balance);
    }

    function getMaticPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        int256 _price = price / 10**8; // price of 1 Matic in USD, USD/Matic use 8 decimals
        return _price;
    }

    function getTokenPrice() public view returns (uint256) {
        return finalTokenPrice;
    }

    function buy(uint256 _amount) public payable {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        int256 _price = price / 10**8; // price of 1 Matic in USD
        require(_amount > 0, "Buy atleast 1 token");
        require(_price > 0, "Error with price feed.");
        // uint256 _tokenAmount = finalTokenPrice.mul(_amount);
        uint256 _tokenAmount = finalTokenPrice.mul(_amount) *
            10**uint256(_token.decimals());
        require(
            msg.value >= (_tokenAmount / uint256(_price)),
            "Transaction value less than required"
        );
        (bool sent, ) = admin.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        _transfer(admin, msg.sender, _amount * 10**uint256(decimals()));
    }

    function buyWithUsdc(uint256 _amount) public returns (uint256) {
        require(_amount > 0, "You need to sell at least some tokens");
        uint256 _tokenAmount = finalTokenPrice.mul(_amount) * 10**uint256(_token.decimals());
        require(
            _token.balanceOf(msg.sender) >= _tokenAmount,
            "Not enough balance"
        );
        require(
            _token.allowance(msg.sender, address(this)) > _tokenAmount,
            "Allow spend to contract"
        );
        //  _token.transfer(admin, _tokenAmount);
        require(_token.transferFrom(msg.sender, admin, _tokenAmount), "USDC payment unsuccesfull");
        _transfer(admin, msg.sender, _amount * 10**uint256(decimals()));
        return _tokenAmount;
    }
}
