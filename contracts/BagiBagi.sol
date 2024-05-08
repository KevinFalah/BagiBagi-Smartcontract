// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BagiBagi {
    uint256 private giftId;

        struct Gift {
            uint256 id;
            address sender;
            uint256 totalAmount;
            mapping(address => uint256) receiverToAmount;
        }

    mapping(uint256 => Gift) public Gifts;

    function createGiftFixed(
        address[] calldata receivers,
        uint256 amount
    ) external payable returns (uint256) {
        require(
            msg.value == (receivers.length * amount),
            "Incorrect amount sent"
        );

        Gift storage newGift = Gifts[giftId];

        newGift.id = giftId;
        newGift.totalAmount = msg.value;
        newGift.sender = msg.sender;

        for (uint i = 0; i < receivers.length; i++) {
            newGift.receiverToAmount[receivers[i]] = amount;
        }

        giftId++;
        return newGift.id;
    }

    function claimGift(uint256 currGiftId) external {
        Gift storage gift = Gifts[currGiftId];

        require(gift.receiverToAmount[msg.sender] > 0, "Not Eligible Receiver");

        require(gift.totalAmount > 0, "Gifts has been withdrawed by sender");

        // Check
        require(
            address(this).balance >= gift.receiverToAmount[msg.sender],
            "Insufficent contract balance"
        );

        // Effects
        uint256 receivedAmount = gift.receiverToAmount[msg.sender];
        gift.totalAmount -= gift.receiverToAmount[msg.sender];
        gift.receiverToAmount[msg.sender] = 0;

        // Interactions
        (bool sent, ) = msg.sender.call{value: receivedAmount}("");
        require(sent, "Failed to claim gift!");
    }

    function withdrawGift(uint256 currGiftId) external {
        Gift storage gift = Gifts[currGiftId];
        require(
            gift.sender == msg.sender,
            "Only gift sender can withdraw gift"
        );
        require(gift.totalAmount > 0, "All gift are claimed!");

        // Check
        require(
            address(this).balance >= gift.totalAmount,
            "Insufficent contract balance"
        );

        // Effects
        uint256 receivedWithdraw = gift.totalAmount;
        gift.totalAmount = 0;

        // Interactions
        (bool sent, ) = msg.sender.call{value: receivedWithdraw}("");
        require(sent, "Failed to withdraw");
    }

    function createGiftCustom(
        address[] calldata receivers,
        uint256[] calldata amounts
    ) external payable returns (uint256) {
        require(
            receivers.length == amounts.length,
            "receivers length and amount length must be same"
        );
        uint256 totalAmount;
        for (uint256 i = 0; i < receivers.length; i++) {
            totalAmount += amounts[i];
        }
        require(msg.value == totalAmount, "Incorrect amount sent");

        Gift storage newGift = Gifts[giftId];

        newGift.id = giftId;
        newGift.sender = msg.sender;
        newGift.totalAmount = totalAmount;

        for (uint256 i = 0; i < receivers.length; i++) {
            newGift.receiverToAmount[receivers[i]] = amounts[i];
        }

        giftId++;

        return newGift.id;
    }

    function getReceivableAmount(
        uint256 currGiftId,
        address claimer
    ) external view returns (uint256 amount) {
        Gift storage gift = Gifts[currGiftId];
        return gift.receiverToAmount[claimer];
    }
}
