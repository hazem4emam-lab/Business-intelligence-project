USE DataWarehouse;
GO

-- ============================================================
-- GOLD LAYER – TABLE DEFINITIONS
-- Galaxy Schema: Store Sales + Online Sales
-- Conformed Dimensions: dim_date, dim_customer, dim_product,
--                       dim_promotion
-- ============================================================

-- Step 1: Drop ALL foreign keys in the gold schema first so no
--         table can block another from being dropped.
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'ALTER TABLE [gold].[' + OBJECT_NAME(fk.parent_object_id) + N']'
             + N' DROP CONSTRAINT [' + fk.name + N'];' + CHAR(13)
FROM   sys.foreign_keys fk
WHERE  SCHEMA_NAME(fk.schema_id) = 'gold';
IF LEN(@sql) > 0 EXEC sp_executesql @sql;
GO

-- Step 2: Drop old stale tables from previous schema
DROP TABLE IF EXISTS gold.fact_online_orders;
DROP TABLE IF EXISTS gold.dim_delivery_provider;
GO

-- Step 3: Drop fact tables
DROP TABLE IF EXISTS gold.fact_store_sales;
DROP TABLE IF EXISTS gold.fact_online_sales;
GO

-- Step 4: Drop dimensions
DROP TABLE IF EXISTS gold.dim_date;
DROP TABLE IF EXISTS gold.dim_customer;
DROP TABLE IF EXISTS gold.dim_product;
DROP TABLE IF EXISTS gold.dim_store;
DROP TABLE IF EXISTS gold.dim_employee;
DROP TABLE IF EXISTS gold.dim_promotion;
DROP TABLE IF EXISTS gold.dim_warehouse;
DROP TABLE IF EXISTS gold.dim_order_status;
DROP TABLE IF EXISTS gold.dim_payment_method;
GO

-- ============================================================
-- CONFORMED DIMENSION: dim_date
-- Grain: one row per calendar day
-- Shared by: fact_store_sales, fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_date (
    Date_Key   INT          NOT NULL PRIMARY KEY,   -- surrogate: YYYYMMDD
    Full_Date  DATE         NOT NULL,
    Day        INT          NOT NULL,
    Month      INT          NOT NULL,
    Month_Name NVARCHAR(20) NOT NULL,
    Quarter    INT          NOT NULL,
    Year       INT          NOT NULL,
    Weekday    NVARCHAR(20) NOT NULL,
    Is_Weekend BIT          NOT NULL
);
GO

-- ============================================================
-- CONFORMED DIMENSION: dim_customer
-- Grain: one row per customer
-- Shared by: fact_store_sales, fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_customer (
    Customer_Key  INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID   INT           NOT NULL,
    First_Name    NVARCHAR(100) NOT NULL,
    Last_Name     NVARCHAR(100) NOT NULL,
    Full_Name     NVARCHAR(200) NOT NULL,
    Gender        NVARCHAR(20)  NOT NULL,
    City          NVARCHAR(100) NOT NULL,
    Loyalty_Level NVARCHAR(50)  NOT NULL,
    Email         NVARCHAR(150) NOT NULL
);
GO

-- ============================================================
-- CONFORMED DIMENSION: dim_product
-- Grain: one row per product
-- Shared by: fact_store_sales, fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_product (
    Product_Key     INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID      INT           NOT NULL,
    SKU             NVARCHAR(100) NOT NULL,
    Product_Name    NVARCHAR(200) NOT NULL,
    Brand_Name      NVARCHAR(100) NOT NULL,
    Department_Name NVARCHAR(100) NOT NULL,
    Package_Size    NVARCHAR(100) NOT NULL
);
GO

-- ============================================================
-- CONFORMED DIMENSION: dim_promotion
-- Grain: one row per promotion
-- Shared by: fact_store_sales, fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_promotion (
    Promotion_Key    INT IDENTITY(1,1) PRIMARY KEY,
    Promotion_ID     INT          NOT NULL,
    Promo_Type       NVARCHAR(100) NOT NULL,
    Discount_Percent DECIMAL(5,2)  NOT NULL,
    Start_Date       DATE          NOT NULL,
    End_Date         DATE          NOT NULL
);
GO

-- ============================================================
-- SCHEMA 1 DIMENSION: dim_store
-- Grain: one row per store
-- Used by: fact_store_sales
-- ============================================================
CREATE TABLE gold.dim_store (
    Store_Key    INT IDENTITY(1,1) PRIMARY KEY,
    Store_ID     INT           NOT NULL,
    Store_Name   NVARCHAR(200) NOT NULL,
    City         NVARCHAR(100) NOT NULL,
    State        NVARCHAR(10)  NOT NULL,
    Region       NVARCHAR(100) NOT NULL,
    Opening_Date DATE          NOT NULL
);
GO

