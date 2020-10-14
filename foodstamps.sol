//SPDX-License-Identifier: MIT

pragma solidity =0.5.11;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/access/roles/CapperRole.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

//forked from "@openzeppelin/contracts/crowdsale/validation/IndividuallyCappedCrowdsale.sol"
/**
 * @title IndividuallyCappedCrowdsale
 * @dev Crowdsale with individualCaps.
 */
contract IndividuallyCappedCrowdsale is Crowdsale, CapperRole {
    using SafeMath for uint256;
    uint256 public constant individualCaps = 5*10**18;  // individual contribution caps

    mapping(address => uint256) private _contributions;
    
    /**
     * @dev Sets a specific beneficiary's maximum contribution.
     * @param beneficiary Address to be capped
     * @param cap Wei limit for individual contribution
     */

    /**
     * @dev Returns the cap of a specific beneficiary.
     * @param beneficiary Address whose cap is to be checked
     * @return Current cap for individual beneficiary
     */
    function getCap(address beneficiary) public view returns (uint256) {
        return individualCaps;
    }

    /**
     * @dev Returns the amount contributed so far by a specific beneficiary.
     * @param beneficiary Address of contributor
     * @return Beneficiary contribution so far
     */
    function getContribution(address beneficiary) public view returns (uint256) {
        return _contributions[beneficiary];
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the beneficiary's funding cap.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(block.number >= 8877475, "block height too low, please try again");// starting block height
        require(block.number <= 8877550, "block height too high, event has ended"); // ending block height
        // solhint-disable-next-line max-line-length
        require(_contributions[beneficiary].add(weiAmount) <= individualCaps, "IndividuallyCappedCrowdsale: beneficiary's cap exceeded");
    }

    /**
     * @dev Extend parent behavior to update beneficiary contributions.
     * @param beneficiary Token purchaser
     * @param weiAmount Amount of wei contributed
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        super._updatePurchasingState(beneficiary, weiAmount);
        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);
    }
}

//from https://docs.openzeppelin.com/contracts/2.x/crowdsales
contract MyToken is 
    ERC20, 
    ERC20Mintable {
        using SafeMath for uint256;
        string public name = "foodstamps";
        string public symbol = "STAMPS";
        uint256 public decimals = 18;
    }

contract MyCrowdsale is 
    Crowdsale, 
    CappedCrowdsale, 
    MintedCrowdsale,
    IndividuallyCappedCrowdsale 
    {
        using SafeMath for uint256;
        constructor(
            uint256 rate,    // rate in TKNbits
            address payable wallet,
            IERC20 token,
            uint256 cap           // total cap, in wei
        )
        CappedCrowdsale(cap) 
        Crowdsale(rate, wallet, token)
        public
        {

        }    
    }

