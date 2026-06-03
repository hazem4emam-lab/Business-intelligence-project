USE DataWarehouse;
GO

-- ============================================================
-- GOLD LAYER – LOAD PROCEDURE
-- Populates all Gold dimensions and fact tables from Silver
-- Execution order: facts cleared first, then dims, then reload
-- ============================================================

CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- CLEAR: facts first (they hold FKs), then dimensions
    -- Using DELETE on dims instead of TRUNCATE to avoid FK
    -- blocking from any external references in the gold schema
    -- ============================================================
    TRUNCATE TABLE gold.fact_store_sales;
    TRUNCATE TABLE gold.fact_online_sales;

    DELETE FROM gold.dim_date;
    DELETE FROM gold.dim_customer;
    DELETE FROM gold.dim_product;
    DELETE FROM gold.dim_promotion;
    DELETE FROM gold.dim_store;
    DELETE FROM gold.dim_employee;
    DELETE FROM gold.dim_warehouse;
    DELETE FROM gold.dim_order_status;
    DELETE FROM gold.dim_payment_method;

    -- ============================================================
    -- 1. dim_date
    -- Generate one row for every date that appears in either
    -- silver.pos_transactions or silver.online_orders.
    -- Grain: calendar day (Date_Key = YYYYMMDD integer)
    -- ============================================================
    WITH date_spine AS (
        SELECT CAST(Transaction_Time AS DATE) AS txn_date
        FROM   silver.pos_transactions
        WHERE  Transaction_Time IS NOT NULL
        UNION
        SELECT CAST(Order_Time AS DATE)
        FROM   silver.online_orders
        WHERE  Order_Time IS NOT NULL
    )
    INSERT INTO gold.dim_date (
        Date_Key, Full_Date, Day, Month, Month_Name,
        Quarter, Year, Weekday, Is_Weekend
    )
    SELECT DISTINCT
        CAST(FORMAT(txn_date, 'yyyyMMdd') AS INT)              AS Date_Key,
        txn_date                                               AS Full_Date,
        DAY(txn_date)                                          AS Day,
        MONTH(txn_date)                                        AS Month,
        DATENAME(MONTH,   txn_date)                            AS Month_Name,
        DATEPART(QUARTER, txn_date)                            AS Quarter,
        YEAR(txn_date)                                         AS Year,
        DATENAME(WEEKDAY, txn_date)                            AS Weekday,
        CASE WHEN DATEPART(WEEKDAY, txn_date) IN (1,7)
             THEN 1 ELSE 0 END                                 AS Is_Weekend
    FROM date_spine;

    -- ============================================================
    -- 2. dim_customer  (conformed)
    -- Source: silver.customers
    -- ============================================================
    INSERT INTO gold.dim_customer (
        Customer_ID, First_Name, Last_Name, Full_Name,
        Gender, City, Loyalty_Level, Email
    )
    SELECT
        Customer_ID,
        ISNULL(First_Name,    'Unknown'),
        ISNULL(Last_Name,     'Unknown'),
        ISNULL(Full_Name,     'Unknown'),
        ISNULL(Gender,        'Unknown'),
        ISNULL(City,          'Unknown'),
        ISNULL(Loyalty_Level, 'Unknown'),
        ISNULL(Email,         'unknown@unknown.com')
    FROM silver.customers;

    -- ============================================================
    -- 3. dim_product  (conformed)
    -- Source: silver.products
    -- ============================================================
    INSERT INTO gold.dim_product (
        Product_ID, SKU, Product_Name,
        Brand_Name, Department_Name, Package_Size
    )
    SELECT
        Product_ID,
        ISNULL(SKU,             'N/A'),
        ISNULL(Product_Name,    'Unknown'),
        ISNULL(Brand_Name,      'Unknown'),
        ISNULL(Department_Name, 'Unknown'),
        ISNULL(Package_Size,    'N/A')
    FROM silver.products;

    -- ============================================================
    -- 4. dim_promotion  (conformed)
    -- Source: silver.promotions
    -- ============================================================
    INSERT INTO gold.dim_promotion (
        Promotion_ID, Promo_Type, Discount_Percent,
        Start_Date, End_Date
    )
    SELECT
        Promotion_ID,
        ISNULL(Promo_Type,       'N/A'),
        ISNULL(Discount_Percent, 0),
        Start_Date,
        End_Date
    FROM silver.promotions;

    -- ============================================================
    -- 5. dim_store  (schema 1 only)
    -- Source: silver.stores
    -- ============================================================
    INSERT INTO gold.dim_store (
        Store_ID, Store_Name, City, State, Region, Opening_Date
    )
    SELECT
        Store_ID,
        ISNULL(Store_Name, 'Unknown'),
        ISNULL(City,       'Unknown'),
        ISNULL(State,      'N/A'),
        ISNULL(Region,     'Unknown'),
        Opening_Date
    FROM silver.stores;

    -- ============================================================
    -- 6. dim_employee  (schema 1 only)
    -- Source: silver.employees
    -- ============================================================
    INSERT INTO gold.dim_employee (
        Employee_ID, Full_Name, Gender, Position, Hire_Date
    )
    SELECT
        Employee_ID,
        ISNULL(Full_Name, 'Unknown'),
        ISNULL(Gender,    'Unknown'),
        ISNULL(Position,  'Unknown'),
        Hire_Date
    FROM silver.employees;

    -- ============================================================
    -- 7. dim_warehouse  (schema 2 only)
    -- Source: silver.warehouses
    -- ============================================================
    INSERT INTO gold.dim_warehouse (
        Warehouse_ID, Warehouse_Name, City, State
    )
    SELECT
        Warehouse_ID,
        ISNULL(Warehouse_Name, 'Unknown'),
        ISNULL(City,           'Unknown'),
        ISNULL(State,          'N/A')
    FROM silver.warehouses;

    -- ============================================================
    -- 8. dim_order_status  (schema 2 only)
    -- Derive distinct status values from silver.online_orders
    -- ============================================================
    INSERT INTO gold.dim_order_status (Status_Name, Description)
    SELECT DISTINCT
        ISNULL(Order_Status, 'Unknown') AS Status_Name,
        CASE ISNULL(Order_Status, 'Unknown')
            WHEN 'Pending'   THEN 'Order placed but not yet processed'
            WHEN 'Shipped'   THEN 'Order dispatched to the delivery provider'
            WHEN 'Delivered' THEN 'Order successfully delivered to customer'
            WHEN 'Cancelled' THEN 'Order was cancelled before fulfilment'
            ELSE 'Status not defined'
        END AS Description
    FROM silver.online_orders;

    -- ============================================================
    -- 9. dim_payment_method  (schema 2 only)
    -- Derive distinct payment methods from silver.payments
    -- ============================================================
    INSERT INTO gold.dim_payment_method (Method_Name, Provider)
    SELECT DISTINCT
        ISNULL(Payment_Method, 'Unknown') AS Method_Name,
        CASE ISNULL(Payment_Method, 'Unknown')
            WHEN 'Credit Card' THEN 'Card Network'
            WHEN 'Debit Card'  THEN 'Card Network'
            WHEN 'PayPal'      THEN 'PayPal'
            WHEN 'Apple Pay'   THEN 'Apple'
            WHEN 'Google Pay'  THEN 'Google'
            WHEN 'Cash'        THEN 'Cash'
            ELSE 'Other'
        END AS Provider
    FROM silver.payments;

    -- ============================================================
    -- 10. fact_store_sales
    -- Grain: one row per POS transaction line item
    -- ============================================================
    INSERT INTO gold.fact_store_sales (
        Date_Key, Store_Key, Product_Key, Customer_Key,
        Employee_Key, Promotion_Key,
        Transaction_ID, Quantity, Unit_Price, Sales_Amount
    )
    SELECT
        CAST(FORMAT(CAST(pt.Transaction_Time AS DATE), 'yyyyMMdd') AS INT) AS Date_Key,
        ds.Store_Key,
        dp.Product_Key,
        dc.Customer_Key,
        de.Employee_Key,
        dpr.Promotion_Key,
        pt.Transaction_ID,
        ISNULL(ti.Quantity,          0) AS Quantity,
        ISNULL(ti.Unit_Price,        0) AS Unit_Price,
        ISNULL(ti.Total_Line_Amount, 0) AS Sales_Amount
    FROM silver.transaction_items ti
    INNER JOIN silver.pos_transactions pt  ON pt.Transaction_ID = ti.Transaction_ID
    INNER JOIN gold.dim_store          ds  ON ds.Store_ID       = pt.Store_ID
    INNER JOIN gold.dim_employee       de  ON de.Employee_ID    = pt.Employee_ID
    INNER JOIN gold.dim_product        dp  ON dp.Product_ID     = ti.Product_ID
    LEFT  JOIN gold.dim_customer       dc  ON dc.Customer_ID    = pt.Customer_ID
    LEFT  JOIN gold.dim_promotion      dpr ON dpr.Promotion_ID  = ti.Promotion_ID
    WHERE pt.Transaction_Time IS NOT NULL;

    -- ============================================================
    -- 11. fact_online_sales
    -- Grain: one row per online order line item
    -- ============================================================
    INSERT INTO gold.fact_online_sales (
        Date_Key, Customer_Key, Product_Key, Warehouse_Key,
        Promotion_Key, Order_Status_Key, Payment_Method_Key,
        Order_ID, Order_Item_ID, Quantity, Unit_Price, Sales_Amount
    )
    SELECT
        CAST(FORMAT(CAST(oo.Order_Time AS DATE), 'yyyyMMdd') AS INT) AS Date_Key,
        dc.Customer_Key,
        dp.Product_Key,
        dw.Warehouse_Key,
        dpr.Promotion_Key,
        dos.Order_Status_Key,
        dpm.Payment_Method_Key,
        oo.Order_ID,
        oi.Order_Item_ID,
        ISNULL(oi.Quantity,          0) AS Quantity,
        ISNULL(oi.Unit_Price,        0) AS Unit_Price,
        ISNULL(oi.Total_Line_Amount, 0) AS Sales_Amount
    FROM silver.online_order_items oi
    INNER JOIN silver.online_orders      oo  ON oo.Order_ID      = oi.Order_ID
    INNER JOIN gold.dim_warehouse        dw  ON dw.Warehouse_ID  = oo.Warehouse_ID
    INNER JOIN gold.dim_product          dp  ON dp.Product_ID    = oi.Product_ID
    INNER JOIN gold.dim_order_status     dos ON dos.Status_Name  = oo.Order_Status
    LEFT  JOIN gold.dim_customer         dc  ON dc.Customer_ID   = oo.Customer_ID
    LEFT  JOIN gold.dim_promotion        dpr ON dpr.Promotion_ID = oi.Promotion_ID
    LEFT  JOIN (
        SELECT Order_ID, Payment_Method,
               ROW_NUMBER() OVER (PARTITION BY Order_ID ORDER BY Payment_ID) AS rn
        FROM silver.payments
    ) pay ON pay.Order_ID = oo.Order_ID AND pay.rn = 1
    LEFT  JOIN gold.dim_payment_method   dpm ON dpm.Method_Name  = pay.Payment_Method
    WHERE oo.Order_Time IS NOT NULL;

    PRINT 'Gold load complete.';
