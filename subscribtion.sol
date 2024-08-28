// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedSubscription {
    struct Subscription {
        uint256 startTime;
        uint256 duration;
        uint256 amount;
    }

    address public creator;
    mapping(address => Subscription) public subscriptions;
    mapping(address => bool) public activeSubscribers;

    event Subscribed(address indexed user, uint256 amount, uint256 duration);
    event Unsubscribed(address indexed user);

    modifier onlyCreator() {
        require(msg.sender == creator, "Only the content creator can perform this action.");
        _;
    }

    modifier onlyActiveSubscriber() {
        require(activeSubscribers[msg.sender], "Only active subscribers can perform this action.");
        _;
    }

    constructor() {
        creator = msg.sender;
    }

    function subscribe(uint256 duration) external payable {
        require(msg.value > 0, "Subscription fee is required.");
        require(duration > 0, "Subscription duration must be greater than zero.");

        Subscription storage subscription = subscriptions[msg.sender];
        subscription.startTime = block.timestamp;
        subscription.duration = duration;
        subscription.amount = msg.value;
        activeSubscribers[msg.sender] = true;

        emit Subscribed(msg.sender, msg.value, duration);
    }

    function checkSubscriptionStatus(address user) public view returns (bool) {
        Subscription memory subscription = subscriptions[user];
        if (subscription.startTime == 0) {
            return false;
        }
        if (block.timestamp > subscription.startTime + subscription.duration) {
            return false;
        }
        return true;
    }

    function unsubscribe() external onlyActiveSubscriber {
        delete subscriptions[msg.sender];
        activeSubscribers[msg.sender] = false;

        emit Unsubscribed(msg.sender);
    }

    function withdrawFunds() external onlyCreator {
        payable(creator).transfer(address(this).balance);
    }

    function getSubscriptionDetails(address user) external view returns (uint256 startTime, uint256 duration, uint256 amount) {
        Subscription memory subscription = subscriptions[user];
        return (subscription.startTime, subscription.duration, subscription.amount);
    }
}
