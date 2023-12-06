// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ModelResultNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct ModelResult {
        uint256 accuracy;
        uint256 recall;
        uint256 f1Score;
        string metadata;
        string description; 
    }

    mapping(uint256 => ModelResult) public modelResults;

    constructor() ERC721("ModelResult", "MDR") {}

    function mintModelResult(
        address recipient,
        uint256 accuracy,
        uint256 recall,
        uint256 f1Score,
        string memory metadata,
        string memory description 
    ) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);

        modelResults[newItemId] = ModelResult(accuracy, recall, f1Score, metadata, description);

        return newItemId;
    }

    function getModelResult(uint256 tokenId) public view returns (ModelResult memory) {
        return modelResults[tokenId];
    }

    function getCurrentTokenId() public view returns (uint256) {
        return _tokenIds.current();
    }

    function updateModelResult(
        uint256 tokenId,
        uint256 accuracy,
        uint256 recall,
        uint256 f1Score,
        string memory metadata,
        string memory description
    ) public {
        address owner;
        try this.ownerOf(tokenId) returns (address _owner) {
            owner = _owner;
        } catch {
            revert("ModelResultNFT: Token ID does not exist");
        }

        modelResults[tokenId] = ModelResult(accuracy, recall, f1Score, metadata, description);
    }

    function updateModel(
        uint256 modelId,
        uint256 accuracy,
        uint256 recall,
        uint256 f1Score,
        string memory metadata
    ) public {
        ModelResult memory currentResult = getModelResult(modelId);

        require(
            accuracy > currentResult.accuracy &&
            recall > currentResult.recall &&
            f1Score > currentResult.f1Score,
            "New model's scores are not higher than the current results"
        );

        modelResults[modelId] = ModelResult(accuracy, recall, f1Score, metadata, currentResult.description);
    }

    function updateModelResultNFT(
        uint256 modelId,
        uint256 /* version */,
        uint256 accuracy,
        uint256 recall,
        uint256 f1Score,
        string memory metadata,
        string memory description
    ) public {
        updateModel(modelId, accuracy, recall, f1Score, metadata);

        uint256 tokenId = getCurrentTokenId();

        updateModelResult(tokenId, accuracy, recall, f1Score, metadata, description);
    }
}


