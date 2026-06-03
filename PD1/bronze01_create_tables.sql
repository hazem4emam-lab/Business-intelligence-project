USE DataWarehouse;
GO

-- BRANDS
CREATE TABLE bronze.brands (
    Brand_ID    NVARCHAR(50),
    Brand_Name  NVARCHAR(100)
);
GO

-- CUSTOMERS
CREATE TABLE bronze.customers (
    Customer_ID   NVARCHAR(50),
    First_Name    NVARCHAR(100),
    Last_Name     NVARCHAR(100),
    Gender        NVARCHAR(20),
    City          NVARCHAR(100),
    Loyalty_Level NVARCHAR(50),
    Email         NVARCHAR(150)
);
GO

-- DEPARTMENTS
CREATE TABLE bronze.departments (
    Department_ID   NVARCHAR(50),
    Department_Name NVARCHAR(100)
);
GO

-- STORES
CREATE TABLE bronze.stores (
    Store_ID     NVARCHAR(50),
    Store_Name   NVARCHAR(200),
    City         NVARCHAR(100),
    State        NVARCHAR(10),
    Region       NVARCHAR(100),
    Opening_Date NVARCHAR(50)
);
GO

-- WAREHOUSES
CREATE TABLE bronze.warehouses (
    Warehouse_ID   NVARCHAR(50),
    Warehouse_Name NVARCHAR(200),
    City           NVARCHAR(100),
    State          NVARCHAR(10)
);
GO

-- EMPLOYEES
CREATE TABLE bronze.employees (
    Employee_ID NVARCHAR(50),
    Name        NVARCHAR(200),
    Gender      NVARCHAR(20),
    Position    NVARCHAR(100),
    Store_ID    NVARCHAR(50),
    Hire_Date   NVARCHAR(50)
);
GO

-- SUPPLIERS
CREATE TABLE bronze.suppliers (
    Supplier_ID   NVARCHAR(50),
    Supplier_Name NVARCHAR(200),
    Country       NVARCHAR(100),
    Phone         NVARCHAR(50)
);
GO

-- PRODUCTS
CREATE TABLE bronze.products (
    Product_ID    NVARCHAR(50),
    SKU           NVARCHAR(100),
    Product_Name  NVARCHAR(200),
    Brand_ID      NVARCHAR(50),
    Department_ID NVARCHAR(50),
    Package_Size  NVARCHAR(100)
);
GO

-- PRODUCT_SUPPLIERS
CREATE TABLE bronze.product_suppliers (
    Product_ID   NVARCHAR(50),
    Supplier_ID  NVARCHAR(50),
    Supply_Price NVARCHAR(50)
);
GO

-- PROMOTIONS
CREATE TABLE bronze.promotions (
    Promotion_ID     NVARCHAR(50),
    Promo_Type       NVARCHAR(100),
    Discount_Percent NVARCHAR(50),
    Start_Date       NVARCHAR(50),
    End_Date         NVARCHAR(50)
);
GO

-- REGISTERS
CREATE TABLE bronze.registers (
    Register_ID     NVARCHAR(50),
    Store_ID        NVARCHAR(50),
    Register_Number NVARCHAR(50)
);
GO

-- DELIVERY_PROVIDERS
CREATE TABLE bronze.delivery_providers (
    Provider_ID   NVARCHAR(50),
    Provider_Name NVARCHAR(200),
    Phone         NVARCHAR(50)
);
GO

-- ONLINE_ORDERS
CREATE TABLE bronze.online_orders (
    Order_ID     NVARCHAR(50),
    Customer_ID  NVARCHAR(50),
    Warehouse_ID NVARCHAR(50),
    Order_Time   NVARCHAR(50),
    Order_Status NVARCHAR(50),
    Order_Total  NVARCHAR(50)
);
GO

-- ONLINE_ORDER_ITEMS
CREATE TABLE bronze.online_order_items (
    Order_Item_ID NVARCHAR(50),
    Order_ID      NVARCHAR(50),
    Product_ID    NVARCHAR(50),
    Promotion_ID  NVARCHAR(50),
    Quantity      NVARCHAR(50),
    Unit_Price    NVARCHAR(50)
);
GO

-- PAYMENTS
CREATE TABLE bronze.payments (
    Payment_ID     NVARCHAR(50),
    Order_ID       NVARCHAR(50),
    Payment_Method NVARCHAR(100),
    Payment_Amount NVARCHAR(50),
    Payment_Time   NVARCHAR(50)
);
GO

-- DELIVERIES
CREATE TABLE bronze.deliveries (
    Delivery_ID     NVARCHAR(50),
    Order_ID        NVARCHAR(50),
    Provider_ID     NVARCHAR(50),
    Ship_Date       NVARCHAR(50),
    Delivery_Date   NVARCHAR(50),
    Delivery_Status NVARCHAR(50)
);
GO

-- POS_TRANSACTIONS
-- NOTE: Transaction_ID is text format e.g. TXN-20250406-000001
CREATE TABLE bronze.pos_transactions (
    Transaction_ID   NVARCHAR(50),
    Store_ID         NVARCHAR(50),
    Register_ID      NVARCHAR(50),
    Employee_ID      NVARCHAR(50),
    Customer_ID      NVARCHAR(50),
    Transaction_Time NVARCHAR(50)
);
GO

-- TRANSACTION_ITEMS
-- NOTE: Transaction_ID is text format e.g. TXN-20250406-000001
CREATE TABLE bronze.transaction_items (
    Line_ID        NVARCHAR(50),
    Transaction_ID NVARCHAR(50),
    Product_ID     NVARCHAR(50),
    Promotion_ID   NVARCHAR(50),
    Quantity       NVARCHAR(50),
    Unit_Price     NVARCHAR(50)
);
GO

-- INVENTORY
CREATE TABLE bronze.inventory (
    Inventory_ID NVARCHAR(50),
    Store_ID     NVARCHAR(50),
    Product_ID   NVARCHAR(50),
    Stock_Level  NVARCHAR(50),
    Last_Updated NVARCHAR(50)
);
GO