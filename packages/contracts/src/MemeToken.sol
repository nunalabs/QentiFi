// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MemeToken
 * @notice Standard ERC-20 token created via MemeTokenFactory
 * @dev Simple implementation with metadata for meme tokens
 */
contract MemeToken is ERC20, Ownable {
    string private _tokenImageURI;
    address public immutable factory;
    address public bondingCurve;
    uint256 public createdAt;

    event ImageURIUpdated(string newImageURI);
    event BondingCurveSet(address indexed bondingCurve);

    constructor(
        string memory name,
        string memory symbol,
        string memory imageURI,
        address creator
    ) ERC20(name, symbol) Ownable(creator) {
        _tokenImageURI = imageURI;
        factory = msg.sender;
        createdAt = block.timestamp;
    }

    /**
     * @notice Set bonding curve address (can only be set once by factory)
     * @param _bondingCurve Address of the bonding curve contract
     */
    function setBondingCurve(address _bondingCurve) external {
        require(msg.sender == factory, "Only factory can set bonding curve");
        require(bondingCurve == address(0), "Bonding curve already set");
        bondingCurve = _bondingCurve;
        emit BondingCurveSet(_bondingCurve);
    }

    /**
     * @notice Mint tokens (only callable by bonding curve or owner)
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external {
        require(
            msg.sender == bondingCurve || msg.sender == owner(),
            "Only bonding curve or owner can mint"
        );
        _mint(to, amount);
    }

    /**
     * @notice Burn tokens from caller
     * @param amount Amount of tokens to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Get token image URI
     * @return URI of the token image
     */
    function imageURI() external view returns (string memory) {
        return _tokenImageURI;
    }

    /**
     * @notice Update token image URI (only owner)
     * @param newImageURI New image URI
     */
    function setImageURI(string memory newImageURI) external onlyOwner {
        _tokenImageURI = newImageURI;
        emit ImageURIUpdated(newImageURI);
    }
}
