// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * EDUCATIONAL TOKEN
 * This token is NOT official Tether USD (USDT).
 * It is created for learning/testing purposes only.
 */

contract EducationalTetherUSD is ERC20, ERC20Burnable, ERC20Pausable, Ownable {

    uint8 private constant TOKEN_DECIMALS = 6;

    // IPFS logo
    string public logoURI =
        "ipfs://bafkreihny5ic6gtsf3ag6o7gwa2xdnwyhfut5gjl6mfwlmgggpasixmfnu";

    // Blocked addresses
    mapping(address => bool) public blocked;

    event AddressBlocked(address indexed account);
    event AddressUnblocked(address indexed account);
    event LogoUpdated(string newLogoURI);

    constructor(uint256 initialSupply)
        ERC20("Tether USD", "USDT")
        Ownable(msg.sender)
    {
        _mint(msg.sender, initialSupply * 10 ** TOKEN_DECIMALS);
    }

    function decimals()
        public
        pure
        override
        returns (uint8)
    {
        return TOKEN_DECIMALS;
    }

    // Owner can create additional tokens
    function mint(address to, uint256 amount)
        external
        onlyOwner
    {
        require(to != address(0), "Invalid address");
        require(!blocked[to], "Address blocked");

        _mint(to, amount * 10 ** TOKEN_DECIMALS);
    }

    // Pause transfers
    function pause()
        external
        onlyOwner
    {
        _pause();
    }

    // Resume transfers
    function unpause()
        external
        onlyOwner
    {
        _unpause();
    }

    // Block an address
    function blockAddress(address account)
        external
        onlyOwner
    {
        require(account != address(0), "Invalid address");

        blocked[account] = true;

        emit AddressBlocked(account);
    }

    // Unblock an address
    function unblockAddress(address account)
        external
        onlyOwner
    {
        blocked[account] = false;

        emit AddressUnblocked(account);
    }

    // Change logo
    function setLogoURI(string calldata newLogoURI)
        external
        onlyOwner
    {
        logoURI = newLogoURI;

        emit LogoUpdated(newLogoURI);
    }

    // ERC20 + Pausable update hook
    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(ERC20, ERC20Pausable)
    {
        require(
            from == address(0) || !blocked[from],
            "Sender blocked"
        );

        require(
            to == address(0) || !blocked[to],
            "Recipient blocked"
        );

        super._update(from, to, value);
    }
}
