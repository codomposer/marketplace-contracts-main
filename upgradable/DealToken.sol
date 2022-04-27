// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DealToken is ERC20Pausable, AccessControl {
    using SafeMath for uint256;
    address private derc = 0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1;
    SafeERC20 erc;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant AGENT_ROLE = keccak256("AGENT_ROLE");

    address private admin;

    mapping(address => bool) whitelistedAddress;
    mapping(address => bool) lockedAddress;
    mapping(address => uint256) lockedTokens;

    uint256 private commission;
    uint256 private tokenPrice;
    uint256 private fees;
    uint256 private finalTokenPrice;

    // Restrict external transfers
    bool private allowTransfers;
    /**
     * @dev Constructor that mines all of existing tokens.
     */
    constructor(string memory _name, string memory _symbol, uint256 _initial_supply, address _owner)
        ERC20(_name, _symbol) {
        _setupRole(MINTER_ROLE, _owner);
        _setupRole(BURNER_ROLE, _owner);
        _setupRole(PAUSER_ROLE, _owner);
        _setupRole(MINTER_ROLE, _owner);
        _mint(_owner, _initial_supply * (10**uint256(decimals())));
        allowTransfers = false;
        erc = SafeERC20(derc);
    }
    // Set params
    function setTokenPrice(uint256 _tokenPrice, uint256 _fees) external onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenPrice = _tokenPrice;
        fees = _fees;
        finalTokenPrice = _tokenPrice.add(_fees);
    }
    function getTokenPrice() external view returns (uint256 _finalTokenPrice) {
        return finalTokenPrice;
    }
    function setCommission(uint256 _commission) external onlyRole(DEFAULT_ADMIN_ROLE) {
        commission = _commission;
    }
    function getCommission() external onlyRole(DEFAULT_ADMIN_ROLE) view returns (uint256 _commission) {
        return commission;
    }
    function allowTransfer() external onlyRole(DEFAULT_ADMIN_ROLE) {
        allowTransfers = true;
    }
    function disallowTransfer() external onlyRole(DEFAULT_ADMIN_ROLE) {
        allowTransfers = false;
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    function freezeAddress(address _address, bool _lock) external onlyRole(DEFAULT_ADMIN_ROLE) {
        lockedAddress[_address] = _lock;
    }

    function freezeTokens(address _address, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(balanceOf(_address) >= amount, "Balance less than freezing tokens");
        lockedTokens[_address] = amount;
    }
    
    function unfreezeTokens(address _address, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(lockedTokens[_address] >= amount, "Unfreezing more than locked.");
        lockedTokens[_address] = lockedTokens[_address].sub(amount);
    }
    function transfer(address _to, uint256 _amount) public override whenNotPaused returns (bool) {
        require(!allowTransfers, "Direct transfers not allowed");
        require(!lockedAddress[_to] && !lockedAddress[msg.sender], "Wallet locked");
        require(_amount <= balanceOf(msg.sender).sub(lockedTokens[msg.sender]), "Not enough Balance");
        _transfer(msg.sender, _to, _amount);
        return true;
    } 
    function transferFrom(address _from, address _to, uint256 _amount) public override whenNotPaused returns (bool) {
        require(!allowTransfers, "Direct transfers not allowed");
        require(!lockedAddress[_to] && !lockedAddress[msg.sender], "Wallet locked");
        require(_amount <= balanceOf(msg.sender).sub(lockedTokens[msg.sender]), "Not enough Balance");
        address spender = _msgSender();
        _spendAllowance(_from, spender, _amount);
        _transfer(_from, _to, _amount);
        return true;
    } 
    function forceTransfer(address _from, address _to, uint256 _amount) onlyRole(DEFAULT_ADMIN_ROLE) external returns (bool) {
        require(!lockedAddress[_to] && !lockedAddress[msg.sender], "Wallet locked");
        require(_amount <= balanceOf(msg.sender).sub(lockedTokens[msg.sender]), "Not enough Balance");
        address spender = _msgSender();
        _spendAllowance(_from, spender, _amount);
        _transfer(_from, _to, _amount);
        return true;
    }
    function buy(uint256 _amount) public returns (bool) {
        require(!lockedAddress[msg.sender], "Wallet locked");
        uint256 _tokenamount = finalTokenPrice.multiply(_amount);
        require(erc.balanceOf(msg.sender)>_tokenAmount, "Not enough balance");
        erc.approve(address(this), _tokenamount);
        erc.transfer(address(this), _tokenamount);
        _transfer(admin, msg.sender, _amount);
        return true;
    } 

    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint256 amount
    // ) internal virtual override {
    //     super._beforeTokenTransfer(from, to, amount);

    //     require(!paused(), "ERC20Pausable: token transfer while paused");
    // }
    function pause() public onlyRole(PAUSER_ROLE) virtual {
        _pause();
    }
    function unpause() public onlyRole(PAUSER_ROLE) virtual {
        _unpause();
    }
}