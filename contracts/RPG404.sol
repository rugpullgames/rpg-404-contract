// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract RPG404 is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI;
    string public baseExtension = ".json";

    uint256 public maxSupply = 100;
    uint256 public maxFreeSupply = 50;

    uint256 public maxPerTxDuringMint = 5;
    uint256 public maxPerAddressDuringMint = 20;
    uint256 public maxPerAddressDuringFreeMint = 2;

    uint256 public cost = 0.007 ether;
    bool public saleIsActive = false;

    mapping(address => uint256) public freeMintedAmount;
    mapping(address => uint256) public mintedAmount;

    constructor() ERC721("RPG 404", "RPG404") {}

    modifier mintCompliance() {
        require(saleIsActive, "Sale is not active yet.");
        require(tx.origin == msg.sender, "Caller cannot be a contract.");
        _;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _quantity) external payable mintCompliance {
        uint256 _totalSupply = totalSupply();
        require(msg.value >= cost * _quantity, "Insufficient Fund.");
        require(maxSupply >= _totalSupply + _quantity, "Exceeds max supply.");
        uint256 _mintedAmount = mintedAmount[msg.sender];
        require(
            _mintedAmount + _quantity <= maxPerAddressDuringMint,
            "Exceeds max mints per address!"
        );
        require(
            _quantity > 0 && _quantity <= maxPerTxDuringMint,
            "Invalid mint amount."
        );
        mintedAmount[msg.sender] = _mintedAmount + _quantity;
        for (uint256 i = 1; i <= _quantity; i++) {
            _safeMint(msg.sender, _totalSupply + 1);
        }
    }

    function freeMint(uint256 _quantity) external mintCompliance {
        uint256 _totalSupply = totalSupply();
        require(
            maxFreeSupply >= _totalSupply + _quantity,
            "Exceeds max free supply."
        );
        uint256 _freeMintedAmount = freeMintedAmount[msg.sender];
        require(
            _freeMintedAmount + _quantity <= maxPerAddressDuringFreeMint,
            "Exceeds max free mints per address!"
        );
        freeMintedAmount[msg.sender] = _freeMintedAmount + _quantity;

        for (uint256 i = 1; i <= _quantity; i++) {
            _safeMint(msg.sender, _totalSupply + 1);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 _ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](_ownerTokenCount);
        for (uint256 i; i < _ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _currentBaseURI = _baseURI();
        return
            bytes(_currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        _currentBaseURI,
                        _tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setmaxMintAmount(uint256 _newMaxPerTxDuringMint) public onlyOwner {
        maxPerTxDuringMint = _newMaxPerTxDuringMint;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function flipSale() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function withdraw() public payable onlyOwner {
        (bool _success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(_success);
    }
}
