// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

contract NFTeeStaker is ERC20 {
    IERC721 nftContract;

    uint256 SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 BASE_YIELD_RATE = 1000 ether;

    struct Staker {
        uint256 currYield;
        uint256 rewards;
        uint256 lastCheckpoint;
        uint256[] stakedNFTs;
    }

    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public tokenOwners;

    constructor(
        address _nftContract,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        nftContract = IERC721(_nftContract);
    }

    function stake(uint256[] memory tokenIds) public {
        Staker storage user = stakers[msg.sender];
        uint256 yield = user.currYield;

        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; ++i) {
            require(
                nftContract.ownerOf(tokenIds[i]) == msg.sender,
                "NOT_OWNED"
            );
            nftContract.safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );
            tokenOwners[tokenIds[i]] = msg.sender;
            yield += BASE_YIELD_RATE;
            user.stakedNFTs.push(tokenIds[i]);

            console.log("Staked Token ID: ", tokenIds[i]);
        }

        accumulate(msg.sender);
        user.currYield = yield;

        console.log("New Yield per day: ", user.currYield);
    }

    function unstake(uint256[] memory tokenIds) public {
        Staker storage user = stakers[msg.sender];
        uint256 yield = user.currYield;

        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; ++i) {
            require(
                nftContract.ownerOf(tokenIds[i]) == address(this),
                "NOT_STAKED"
            );
            require(
                tokenOwners[tokenIds[i]] == msg.sender,
                "NOT_ORIGINAL_OWNER"
            );

            if (user.currYield != 0) {
                yield -= BASE_YIELD_RATE;
            }

            for (uint256 j = 0; j < user.stakedNFTs.length; ++j) {
                if (tokenIds[i] == user.stakedNFTs[j]) {
                    uint256 tempTokenId = user.stakedNFTs[
                        user.stakedNFTs.length - 1
                    ];
                    user.stakedNFTs[user.stakedNFTs.length - 1] = tokenIds[i];
                    user.stakedNFTs[j] = tempTokenId;
                    break;
                }
            }

            user.stakedNFTs.pop();

            nftContract.safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i]
            );

            console.log("Unstaked Token ID: ", tokenIds[i]);
        }

        accumulate(msg.sender);
        user.currYield = yield;

        console.log("New Yield per day: ", user.currYield);
    }

    function claim() public {
        Staker storage user = stakers[msg.sender];
        accumulate(msg.sender);

        console.log("Minting ", user.rewards, " tokens to ", msg.sender);

        _mint(msg.sender, user.rewards);
        user.rewards = 0;

        console.log("Rewards set to 0 for ", msg.sender);
    }

    function accumulate(address staker) internal {
        stakers[staker].rewards += getRewards(staker);
        stakers[staker].lastCheckpoint = block.timestamp;
    }

    function getRewards(address staker) public view returns (uint256) {
        Staker memory user = stakers[staker];
        if (user.lastCheckpoint == 0) {
            return 0;
        }

        console.log("Last Checkpoint: ", user.lastCheckpoint);
        console.log("Block Timestamp: ", block.timestamp);
        console.log(
            "Rewards: ",
            ((block.timestamp - user.lastCheckpoint) * user.currYield) /
                SECONDS_PER_DAY
        );

        return
            ((block.timestamp - user.lastCheckpoint) * user.currYield) /
            SECONDS_PER_DAY;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return tokenOwners[tokenId];
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}
