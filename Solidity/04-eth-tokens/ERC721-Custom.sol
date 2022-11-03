// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721, IERC721Metadata {
    string private _name;
    string private _symbol;

    // store the owner of each nft
    // nftId => owner
    mapping(uint256 => address) internal _ownerOf;

    // amount of nft that each address owns
    // owner => nofOfNFTs
    mapping(address => uint256) internal _balanceOf;

    // owner of the NFT might allow another address to take control of this nft
    // nftid => operator_address
    mapping(uint256 => address) internal _approvals;

    // tokenId => string
    mapping(uint256 => string) private _tokenURIs;

    // if a owner owns many nfts, instead for each nft, we can give approval to a single address to take control over all of my nfts
    // nft owner => operator_address => bool
    mapping(address => mapping(address => bool))
        public
        override isApprovedForAll;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external virtual returns (bytes4) {}

    function setApprovalForAll(address operator, bool _approved)
        external
        virtual
        override
    {
        require(
            msg.sender != operator,
            "owner giving himself the operator permission"
        );
        // owner has given operator permission to spend his nfts
        isApprovedForAll[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    /* 
        gives permission to the "to" address to take control of tokenId
        caller of the function will have to be owner of tokenId or operator of the tokenId
    */
    function approve(address to, uint256 tokenId) external virtual override {
        address owner = _ownerOf[tokenId];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );

        _approvals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /// if "to" is a contract, instead of a real user, we need to call onERC721Received()
    ///
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function balanceOf(address owner)
        external
        view
        virtual
        override
        returns (uint256 balance)
    {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    function ownerOf(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address owner)
    {
        owner = _ownerOf[tokenId];
        require(owner != address(0), "owner = zero address");
    }

    function getApproved(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address operator)
    {
        require(_ownerOf[tokenId] != address(0), "token doesn't exist");
        return _approvals[tokenId];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        virtual
        override
        returns (bool)
    {
        return
            interfaceID == type(IERC721).interfaceId ||
            interfaceID == type(IERC165).interfaceId;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(from == _ownerOf[tokenId], "from != owner");
        require(to != address(0), "to = zero address");
        require(
            _isApprovedOrOwner(from, msg.sender, tokenId),
            "not authorised"
        );

        _balanceOf[from] -= 1;
        _balanceOf[to] += 1;
        _ownerOf[tokenId] = to;
        delete _approvals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        _safeTransferFrom(from, to, tokenId, data);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        // check if the token is minted or not
        require(_ownerOf[_tokenId] != address(0), "invalid token id");

        // send the URI that has been set
        return string(abi.encodePacked(_baseURI(), Strings.toString(_tokenId)));
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        transferFrom(from, to, tokenId);

        // check whether an address is a contract or not
        // if 0, it is a contract address
        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "not a contract, unsafe recipient"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "to = zero address");
        require(_ownerOf[tokenId] == address(0), "token exists");

        _balanceOf[to] += 1;
        _ownerOf[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "token doesnot exist");

        _balanceOf[owner] -= 1;
        delete _ownerOf[tokenId];
        delete _approvals[tokenId];

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        emit Transfer(owner, address(0), tokenId);
    }

    function _setTokenURI(uint _tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(_ownerOf[_tokenId] != address(0), "token doesnot exist");
        _tokenURIs[_tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view virtual returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[tokenId]);
    }
}

contract MyNFT is ERC721 {
    uint public tokenCount = 0;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function mint(string memory _tokenURI) external {
        tokenCount++;

        _mint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);
    }

    function burn(uint256 tokenId) external {
        require(msg.sender == _ownerOf[tokenId], "not owner");
        _burn(tokenId);
    }
}
