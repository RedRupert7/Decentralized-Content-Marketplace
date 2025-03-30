**README.md**

# Decentralized Content Marketplace

## Overview
The Decentralized Content Marketplace is a smart contract-based platform that enables content creators to tokenize and sell digital content with automated royalty distributions. The contract supports one-time purchases, subscriptions, and revenue-sharing among collaborators.

## Features
- **Content Registration**: Creators can list digital content with metadata, pricing, and royalty details.
- **Collaborator Royalties**: Multiple contributors can receive a percentage of earnings.
- **Purchasing Mechanism**: Users can buy content via one-time payment or subscription.
- **Reviews & Ratings**: Buyers can leave reviews and ratings for purchased content.
- **Automated Royalty Distribution**: Payments are split between creators and collaborators.
- **Content Management**: Creators can update prices and activation status.

## Data Structures
### **Maps & Variables**
- **Contents**: Stores content details such as title, creator, price, and subscription terms.
- **Content Collaborators**: Manages revenue-sharing percentages for contributors.
- **Purchases**: Tracks purchases and subscription expiry dates.
- **Reviews**: Allows users to rate and review content.
- **Global Counters**: Maintains counters for content IDs and purchase IDs.

## Public Functions
- **register-content**: Adds new content to the marketplace.
- **add-collaborator**: Assigns a collaborator with a royalty percentage.
- **purchase-content**: Enables users to purchase content.
- **distribute-royalties**: Splits earnings among content creators and collaborators.
- **leave-review**: Allows users to rate and review content.
- **update-content-status**: Enables creators to activate/deactivate content.
- **update-content-price**: Modifies the price of content.

## Read-Only Functions
- **get-content**: Retrieves content details.
- **get-content-collaborator**: Fetches collaborator details.
- **get-purchase**: Checks purchase history.
- **get-review**: Retrieves a review for a piece of content.
- **has-active-subscription**: Determines if a user has an active subscription.
- **calculate-average-rating**: Computes an average rating for content.

## Error Codes
- **ERR-NOT-AUTHORIZED**: Unauthorized action attempted.
- **ERR-CONTENT-NOT-FOUND**: Content does not exist.
- **ERR-PRICE-NOT-MET**: Insufficient payment amount.
- **ERR-ALREADY-PURCHASED**: Content has already been purchased.
- **ERR-INVALID-RATING**: Invalid rating value.
- **ERR-CONTENT-NOT-ACTIVE**: Content is deactivated.
- **ERR-ALREADY-REVIEWED**: Content already reviewed by user.
- **ERR-NOT-PURCHASED**: User has not purchased the content.
- **ERR-INVALID-ROYALTY-PERCENTAGE**: Invalid royalty percentage.
- **ERR-TOTAL-ROYALTY-EXCEEDS-100**: Total royalty exceeds 100%.

## Installation & Deployment
1. Clone the repository.
2. Deploy the contract using Clarity.
3. Interact with the contract using Clarity functions.

---

**Pull Request Description**

### **Title:** Implement Decentralized Content Marketplace Smart Contract

### **Description:**
This PR introduces a Clarity smart contract for a decentralized content marketplace. The contract enables content creators to tokenize and sell digital content while automating royalty distributions among collaborators. It supports one-time purchases, subscriptions, and user reviews.

#### **Key Features:**
- Content registration and management
- Purchase and subscription tracking
- Royalty distribution among multiple collaborators
- Review and rating system
- Content status and price management

This implementation ensures that all transactions are transparent and that royalties are fairly distributed among contributors. Further optimizations can be made for gas efficiency and additional f