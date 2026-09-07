\# Design Decisions



This document explains the key design choices behind the CS2 Inventory Tracker database and the meaning of the main fields and metrics.



\---



\## 1. Separation of Cash and Inventory



\*\*Decision:\*\*  

All real money movements are stored only in the `purchases` and `sales` tables.  

The `inventory` table never records cash directly.



\*\*Reason:\*\*  

This prevents double-counting. Openings, trade-ups, and other item transformations only move cost basis — they never create new money.



\---



\## 2. One Item = One Row



\*\*Decision:\*\*  

Every physical item is stored as a separate row in the `inventory` table.  

`quantity` is normally `1` while the item exists and is set to `0` when it leaves the inventory.



\*\*Reason:\*\*  

This avoids complex partial-quantity logic. Status handling stays simple and reliable.



\---



\## 3. Cost Basis Inheritance



\*\*Decision:\*\*  

When items are opened or used in a trade-up, their `unit\_cost` is transferred to the resulting item(s).



\*\*Examples:\*\*

\- Capsule bought for 0.15 → sticker receives `unit\_cost = 0.15`

\- Trade-up with inputs costing 0.20 + 0.15 + eight free skins → output skin receives `unit\_cost = 0.35`

\- That skin used in a later trade-up → the 0.35 moves forward again



\*\*Reason:\*\*  

This keeps realized profit calculations accurate even after multiple transformations.



\---



\## 4. Status Field



The `status` column records what happened to each item:



| Status       | Meaning                                      |

|--------------|----------------------------------------------|

| `Holding`    | Item is still in the inventory               |

| `Sold`       | Item was sold on the market                  |

| `Opened`     | Case, Capsule or Terminal was opened         |

| `Traded-Up`  | Item was used as input in a trade-up         |

| `Consumed`   | Sticker, charm, patch, etc. was applied      |

| `Traded`     | Item was given away in a trade               |

| `Gifted`     | Item was given away as a gift                |



\---



\## 5. Key Fields Explained



\### purchases table



| Field               | Meaning                                      |

|---------------------|----------------------------------------------|

| `amount`            | Price per unit                               |

| `quantity`          | Number of units bought                       |

| `purchase\_category` | Type of item bought (Skin, Case, Capsule…)   |

| Real money spent    | `amount × quantity`                          |



\### sales table



| Field            | Meaning                                      |

|------------------|----------------------------------------------|

| `amount`         | Price per unit received                      |

| `quantity`       | Number of units sold                         |

| `sale\_category`  | Type of item sold                            |

| Real money received | `amount × quantity`                       |



\### inventory table



| Field              | Meaning                                         |

|--------------------|-------------------------------------------------|

| `unit\_cost`        | Cost basis of this specific item                |

| `quantity`         | 1 = exists, 0 = no longer exists                |

| `status`           | Current state of the item                       |

| `acquisition\_type` | How the item entered the inventory              |

| `related\_sale\_id`  | Links to the sales row when the item was sold   |

| `case\_id`          | Steam case ID (for readability only)            |



\---



\## 6. Core Metrics



| Metric                  | Calculation                                      | Meaning                                      |

|-------------------------|--------------------------------------------------|----------------------------------------------|

| Total Money Invested    | `SUM(amount × quantity)` from purchases          | All real money put into CS2                  |

| Total Revenue           | `SUM(amount × quantity)` from sales              | All real money received from sales           |

| Cost of Goods Sold      | `SUM(unit\_cost)` where status = 'Sold'           | Cost basis of items that were sold           |

| Realized Profit         | Total Revenue − Cost of Goods Sold               | Actual profit/loss from sold items           |

| Current Cost Basis      | `SUM(unit\_cost)` where status = 'Holding'        | Capital still tied in current inventory      |



\---



\## 7. Multi-Account Handling



\- `purchases.account\_id` → account where the money was spent

\- `inventory.account\_id` → account that currently holds the item

\- `sales.account\_id` → account that received the money



Per-account profit analysis is secondary. The main focus is overall portfolio performance.



\---



\## 8. Why This Design Works



\- No double-counting of cash

\- Cost basis is never lost or inflated

\- Works correctly with free drops, gifts, openings and chained trade-ups

\- Simple enough for manual data entry

\- Structured for clean Power BI reporting

