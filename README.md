# CS2 Inventory Tracker

A personal MySQL database designed to track Counter-Strike 2 inventory history, cost basis, openings, trade-ups, and overall profit/loss. Built for clean analysis in Power BI.

---

## Problem

Tracking CS2 inventory in spreadsheets quickly becomes unreliable once you start doing case openings, capsule openings, and especially trade-ups. Common issues include:

- Double-counting money spent
- Losing cost basis when items are opened or traded up
- Difficulty calculating true realized profit
- No clean way to analyse holdings by collection, rarity, acquisition type, etc.

This project solves those problems with a structured relational model.

---

## Features

- Clean separation between **cash movements** and **item movements**
- Correct cost-basis tracking through:
  - Case / Capsule / Terminal openings
  - Trade-ups (including chained trade-ups)
  - Free drops and gifts
- Support for multiple Steam accounts
- Status tracking for every item (Holding, Sold, Opened, Traded-Up, Consumed, etc.)
- Ready for Power BI (star-schema friendly)
- Simple enough for manual data entry

---

## Database Schema

### Tables

| Table         | Purpose                                              |
|---------------|------------------------------------------------------|
| `accounts`    | Steam accounts                                       |
| `purchases`   | All real money spent (unit price × quantity)         |
| `sales`       | All real money received (unit price × quantity)      |
| `inventory`   | Every individual item (one row = one physical item)  |

### Core Design Principles

1. **Cash is recorded only in `purchases` and `sales`**
2. **Cost basis lives on inventory rows** (`unit_cost`)
3. **One physical item = one inventory row** (quantity is 1 while held, 0 when it leaves)
4. **Status** explains what happened to the item
5. Cost basis is **transferred**, never duplicated or lost

---

## Status Values

| Status       | Meaning                                      |
|--------------|----------------------------------------------|
| `Holding`    | Currently in inventory                       |
| `Sold`       | Sold on the market                           |
| `Opened`     | Case / Capsule / Terminal opened             |
| `Traded-Up`  | Used as input in a trade-up                  |
| `Consumed`   | Sticker, charm, patch, etc. applied          |
| `Traded`     | Given away in a trade                        |
| `Gifted`     | Given away as a gift                         |

---

## Supported Analyses

- Total invested capital
- Portfolio distribution by account
- Inventory breakdown by rarity
- Inventory breakdown by collection
- Acquisition type statistics
- Sales history
- Profit and loss analysis

---

## This project was created to improve practical skills in:

- Database design
- SQL
- Data modeling
- Business Intelligence (Power BI)
- Git version control
- Technical documentation