END;
GO

-- Execute the procedure
EXEC gold.load_gold;
GO

-- ============================================================
-- VALIDATION QUERIES
-- ============================================================

-- Row counts for all gold tables
SELECT 'dim_date'           AS table_name, COUNT(*) AS row_count FROM gold.dim_date           UNION ALL
SELECT 'dim_customer'       ,              COUNT(*)              FROM gold.dim_customer        UNION ALL
SELECT 'dim_product'        ,              COUNT(*)              FROM gold.dim_product         UNION ALL
SELECT 'dim_promotion'      ,              COUNT(*)              FROM gold.dim_promotion       UNION ALL
SELECT 'dim_store'          ,              COUNT(*)              FROM gold.dim_store           UNION ALL
SELECT 'dim_employee'       ,              COUNT(*)              FROM gold.dim_employee        UNION ALL
SELECT 'dim_warehouse'      ,              COUNT(*)              FROM gold.dim_warehouse       UNION ALL
SELECT 'dim_order_status'   ,              COUNT(*)              FROM gold.dim_order_status    UNION ALL
SELECT 'dim_payment_method' ,              COUNT(*)              FROM gold.dim_payment_method  UNION ALL
SELECT 'fact_store_sales'   ,              COUNT(*)              FROM gold.fact_store_sales    UNION ALL
SELECT 'fact_online_sales'  ,              COUNT(*)              FROM gold.fact_online_sales
ORDER BY table_name;

-- Referential integrity spot-checks
SELECT COUNT(*) AS orphan_store_sales_no_date
FROM   gold.fact_store_sales f
WHERE  NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.Date_Key = f.Date_Key);

SELECT COUNT(*) AS orphan_online_sales_no_date
FROM   gold.fact_online_sales f
WHERE  NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.Date_Key = f.Date_Key);

-- Cross-schema test: customers who bought both in-store and online
SELECT dc.Customer_ID, dc.Full_Name,
       COUNT(DISTINCT fs.Sales_ID)        AS store_line_items,
       COUNT(DISTINCT fo.Online_Sales_ID) AS online_line_items
FROM        gold.dim_customer dc
INNER JOIN  gold.fact_store_sales  fs ON fs.Customer_Key = dc.Customer_Key
INNER JOIN  gold.fact_online_sales fo ON fo.Customer_Key = dc.Customer_Key
GROUP BY dc.Customer_ID, dc.Full_Name
ORDER BY store_line_items DESC;
