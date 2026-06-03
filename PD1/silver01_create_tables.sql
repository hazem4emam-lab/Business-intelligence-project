USE DataWarehouse;
GO

DROP TABLE IF EXISTS silver.load_log;
DROP TABLE IF EXISTS silver.inventory;
DROP TABLE IF EXISTS silver.transaction_items;
DROP TABLE IF EXISTS silver.pos_transactions;
DROP TABLE IF EXISTS silver.deliveries;
DROP TABLE IF EXISTS silver.payments;
DROP TABLE IF EXISTS silver.online_order_items;
DROP TABLE IF EXISTS silver.online_orders;
DROP TABLE IF EXISTS silver.delivery_providers;
DROP TABLE IF EXISTS silver.registers;
DROP TABLE IF EXISTS silver.promotions;
DROP TABLE IF EXISTS silver.product_suppliers;
DROP TABLE IF EXISTS silver.products;
DROP TABLE IF EXISTS silver.suppliers;
DROP TABLE IF EXISTS silver.employees;
DROP TABLE IF EXISTS silver.warehouses;
DROP TABLE IF EXISTS silver.stores;
DROP TABLE IF EXISTS silver.departments;
DROP TABLE IF EXISTS silver.customers;
DROP TABLE IF EXISTS silver.brands;
GO

-- BRANDS
CREATE TABLE silver.brands (
    Brand_ID   INT,
    Brand_Name NVARCHAR(100)
);
GO

-- CUSTOMERS
CREATE TABLE silver.customers (
    Customer_ID   INT,
    First_Name    NVARCHAR(100),
    Last_Name     NVARCHAR(100),
    Full_Name     NVARCHAR(200),        -- derived: First_Name + Last_Name
    Gender        NVARCHAR(20),
    City          NVARCHAR(100),
    Loyalty_Level NVARCHAR(50),
    Email         NVARCHAR(150)
);
GO

-- DEPARTMENTS
CREATE TABLE silver.departments (
    Department_ID   INT,
    Department_Name NVARCHAR(100)
);
GO

-- STORES
CREATE TABLE silver.stores (
    Store_ID     INT,
    Store_Name   NVARCHAR(200),
    City         NVARCHAR(100),
    State        NVARCHAR(10),
    Region       NVARCHAR(100),
    Opening_Date DATE
);
GO

-- WAREHOUSES
CREATE TABLE silver.warehouses (
    Warehouse_ID   INT,
    Warehouse_Name NVARCHAR(200),
    City           NVARCHAR(100),
    State          NVARCHAR(10)
);
GO

-- EMPLOYEES
CREATE TABLE silver.employees (
    Employee_ID INT,
    Full_Name   NVARCHAR(200),
    Gender      NVARCHAR(20),
    Position    NVARCHAR(100),
    Store_ID    INT,
    Hire_Date   DATE
);
GO

-- SUPPLIERS
CREATE TABLE silver.suppliers (
    Supplier_ID   INT,
    Supplier_Name NVARCHAR(200),
    Country       NVARCHAR(100),
    Phone         NVARCHAR(50)
);
GO

-- PRODUCTS
-- Enriched: Brand_Name from bronze.brands, Department_Name from bronze.departments
CREATE TABLE silver.products (
    Product_ID      INT,
    SKU             NVARCHAR(100),
    Product_Name    NVARCHAR(200),
    Brand_ID        INT,
    Brand_Name      NVARCHAR(100),      -- enriched from bronze.brands
    Department_ID   INT,
    Department_Name NVARCHAR(100),      -- enriched from bronze.departments
    Package_Size    NVARCHAR(100)
);
GO

-- PRODUCT_SUPPLIERS
-- Enriched: Supplier_Name and Country from bronze.suppliers
CREATE TABLE silver.product_suppliers (
    Product_ID    INT,
    Supplier_ID   INT,
    Supplier_Name NVARCHAR(200),        -- enriched from bronze.suppliers
    Country       NVARCHAR(100),        -- enriched from bronze.suppliers
    Supply_Price  DECIMAL(10,2)
);
GO

-- PROMOTIONS
CREATE TABLE silver.promotions (
    Promotion_ID     INT,
    Promo_Type       NVARCHAR(100),
    Discount_Percent DECIMAL(5,2),
    Start_Date       DATE,
    End_Date         DATE,
    Duration_Days    INT                -- derived: days the promotion runs
);
GO