-- ============================================================
-- SCHEMA 1 DIMENSION: dim_employee
-- Grain: one row per employee
-- Used by: fact_store_sales
-- ============================================================
CREATE TABLE gold.dim_employee (
    Employee_Key INT IDENTITY(1,1) PRIMARY KEY,
    Employee_ID  INT           NOT NULL,
    Full_Name    NVARCHAR(200) NOT NULL,
    Gender       NVARCHAR(20)  NOT NULL,
    Position     NVARCHAR(100) NOT NULL,
    Hire_Date    DATE          NOT NULL
);
GO

-- ============================================================
-- SCHEMA 2 DIMENSION: dim_warehouse
-- Grain: one row per warehouse
-- Used by: fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_warehouse (
    Warehouse_Key  INT IDENTITY(1,1) PRIMARY KEY,
    Warehouse_ID   INT           NOT NULL,
    Warehouse_Name NVARCHAR(200) NOT NULL,
    City           NVARCHAR(100) NOT NULL,
    State          NVARCHAR(10)  NOT NULL
);
GO

-- ============================================================
-- SCHEMA 2 DIMENSION: dim_order_status
-- Grain: one row per distinct order status value
-- Used by: fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_order_status (
    Order_Status_Key INT IDENTITY(1,1) PRIMARY KEY,
    Status_Name      NVARCHAR(50)  NOT NULL,
    Description      NVARCHAR(200) NOT NULL
);
GO

-- ============================================================
-- SCHEMA 2 DIMENSION: dim_payment_method
-- Grain: one row per distinct payment method
-- Used by: fact_online_sales
-- ============================================================
CREATE TABLE gold.dim_payment_method (
    Payment_Method_Key INT IDENTITY(1,1) PRIMARY KEY,
    Method_Name        NVARCHAR(100) NOT NULL,
    Provider           NVARCHAR(100) NOT NULL
);
GO

-- ============================================================
-- STAR SCHEMA 1 – FACT TABLE: fact_store_sales
-- Grain: one row per POS transaction line item
-- ============================================================
CREATE TABLE gold.fact_store_sales (
    Sales_ID       INT IDENTITY(1,1) PRIMARY KEY,
    Date_Key       INT           NOT NULL REFERENCES gold.dim_date(Date_Key),
    Store_Key      INT           NOT NULL REFERENCES gold.dim_store(Store_Key),
    Product_Key    INT           NOT NULL REFERENCES gold.dim_product(Product_Key),
    Customer_Key   INT               NULL REFERENCES gold.dim_customer(Customer_Key),
    Employee_Key   INT           NOT NULL REFERENCES gold.dim_employee(Employee_Key),
    Promotion_Key  INT               NULL REFERENCES gold.dim_promotion(Promotion_Key),
    Transaction_ID NVARCHAR(50)  NOT NULL,
    Quantity       INT           NOT NULL,
    Unit_Price     DECIMAL(10,2) NOT NULL,
    Sales_Amount   DECIMAL(10,2) NOT NULL
);
GO

-- ============================================================
-- STAR SCHEMA 2 – FACT TABLE: fact_online_sales
-- Grain: one row per online order line item
-- ============================================================
CREATE TABLE gold.fact_online_sales (
    Online_Sales_ID    INT IDENTITY(1,1) PRIMARY KEY,
    Date_Key           INT           NOT NULL REFERENCES gold.dim_date(Date_Key),
    Customer_Key       INT               NULL REFERENCES gold.dim_customer(Customer_Key),
    Product_Key        INT           NOT NULL REFERENCES gold.dim_product(Product_Key),
    Warehouse_Key      INT           NOT NULL REFERENCES gold.dim_warehouse(Warehouse_Key),
    Promotion_Key      INT               NULL REFERENCES gold.dim_promotion(Promotion_Key),
    Order_Status_Key   INT           NOT NULL REFERENCES gold.dim_order_status(Order_Status_Key),
    Payment_Method_Key INT               NULL REFERENCES gold.dim_payment_method(Payment_Method_Key),
    Order_ID           INT           NOT NULL,
    Order_Item_ID      INT           NOT NULL,
    Quantity           INT           NOT NULL,
    Unit_Price         DECIMAL(10,2) NOT NULL,
    Sales_Amount       DECIMAL(10,2) NOT NULL
);
GO
