// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

/// @title The Delphya App
/// @author RisMouZ

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DelphyaDapp is Ownable {
    using SafeERC20 for IERC20;

    IERC20 dpt;

    struct User {
        string pseudo;
    }

    /// @dev the Prediction struct using mapping for stock the betting amount for any users

    struct Prediction {
        string description;
        uint256 dateLimit;
        bool didItHappened;
        bool didItNotHappened;
        uint256 userParticipate;
        bool exist;
        uint256 totalBet;
        uint256 betFor;
        uint256 betAgainst;
        uint256 betForAmount;
        uint256 betAgainstAmount;
        mapping(address => uint256) bet;
        mapping(address => bool) betForPrediction;
        mapping(address => bool) betAgainstPrediction;
    }

    mapping(address => User) users;
    mapping(string => Prediction) predictions;

    event UserCreated(address userAddress);
    event PredictionCreated(string predictionName);
    event PredictionFounded(string predictionName, uint256 amount);
    event PredictionUpdate(string predictionName);
    event GainTransfered(address userAddress, uint256 amount);

    constructor(address dptAdress) {
        dpt = IERC20(dptAdress);
    }

    function createUser(string memory _pseudo) external {
        users[msg.sender].pseudo = _pseudo;
    }

    function createPrediction(
        string memory _name,
        string memory _description,
        uint256 _dateLimit
    ) external onlyOwner {
        require(!predictions[_name].exist, "Prediction already exist");
        predictions[_name].description = _description;
        predictions[_name].dateLimit = _dateLimit;
        predictions[_name].exist = true;
        emit PredictionCreated(_name);
    }

    function betForPrediction(uint256 _amount, string memory _name) external {
        require(predictions[_name].exist, "This prediction doesn't exist");
        require(!predictions[_name].betAgainstPrediction[msg.sender]);
        dpt.safeTransferFrom(msg.sender, address(this), _amount);
        predictions[_name].totalBet += _amount;
        predictions[_name].betFor + 1;
        predictions[_name].betForPrediction[msg.sender] = true;
        predictions[_name].betForAmount += _amount;
        predictions[_name].bet[msg.sender] += _amount;
        emit PredictionFounded(_name, _amount);
    }

    function betAgainstPrediction(uint256 _amount, string memory _name)
        external
    {
        require(predictions[_name].exist, "This prediction doesn't exist");
        require(!predictions[_name].betForPrediction[msg.sender]);
        dpt.safeTransferFrom(msg.sender, address(this), _amount);
        predictions[_name].totalBet += _amount;
        predictions[_name].betAgainst + 1;
        predictions[_name].betAgainstPrediction[msg.sender] = true;
        predictions[_name].betAgainstAmount += _amount;
        predictions[_name].bet[msg.sender] += _amount;
        emit PredictionFounded(_name, _amount);
    }

    function predictionHappened(string memory _name) external onlyOwner {
        require(
            predictions[_name].exist &&
                predictions[_name].dateLimit < block.timestamp
        );
        predictions[_name].didItHappened = true;
        emit PredictionUpdate(_name);
    }

    function predictionHNotappened(string memory _name) external onlyOwner {
        require(
            predictions[_name].exist &&
                predictions[_name].dateLimit < block.timestamp
        );
        predictions[_name].didItNotHappened = true;
        emit PredictionUpdate(_name);
    }

    function withdrawBet(string memory _name) external {
        require(predictions[_name].exist, "This prediction doesn't exist");
        require(
            predictions[_name].bet[msg.sender] > 0,
            "You have no bet in this prediction"
        );
        require(predictions[_name].dateLimit < block.timestamp);
        require(
            (predictions[_name].didItHappened &&
                predictions[_name].betForPrediction[msg.sender]) ||
                (predictions[_name].didItNotHappened &&
                    predictions[_name].betAgainstPrediction[msg.sender])
        );
        if (predictions[_name].didItHappened) {
            uint256 gain = (predictions[_name].bet[msg.sender] /
                predictions[_name].betForAmount) * predictions[_name].totalBet;
            dpt.safeTransferFrom(address(this), msg.sender, gain);
            emit GainTransfered(msg.sender, gain);
        }
        if (predictions[_name].didItNotHappened) {
            uint256 gain = (predictions[_name].bet[msg.sender] /
                predictions[_name].betAgainstAmount) *
                predictions[_name].totalBet;
            dpt.safeTransferFrom(address(this), msg.sender, gain);
            emit GainTransfered(msg.sender, gain);
        }
    }
}
