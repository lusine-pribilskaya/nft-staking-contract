// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStaking is Ownable {
    IERC721 public immutable nft;
    IERC20 public immutable rewardToken;

    uint256 public rewardRate = 1 ether;
    uint256 public constant SECONDS_IN_DAY = 86400;

    struct Stake {
        uint256 tokenId;
        uint256 timestamp;
    }

    mapping(address => Stake[]) public stakes;
    mapping(uint256 => address) public tokenOwner;

    constructor(address _nft, address _rewardToken) {
        nft = IERC721(_nft);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 tokenId) external {
        nft.transferFrom(msg.sender, address(this), tokenId);
        stakes[msg.sender].push(Stake(tokenId, block.timestamp));
        tokenOwner[tokenId] = msg.sender;
    }

    function unstake(uint256 tokenId) external {
        require(tokenOwner[tokenId] == msg.sender, "Not token owner");
        _claimReward(tokenId);
        _removeStake(msg.sender, tokenId);
        nft.transferFrom(address(this), msg.sender, tokenId);
        delete tokenOwner[tokenId];
    }

    function claimAllRewards() external {
        Stake[] storage userStakes = stakes[msg.sender];
        for (uint256 i = 0; i < userStakes.length; i++) {
            _claimReward(userStakes[i].tokenId);
            userStakes[i].timestamp = block.timestamp;
        }
    }

    function _claimReward(uint256 tokenId) internal {
        address staker = tokenOwner[tokenId];
        Stake[] storage userStakes = stakes[staker];
        for (uint256 i = 0; i < userStakes.length; i++) {
            if (userStakes[i].tokenId == tokenId) {
                uint256 stakedTime = block.timestamp - userStakes[i].timestamp;
                uint256 rewardAmount = (stakedTime * rewardRate) / SECONDS_IN_DAY;
                rewardToken.transfer(staker, rewardAmount);
                userStakes[i].timestamp = block.timestamp;
                break;
            }
        }
    }

    function _removeStake(address user, uint256 tokenId) internal {
        Stake[] storage userStakes = stakes[user];
        for (uint256 i = 0; i < userStakes.length; i++) {
            if (userStakes[i].tokenId == tokenId) {
                userStakes[i] = userStakes[userStakes.length - 1];
                userStakes.pop();
                break;
            }
        }
    }
}
