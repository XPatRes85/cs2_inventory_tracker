-- ============================================================
-- CS2 Inventory Tracker - Database Schema
-- ============================================================
-- Clean relational model for tracking CS2 inventory, 
-- cost basis, openings, trade-ups and profit/loss.
-- ============================================================

CREATE DATABASE IF NOT EXISTS cs2_inventory
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE cs2_inventory;

-- ------------------------------------------------------------
-- Accounts
-- ------------------------------------------------------------
CREATE TABLE accounts (
  account_id    INT NOT NULL AUTO_INCREMENT,
  account_name  VARCHAR(50) NOT NULL,
  PRIMARY KEY (account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ------------------------------------------------------------
-- Purchases (real money spent)
-- amount = unit price, quantity = number of units
-- Real money spent = amount * quantity
-- ------------------------------------------------------------
CREATE TABLE purchases (
  purchase_id         INT NOT NULL AUTO_INCREMENT,
  account_id          INT NOT NULL,
  item_name           VARCHAR(120) NOT NULL,
  purchase_category   VARCHAR(30) DEFAULT NULL,
  amount              DECIMAL(12,2) NOT NULL,
  quantity            INT NOT NULL,
  purchase_date       DATE NOT NULL,
  notes               VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (purchase_id),
  KEY fk_purchases_account (account_id),
  CONSTRAINT fk_purchases_account 
    FOREIGN KEY (account_id) REFERENCES accounts (account_id),
  CONSTRAINT chk_positive_amount 
    CHECK (amount > 0),
  CONSTRAINT chk_purchase_category 
    CHECK (purchase_category IN (
      'Skin', 'Case', 'Terminal', 'Knife', 'Gloves', 'Capsule',
      'Sticker', 'Music Kit', 'Agent', 'Case Key', 'Graffiti',
      'Charm', 'Patch', 'Collectible', 'Prime Status Upgrade',
      'Pass', 'Other'
    ))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ------------------------------------------------------------
-- Sales (real money received)
-- amount = unit price, quantity = number of units
-- Real money received = amount * quantity
-- ------------------------------------------------------------
CREATE TABLE sales (
  sale_id         INT NOT NULL AUTO_INCREMENT,
  account_id      INT NOT NULL,
  item_name       VARCHAR(120) NOT NULL,
  sale_category   VARCHAR(30) NOT NULL,
  amount          DECIMAL(12,2) NOT NULL,
  quantity        INT NOT NULL,
  sale_date       DATE NOT NULL,
  notes           VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (sale_id),
  KEY fk_sales_account (account_id),
  CONSTRAINT fk_sales_account 
    FOREIGN KEY (account_id) REFERENCES accounts (account_id),
  CONSTRAINT chk_positive_sale_amount 
    CHECK (amount > 0),
  CONSTRAINT chk_sale_category 
    CHECK (sale_category IN (
      'Skin', 'Case', 'Terminal', 'Knife', 'Gloves', 'Capsule',
      'Sticker', 'Music Kit', 'Agent', 'Case Key', 'Graffiti',
      'Charm', 'Patch', 'Collectible', 'Other'
    ))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ------------------------------------------------------------
-- Inventory
-- One physical item = one row
-- quantity = 1 while held, 0 when the item no longer exists
-- unit_cost carries the cost basis through openings & trade-ups
-- ------------------------------------------------------------
CREATE TABLE inventory (
  inventory_id      INT NOT NULL AUTO_INCREMENT,
  account_id        INT NOT NULL,
  case_id           INT DEFAULT NULL COMMENT 'Steam case ID for readability',
  item_name         VARCHAR(120) NOT NULL,
  item_type         VARCHAR(30) NOT NULL,
  item_category     VARCHAR(20) NOT NULL DEFAULT 'Normal',
  weapon            VARCHAR(50) DEFAULT NULL,
  exterior          VARCHAR(30) DEFAULT NULL,
  rarity            VARCHAR(30) DEFAULT NULL,
  collection        VARCHAR(80) DEFAULT NULL,
  acquisition_type  VARCHAR(30) NOT NULL,
  unit_cost         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  quantity          INT NOT NULL,
  status            VARCHAR(20) NOT NULL,
  related_sale_id   INT DEFAULT NULL,
  acquired_date     DATE NOT NULL,
  notes             VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (inventory_id),
  KEY fk_inventory_account (account_id),
  KEY fk_inventory_sale (related_sale_id),
  CONSTRAINT fk_inventory_account 
    FOREIGN KEY (account_id) REFERENCES accounts (account_id),
  CONSTRAINT fk_inventory_sale 
    FOREIGN KEY (related_sale_id) REFERENCES sales (sale_id),
  CONSTRAINT chk_item_type 
    CHECK (item_type IN (
      'Weapon', 'Case', 'Terminal', 'Knife', 'Gloves', 'Capsule',
      'Sticker', 'Music Kit', 'Agent', 'Case Key', 'Graffiti',
      'Charm', 'Patch', 'Collectible'
    )),
  CONSTRAINT chk_item_category 
    CHECK (item_category IN ('Normal', 'Souvenir', 'StatTrak™')),
  CONSTRAINT chk_acquisition_type 
    CHECK (acquisition_type IN (
      'Purchase', 'Drop', 'Case Opening', 'Terminal Opening',
      'Capsule Opening', 'Trade-Up', 'Trade', 'Gift',
      'Redeemed', 'Opening Inventory', 'Other'
    )),
  CONSTRAINT chk_status 
    CHECK (status IN (
      'Holding', 'Sold', 'Opened', 'Consumed',
      'Traded-Up', 'Traded', 'Gifted'
    )),
  CONSTRAINT chk_positive_qty 
    CHECK (quantity >= 0),
  CONSTRAINT chk_positive_unit_cost 
    CHECK (unit_cost >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;