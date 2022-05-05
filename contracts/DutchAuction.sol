// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DutchAuction {
    uint256 private constant DURATION = 2 days;
    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startsAt;
    uint256 public immutable endsAt;
    uint256 public immutable discountRate;
    string public item;
    bool public stopped;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        string memory _item
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startsAt = block.timestamp;
        endsAt = block.timestamp + DURATION;
        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price and discount "
        );
        item = _item;
    }

    modifier notStopped() {
        require(!stopped, "stopped");
        _;
    }

    function getPrice() public view notStopped returns (uint256) {
        uint256 timeElapsed = block.timestamp - startsAt;
        uint256 discount = discountRate - timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable notStopped {
        require(block.timestamp < endsAt, "ended");
        uint256 price = getPrice();
        require(msg.value >= price, "not enough funds");

        uint256 refund = msg.value - price;

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        seller.transfer(address(this).balance);
        stopped = true;
    }
}
