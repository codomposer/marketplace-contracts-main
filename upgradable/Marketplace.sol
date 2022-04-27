// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Issuer.sol";
import "./DealToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Marketplace - Allows creation and listing of custom tokens.

contract Marketplace is Issuer, Ownable {

    /*
     * Public functions
     */
    /// @dev Allows verified creation of custom token.
    /// @param _name String for token name.
    /// @param _symbol String for token symbol.
    /// @param _initial_supply uint256 for inital supply.
    /// @param _tokenPrice uint256 for token price.
    /// @param _fees uint256 for fees on each token.
    /// @return tokenAddress Returns token contract address.
    function create(string memory _name, string memory _symbol, uint256 _initial_supply, uint256 _tokenPrice, uint256 _fees)
        public
        returns (address tokenAddress)
    {
        tokenAddress = address(new DealToken(_name, _symbol, _initial_supply, _tokenPrice, _fees, payable(msg.sender)));
        register(tokenAddress);
        return tokenAddress;
    }
    /// @param _deal address for fees on each token.
    /// @return tokenAddress Returns token contract address.
    function addDeal(address _deal)
        public
        returns (address tokenAddress)
    {
        register(_deal);
        return _deal;
    }
}
