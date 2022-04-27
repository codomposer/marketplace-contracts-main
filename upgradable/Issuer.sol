// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Issuer {
    /*
     *  Events
     */
    event DealInstantiation(address indexed issuer, address indexed instantiation);
    /*
     *  Storage
     */
    mapping(address => bool) public isInstantiation;
    mapping(address => address[]) public instantiations;
    mapping(address => address) public dealIssuer;

    mapping(address => bool) private whitelisted;

    /*
     * Public functions
     */
    /// @dev Returns number of instantiations by issuer.
    /// @param issuer Contract issuer.
    /// @return Returns number of instantiations by issuer.
    function getInstantiationCount(address issuer)
        public
        view
        returns (uint)
    {
        return instantiations[issuer].length;
    }

    /*
     * Internal functions
     */
    /// @dev Registers contract in issuer registry.
    /// @param instantiation Address of contract instantiation.
    function register(address instantiation)
        internal
    {
        isInstantiation[instantiation] = true;
        instantiations[msg.sender].push(instantiation);
        dealIssuer[instantiation] = msg.sender;
        emit DealInstantiation(msg.sender, instantiation);
    }
}