-- REGISTERS
CREATE TABLE silver.registers (
    Register_ID     INT,
    Store_ID        INT,
    Register_Number INT
);
GO

-- DELIVERY_PROVIDERS
CREATE TABLE silver.delivery_providers (
    Provider_ID   INT,
    Provider_Name NVARCHAR(200),
    Phone         NVARCHAR(50)
);
GO

-- ONLINE_ORDERS
-- Enriched: Customer_Name from bronze.customers, Warehouse_Name from bronze.warehouses
CREATE TABLE silver.online_orders (
    Order_ID       INT,
    Customer_ID    INT,
    Customer_Name  NVARCHAR(200),       -- enriched from bronze.customers
    Warehouse_ID   INT,
    Warehouse_Name NVARCHAR(200),       -- enriched from bronze.warehouses
    Order_Time     DATETIME,
    Order_Status   NVARCHAR(50),
    Order_Total    DECIMAL(10,2)
);
GO

-- ONLINE_ORDER_ITEMS
-- Enriched: Product_Name from bronze.products, Discount_Percent from bronze.promotions
CREATE TABLE silver.online_order_items (
    Order_Item_ID     INT,
    Order_ID          INT,
    Product_ID        INT,
    Product_Name      NVARCHAR(200),    -- enriched from bronze.products
    Promotion_ID      INT,
    Discount_Percent  DECIMAL(5,2),     -- enriched from bronze.promotions
    Quantity          INT,
    Unit_Price        DECIMAL(10,2),
    Total_Line_Amount DECIMAL(10,2)     -- derived: Quantity * Unit_Price
);
GO

-- PAYMENTS
CREATE TABLE silver.payments (
    Payment_ID     INT,
    Order_ID       INT,
    Payment_Method NVARCHAR(100),
    Payment_Amount DECIMAL(10,2),
    Payment_Time   DATETIME
);
GO

-- DELIVERIES
-- Enriched: Provider_Name from bronze.delivery_providers
CREATE TABLE silver.deliveries (
    Delivery_ID     INT,
    Order_ID        INT,
    Provider_ID     INT,
    Provider_Name   NVARCHAR(200),      -- enriched from bronze.delivery_providers
    Ship_Date       DATETIME,
    Delivery_Date   DATETIME,
    Delivery_Status NVARCHAR(50),
    Delivery_Days   INT                 -- derived: days between ship and delivery
);
GO

-- POS_TRANSACTIONS
-- NOTE: Transaction_ID stays NVARCHAR - format is TXN-20250406-000001
-- Enriched: Store_Name from bronze.stores, Employee_Name from bronze.employees
CREATE TABLE silver.pos_transactions (
    Transaction_ID   NVARCHAR(50),
    Store_ID         INT,
    Store_Name       NVARCHAR(200),     -- enriched from bronze.stores
    Register_ID      INT,
    Employee_ID      INT,
    Employee_Name    NVARCHAR(200),     -- enriched from bronze.employees
    Customer_ID      INT,
    Transaction_Time DATETIME
);
GO

-- TRANSACTION_ITEMS
-- Enriched: Product_Name from bronze.products, Discount_Percent from bronze.promotions
CREATE TABLE silver.transaction_items (
    Line_ID           INT,
    Transaction_ID    NVARCHAR(50),     -- stays NVARCHAR, matches POS_TRANSACTIONS
    Product_ID        INT,
    Product_Name      NVARCHAR(200),    -- enriched from bronze.products
    Promotion_ID      INT,
    Discount_Percent  DECIMAL(5,2),     -- enriched from bronze.promotions
    Quantity          INT,
    Unit_Price        DECIMAL(10,2),
    Total_Line_Amount DECIMAL(10,2)     -- derived: Quantity * Unit_Price
);
GO

-- INVENTORY
-- Enriched: Store_Name from bronze.stores, Product_Name from bronze.products
CREATE TABLE silver.inventory (
    Inventory_ID INT,
    Store_ID     INT,
    Store_Name   NVARCHAR(200),         -- enriched from bronze.stores
    Product_ID   INT,
    Product_Name NVARCHAR(200),         -- enriched from bronze.products
    Stock_Level  INT,
    Last_Updated DATETIME
);
GO
