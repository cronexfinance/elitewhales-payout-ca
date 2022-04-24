// SPDX-License-Identifier: MIT

pragma solidity >=0.8.11;
import "./Ownable.sol";
contract thingy is Ownable {

    struct partner { address pAddress; uint256 pShare; }
    mapping(uint256 => partner) partnerIndex;
    mapping(address => uint256) indexOfPartner;
    uint256 partnerSize = 0;

    function partnerAdd(address pAddress, uint256 pShare) public onlyOwner {
        require(indexOfPartner[pAddress] == 0, "partner already exists");
        partnerIndex[++partnerSize] = partner(pAddress, pShare);
        indexOfPartner[pAddress] = partnerSize;
    }
    function partnerUpdate(address pAddress, uint256 pShare) public onlyOwner {
        require(indexOfPartner[pAddress] != 0, "partner does not exist");
        partnerIndex[indexOfPartner[pAddress]].pShare = pShare;
    }
    function getParnters() public view returns (address[] memory partners) {
        address[] memory _partners = new address[](partnerSize);
        for(uint256 i; i<partnerSize; i++) { _partners[i] = partnerIndex[i].pAddress; }
        return _partners;
    }
    function totalShares() public view returns (uint256) {
        uint256 _shares;
        for(uint256 i; i<partnerSize; i++) { _shares += partnerIndex[i].pShare; }
        return _shares;
    }
    function distributeShares() public onlyOwner {
        uint256 _shares = totalShares();
        bool success;
        partner[] memory _partners = new partner[](partnerSize);
        for(uint256 i; i<partnerSize; i++) { 
            if(_partners[i].pAddress != address(0) && _partners[i].pShare > 0) {
                (success,) = _partners[i].pAddress.call{value: address(this).balance * _partners[i].pShare / _shares}("");
            }
        }
    }
}
