USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @rows INT;

    -- ===========================
    -- BRANDS
    -- Transformations:
    --   Cast Brand_ID to INT
    --   TRIM Brand_Name
    --   Deduplicate on Brand_ID (keep first occurrence)
    -- ===========================
    TRUNCATE TABLE silver.brands;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Brand_ID AS INT) ORDER BY Brand_ID) AS rn
        FROM bronze.brands
        WHERE TRIM(ISNULL(Brand_ID, '')) != ''
    )
    INSERT INTO silver.brands
    SELECT
        TRY_CAST(Brand_ID AS INT),
        TRIM(Brand_Name)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.brands);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.brands', @rows, 'SUCCESS');

    -- ===========================
    -- CUSTOMERS
    -- Transformations:
    --   Cast Customer_ID to INT
    --   TRIM all text columns
    --   Derive Full_Name = First_Name + Last_Name
    --   Lowercase Email
    --   Filter rows with NULL or blank Customer_ID
    --   Deduplicate on Customer_ID (keep first occurrence)
    -- ===========================
    TRUNCATE TABLE silver.customers;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Customer_ID AS INT) ORDER BY Customer_ID) AS rn
        FROM bronze.customers
        WHERE TRIM(ISNULL(Customer_ID, '')) != ''
    )
    INSERT INTO silver.customers
    SELECT
        TRY_CAST(Customer_ID AS INT),
        TRIM(First_Name),
        TRIM(Last_Name),
        TRIM(First_Name) + ' ' + TRIM(Last_Name) AS Full_Name,
        CASE
            WHEN UPPER(TRIM(Gender)) IN ('M', 'MALE')   THEN 'Male'
            WHEN UPPER(TRIM(Gender)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE TRIM(Gender)
        END,
        TRIM(City),
        TRIM(Loyalty_Level),
        LOWER(TRIM(Email))
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.customers);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.customers', @rows, 'SUCCESS');

    -- ===========================
    -- DEPARTMENTS
    -- Transformations:
    --   Cast Department_ID to INT
    --   TRIM Department_Name
    --   Deduplicate on Department_ID
    -- ===========================
    TRUNCATE TABLE silver.departments;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Department_ID AS INT) ORDER BY Department_ID) AS rn
        FROM bronze.departments
        WHERE TRIM(ISNULL(Department_ID, '')) != ''
    )
    INSERT INTO silver.departments
    SELECT
        TRY_CAST(Department_ID AS INT),
        TRIM(Department_Name)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.departments);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.departments', @rows, 'SUCCESS');

    -- ===========================
    -- STORES
    -- Transformations:
    --   Cast Store_ID to INT
    --   Cast Opening_Date to DATE
    --   TRIM all text columns
    --   Deduplicate on Store_ID
    -- ===========================
    TRUNCATE TABLE silver.stores;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Store_ID AS INT) ORDER BY Store_ID) AS rn
        FROM bronze.stores
        WHERE TRIM(ISNULL(Store_ID, '')) != ''
    )
    INSERT INTO silver.stores
    SELECT
        TRY_CAST(Store_ID AS INT),
        TRIM(Store_Name),
        TRIM(City),
        TRIM(State),
        TRIM(Region),
        TRY_CAST(Opening_Date AS DATE)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.stores);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.stores', @rows, 'SUCCESS');

    -- ===========================
    -- WAREHOUSES
    -- Transformations:
    --   Cast Warehouse_ID to INT
    --   TRIM text columns
    --   Deduplicate on Warehouse_ID
    -- ===========================
    TRUNCATE TABLE silver.warehouses;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Warehouse_ID AS INT) ORDER BY Warehouse_ID) AS rn
        FROM bronze.warehouses
        WHERE TRIM(ISNULL(Warehouse_ID, '')) != ''
    )
    INSERT INTO silver.warehouses
    SELECT
        TRY_CAST(Warehouse_ID AS INT),
        TRIM(Warehouse_Name),
        TRIM(City),
        TRIM(State)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.warehouses);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.warehouses', @rows, 'SUCCESS');

    -- ===========================
    -- EMPLOYEES
    -- Transformations:
    --   Cast Employee_ID and Store_ID to INT
    --   Cast Hire_Date to DATE
    --   TRIM Name and Position
    --   Standardize Gender
    --   Deduplicate on Employee_ID
    --   Enrichment: JOIN bronze.stores to bring in Store_Name and Store_City
    -- ===========================
    TRUNCATE TABLE silver.employees;
    WITH cte AS (
        SELECT e.*,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(e.Employee_ID AS INT) ORDER BY e.Employee_ID) AS rn
        FROM bronze.employees e
        WHERE TRIM(ISNULL(e.Employee_ID, '')) != ''
    )
    INSERT INTO silver.employees
    SELECT
        TRY_CAST(c.Employee_ID AS INT),
        TRIM(c.Name),
        CASE
            WHEN UPPER(TRIM(c.Gender)) IN ('M', 'MALE')   THEN 'Male'
            WHEN UPPER(TRIM(c.Gender)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE TRIM(c.Gender)
        END,
        TRIM(c.Position),
        TRY_CAST(c.Store_ID AS INT),
        TRY_CAST(c.Hire_Date AS DATE)
    FROM cte c WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.employees);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.employees', @rows, 'SUCCESS');

    -- ===========================
    -- SUPPLIERS
    -- Transformations:
    --   Cast Supplier_ID to INT
    --   TRIM text columns
    --   Deduplicate on Supplier_ID
    -- ===========================
    TRUNCATE TABLE silver.suppliers;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Supplier_ID AS INT) ORDER BY Supplier_ID) AS rn
        FROM bronze.suppliers
        WHERE TRIM(ISNULL(Supplier_ID, '')) != ''
    )
    INSERT INTO silver.suppliers
    SELECT
        TRY_CAST(Supplier_ID AS INT),
        TRIM(Supplier_Name),
        TRIM(Country),
        TRIM(Phone)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.suppliers);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.suppliers', @rows, 'SUCCESS');

    -- ===========================
    -- PRODUCTS
    -- Transformations:
    --   Cast Product_ID, Brand_ID, Department_ID to INT
    --   TRIM text columns
    --   Replace NULL Package_Size with 'N/A'
    --   Deduplicate on Product_ID
    --   Enrichment: JOIN bronze.brands and bronze.departments to bring in
    --               Brand_Name and Department_Name as context columns
    -- NOTE: silver.products table must have Brand_Name and Department_Name
    --       columns added (see silver01_create_tables.sql)
    -- ===========================
    TRUNCATE TABLE silver.products;
    WITH cte AS (
        SELECT p.*,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(p.Product_ID AS INT) ORDER BY p.Product_ID) AS rn
        FROM bronze.products p
        WHERE TRIM(ISNULL(p.Product_ID, '')) != ''
    )
    INSERT INTO silver.products
    SELECT
        TRY_CAST(c.Product_ID AS INT),
        TRIM(c.SKU),
        TRIM(c.Product_Name),
        TRY_CAST(c.Brand_ID AS INT),
        TRIM(ISNULL(b.Brand_Name, 'Unknown'))       AS Brand_Name,
        TRY_CAST(c.Department_ID AS INT),
        TRIM(ISNULL(d.Department_Name, 'Unknown'))  AS Department_Name,
        TRIM(ISNULL(c.Package_Size, 'N/A'))
    FROM cte c
    LEFT JOIN bronze.brands      b ON TRIM(b.Brand_ID)      = TRIM(c.Brand_ID)
    LEFT JOIN bronze.departments d ON TRIM(d.Department_ID) = TRIM(c.Department_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.products);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.products', @rows, 'SUCCESS');

    -- ===========================
    -- PRODUCT_SUPPLIERS
    -- Transformations:
    --   Cast Product_ID and Supplier_ID to INT
    --   Cast Supply_Price to DECIMAL
    --   Deduplicate on Product_ID + Supplier_ID combination
    --   Enrichment: JOIN bronze.suppliers to bring in Supplier_Name and Country
    -- NOTE: silver.product_suppliers must have Supplier_Name and Country columns
    -- ===========================
    TRUNCATE TABLE silver.product_suppliers;
    WITH cte AS (
        SELECT ps.*,
            ROW_NUMBER() OVER (
                PARTITION BY TRY_CAST(ps.Product_ID AS INT), TRY_CAST(ps.Supplier_ID AS INT)
                ORDER BY ps.Product_ID
            ) AS rn
        FROM bronze.product_suppliers ps
        WHERE TRIM(ISNULL(ps.Product_ID, '')) != ''
    )
    INSERT INTO silver.product_suppliers
    SELECT
        TRY_CAST(c.Product_ID AS INT),
        TRY_CAST(c.Supplier_ID AS INT),
        TRIM(ISNULL(s.Supplier_Name, 'Unknown'))    AS Supplier_Name,
        TRIM(ISNULL(s.Country, 'Unknown'))          AS Country,
        TRY_CAST(c.Supply_Price AS DECIMAL(10,2))
    FROM cte c
    LEFT JOIN bronze.suppliers s ON TRIM(s.Supplier_ID) = TRIM(c.Supplier_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.product_suppliers);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.product_suppliers', @rows, 'SUCCESS');

    -- ===========================
    -- PROMOTIONS
    -- Transformations:
    --   Cast Promotion_ID to INT
    --   Cast Discount_Percent to DECIMAL
    --   Cast Start_Date and End_Date to DATE
    --   TRIM Promo_Type
    --   Derive Duration_Days = End_Date minus Start_Date
    --   Deduplicate on Promotion_ID
    -- ===========================
    TRUNCATE TABLE silver.promotions;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Promotion_ID AS INT) ORDER BY Promotion_ID) AS rn
        FROM bronze.promotions
        WHERE TRIM(ISNULL(Promotion_ID, '')) != ''
    )
    INSERT INTO silver.promotions
    SELECT
        TRY_CAST(Promotion_ID AS INT),
        TRIM(Promo_Type),
        TRY_CAST(Discount_Percent AS DECIMAL(5,2)),
        TRY_CAST(Start_Date AS DATE),
        TRY_CAST(End_Date AS DATE),
        DATEDIFF(DAY,
            TRY_CAST(Start_Date AS DATE),
            TRY_CAST(End_Date AS DATE))             AS Duration_Days
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.promotions);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.promotions', @rows, 'SUCCESS');

    -- ===========================
    -- REGISTERS
    -- Transformations:
    --   Cast all columns to INT
    --   Deduplicate on Register_ID
    -- ===========================
    TRUNCATE TABLE silver.registers;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Register_ID AS INT) ORDER BY Register_ID) AS rn
        FROM bronze.registers
        WHERE TRIM(ISNULL(Register_ID, '')) != ''
    )
    INSERT INTO silver.registers
    SELECT
        TRY_CAST(Register_ID AS INT),
        TRY_CAST(Store_ID AS INT),
        TRY_CAST(Register_Number AS INT)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.registers);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.registers', @rows, 'SUCCESS');

    -- ===========================
    -- DELIVERY_PROVIDERS
    -- Transformations:
    --   Cast Provider_ID to INT
    --   TRIM text columns
    --   Deduplicate on Provider_ID
    -- ===========================
    TRUNCATE TABLE silver.delivery_providers;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Provider_ID AS INT) ORDER BY Provider_ID) AS rn
        FROM bronze.delivery_providers
        WHERE TRIM(ISNULL(Provider_ID, '')) != ''
    )
    INSERT INTO silver.delivery_providers
    SELECT
        TRY_CAST(Provider_ID AS INT),
        TRIM(Provider_Name),
        TRIM(Phone)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.delivery_providers);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.delivery_providers', @rows, 'SUCCESS');

    -- ===========================
    -- ONLINE_ORDERS
    -- Transformations:
    --   Cast all IDs to INT
    --   Cast Order_Time to DATETIME
    --   Cast Order_Total to DECIMAL
    --   Standardize Order_Status casing
    --   Deduplicate on Order_ID
    --   Enrichment: JOIN bronze.customers to bring in Full_Name
    --               JOIN bronze.warehouses to bring in Warehouse_Name
    -- NOTE: silver.online_orders must have Customer_Name and Warehouse_Name columns
    -- ===========================
    TRUNCATE TABLE silver.online_orders;
    WITH cte AS (
        SELECT o.*,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(o.Order_ID AS INT) ORDER BY o.Order_ID) AS rn
        FROM bronze.online_orders o
        WHERE TRIM(ISNULL(o.Order_ID, '')) != ''
    )
    INSERT INTO silver.online_orders
    SELECT
        TRY_CAST(c.Order_ID AS INT),
        TRY_CAST(c.Customer_ID AS INT),
        TRIM(cu.First_Name) + ' ' + TRIM(cu.Last_Name) AS Customer_Name,
        TRY_CAST(c.Warehouse_ID AS INT),
        TRIM(ISNULL(w.Warehouse_Name, 'Unknown'))       AS Warehouse_Name,
        TRY_CAST(c.Order_Time AS DATETIME),
        CASE
            WHEN UPPER(TRIM(c.Order_Status)) = 'DELIVERED'  THEN 'Delivered'
            WHEN UPPER(TRIM(c.Order_Status)) = 'CANCELLED'  THEN 'Cancelled'
            WHEN UPPER(TRIM(c.Order_Status)) = 'PROCESSING' THEN 'Processing'
            WHEN UPPER(TRIM(c.Order_Status)) = 'SHIPPED'    THEN 'Shipped'
            ELSE TRIM(c.Order_Status)
        END,
        TRY_CAST(c.Order_Total AS DECIMAL(10,2))
    FROM cte c
    LEFT JOIN bronze.customers  cu ON TRIM(cu.Customer_ID)  = TRIM(c.Customer_ID)
    LEFT JOIN bronze.warehouses w  ON TRIM(w.Warehouse_ID)  = TRIM(c.Warehouse_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.online_orders);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.online_orders', @rows, 'SUCCESS');

    -- ===========================
    -- ONLINE_ORDER_ITEMS
    -- Transformations:
    --   Cast all IDs, Quantity, Unit_Price to proper types
    --   Derive Total_Line_Amount = Quantity * Unit_Price
    --   Deduplicate on Order_Item_ID
    --   Enrichment: JOIN bronze.products to bring in Product_Name
    --               JOIN bronze.promotions to bring in Discount_Percent
    -- NOTE: silver.online_order_items must have Product_Name and Discount_Percent columns
    -- ===========================
    TRUNCATE TABLE silver.online_order_items;
    WITH cte AS (
        SELECT
            oi.Order_Item_ID,
            oi.Order_ID,
            oi.Product_ID,
            oi.Promotion_ID,
            oi.Quantity,
            oi.Unit_Price,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(oi.Order_Item_ID AS INT) ORDER BY oi.Order_Item_ID) AS rn
        FROM bronze.online_order_items oi
        WHERE TRIM(ISNULL(oi.Order_Item_ID, '')) != ''
    )
    INSERT INTO silver.online_order_items
    SELECT
        TRY_CAST(c.Order_Item_ID AS INT),
        TRY_CAST(c.Order_ID AS INT),
        TRY_CAST(c.Product_ID AS INT),
        TRIM(ISNULL(p.Product_Name, 'Unknown'))                     AS Product_Name,
        TRY_CAST(c.Promotion_ID AS INT),
        TRY_CAST(ISNULL(pr.Discount_Percent, '0') AS DECIMAL(5,2)) AS Discount_Percent,
        TRY_CAST(c.Quantity AS INT),
        TRY_CAST(c.Unit_Price AS DECIMAL(10,2)),
        TRY_CAST(c.Quantity AS INT) * TRY_CAST(c.Unit_Price AS DECIMAL(10,2))  AS Total_Line_Amount
    FROM cte c
    LEFT JOIN bronze.products   p  ON TRIM(p.Product_ID)   = TRIM(c.Product_ID)
    LEFT JOIN bronze.promotions pr ON TRIM(pr.Promotion_ID) = TRIM(c.Promotion_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.online_order_items);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.online_order_items', @rows, 'SUCCESS');

    -- ===========================
    -- PAYMENTS
    -- Transformations:
    --   Cast Payment_ID and Order_ID to INT
    --   Cast Payment_Amount to DECIMAL
    --   Cast Payment_Time to DATETIME
    --   TRIM Payment_Method
    --   Deduplicate on Payment_ID
    -- ===========================
    TRUNCATE TABLE silver.payments;
    WITH cte AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(Payment_ID AS INT) ORDER BY Payment_ID) AS rn
        FROM bronze.payments
        WHERE TRIM(ISNULL(Payment_ID, '')) != ''
    )
    INSERT INTO silver.payments
    SELECT
        TRY_CAST(Payment_ID AS INT),
        TRY_CAST(Order_ID AS INT),
        TRIM(Payment_Method),
        TRY_CAST(Payment_Amount AS DECIMAL(10,2)),
        TRY_CAST(Payment_Time AS DATETIME)
    FROM cte WHERE rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.payments);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.payments', @rows, 'SUCCESS');

    -- ===========================
    -- DELIVERIES
    -- Transformations:
    --   Cast all IDs to INT
    --   Cast Ship_Date and Delivery_Date to DATETIME
    --   TRIM Delivery_Status
    --   Derive Delivery_Days = days between Ship_Date and Delivery_Date
    --   Deduplicate on Delivery_ID
    --   Enrichment: JOIN bronze.delivery_providers to bring in Provider_Name
    -- NOTE: silver.deliveries must have Provider_Name column
    -- ===========================
    TRUNCATE TABLE silver.deliveries;
    WITH cte AS (
        SELECT d.*,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(d.Delivery_ID AS INT) ORDER BY d.Delivery_ID) AS rn
        FROM bronze.deliveries d
        WHERE TRIM(ISNULL(d.Delivery_ID, '')) != ''
    )
    INSERT INTO silver.deliveries
    SELECT
        TRY_CAST(c.Delivery_ID AS INT),
        TRY_CAST(c.Order_ID AS INT),
        TRY_CAST(c.Provider_ID AS INT),
        TRIM(ISNULL(dp.Provider_Name, 'Unknown'))   AS Provider_Name,
        TRY_CAST(c.Ship_Date AS DATETIME),
        TRY_CAST(c.Delivery_Date AS DATETIME),
        TRIM(c.Delivery_Status),
        DATEDIFF(DAY,
            TRY_CAST(c.Ship_Date AS DATETIME),
            TRY_CAST(c.Delivery_Date AS DATETIME))  AS Delivery_Days
    FROM cte c
    LEFT JOIN bronze.delivery_providers dp ON TRIM(dp.Provider_ID) = TRIM(c.Provider_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.deliveries);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.deliveries', @rows, 'SUCCESS');

    -- ===========================
    -- POS_TRANSACTIONS
    -- Transformations:
    --   Keep Transaction_ID as NVARCHAR (format: TXN-20250406-000001)
    --   Cast Store_ID, Register_ID, Employee_ID, Customer_ID to INT
    --   Cast Transaction_Time to DATETIME
    --   Deduplicate on Transaction_ID
    --   Enrichment: JOIN bronze.stores to bring in Store_Name
    --               JOIN bronze.employees to bring in Employee Name
    -- NOTE: silver.pos_transactions must have Store_Name and Employee_Name columns
    -- ===========================
    TRUNCATE TABLE silver.pos_transactions;
    WITH cte AS (
        SELECT t.*,
            ROW_NUMBER() OVER (PARTITION BY TRIM(t.Transaction_ID) ORDER BY t.Transaction_ID) AS rn
        FROM bronze.pos_transactions t
        WHERE TRIM(ISNULL(t.Transaction_ID, '')) != ''
    )
    INSERT INTO silver.pos_transactions
    SELECT
        TRIM(c.Transaction_ID),
        TRY_CAST(c.Store_ID AS INT),
        TRIM(ISNULL(s.Store_Name, 'Unknown'))       AS Store_Name,
        TRY_CAST(c.Register_ID AS INT),
        TRY_CAST(c.Employee_ID AS INT),
        TRIM(ISNULL(e.Name, 'Unknown'))             AS Employee_Name,
        TRY_CAST(c.Customer_ID AS INT),
        TRY_CAST(c.Transaction_Time AS DATETIME)
    FROM cte c
    LEFT JOIN bronze.stores    s ON TRIM(s.Store_ID)    = TRIM(c.Store_ID)
    LEFT JOIN bronze.employees e ON TRIM(e.Employee_ID) = TRIM(c.Employee_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.pos_transactions);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.pos_transactions', @rows, 'SUCCESS');

    -- ===========================
    -- TRANSACTION_ITEMS
    -- Transformations:
    --   Cast Line_ID, Product_ID, Promotion_ID, Quantity to INT
    --   Keep Transaction_ID as NVARCHAR to match POS_TRANSACTIONS
    --   Cast Unit_Price to DECIMAL
    --   Derive Total_Line_Amount = Quantity * Unit_Price
    --   Deduplicate on Line_ID
    --   Enrichment: JOIN bronze.products to bring in Product_Name
    --               JOIN bronze.promotions to bring in Discount_Percent
    -- NOTE: silver.transaction_items must have Product_Name and Discount_Percent columns
    -- ===========================
    TRUNCATE TABLE silver.transaction_items;
    WITH cte AS (
        SELECT
            ti.Line_ID,
            ti.Transaction_ID,
            ti.Product_ID,
            ti.Promotion_ID,
            ti.Quantity,
            ti.Unit_Price,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(ti.Line_ID AS INT) ORDER BY ti.Line_ID) AS rn
        FROM bronze.transaction_items ti
        WHERE TRIM(ISNULL(ti.Line_ID, '')) != ''
    )
    INSERT INTO silver.transaction_items
    SELECT
        TRY_CAST(c.Line_ID AS INT),
        TRIM(c.Transaction_ID),
        TRY_CAST(c.Product_ID AS INT),
        TRIM(ISNULL(p.Product_Name, 'Unknown'))                     AS Product_Name,
        TRY_CAST(c.Promotion_ID AS INT),
        TRY_CAST(ISNULL(pr.Discount_Percent, '0') AS DECIMAL(5,2)) AS Discount_Percent,
        TRY_CAST(c.Quantity AS INT),
        TRY_CAST(c.Unit_Price AS DECIMAL(10,2)),
        TRY_CAST(c.Quantity AS INT) * TRY_CAST(c.Unit_Price AS DECIMAL(10,2)) AS Total_Line_Amount
    FROM cte c
    LEFT JOIN bronze.products   p  ON TRIM(p.Product_ID)   = TRIM(c.Product_ID)
    LEFT JOIN bronze.promotions pr ON TRIM(pr.Promotion_ID) = TRIM(c.Promotion_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.transaction_items);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.transaction_items', @rows, 'SUCCESS');

    -- ===========================
    -- INVENTORY
    -- Transformations:
    --   Cast all IDs and Stock_Level to INT
    --   Cast Last_Updated to DATETIME
    --   Deduplicate on Inventory_ID
    --   Enrichment: JOIN bronze.products to bring in Product_Name
    --               JOIN bronze.stores to bring in Store_Name
    -- NOTE: silver.inventory must have Product_Name and Store_Name columns
    -- ===========================
    TRUNCATE TABLE silver.inventory;
    WITH cte AS (
        SELECT i.*,
            ROW_NUMBER() OVER (PARTITION BY TRY_CAST(i.Inventory_ID AS INT) ORDER BY i.Inventory_ID) AS rn
        FROM bronze.inventory i
        WHERE TRIM(ISNULL(i.Inventory_ID, '')) != ''
    )
    INSERT INTO silver.inventory
    SELECT
        TRY_CAST(c.Inventory_ID AS INT),
        TRY_CAST(c.Store_ID AS INT),
        TRIM(ISNULL(s.Store_Name, 'Unknown'))       AS Store_Name,
        TRY_CAST(c.Product_ID AS INT),
        TRIM(ISNULL(p.Product_Name, 'Unknown'))     AS Product_Name,
        TRY_CAST(c.Stock_Level AS INT),
        TRY_CAST(c.Last_Updated AS DATETIME)
    FROM cte c
    LEFT JOIN bronze.stores   s ON TRIM(s.Store_ID)   = TRIM(c.Store_ID)
    LEFT JOIN bronze.products p ON TRIM(p.Product_ID) = TRIM(c.Product_ID)
    WHERE c.rn = 1;
    SET @rows = (SELECT COUNT(*) FROM silver.inventory);
    INSERT INTO silver.load_log (table_name, rows_loaded, status)
    VALUES ('silver.inventory', @rows, 'SUCCESS');

    PRINT 'Silver load complete.';
END;
GO

-- ===========================
-- RUN AND VALIDATE
-- ===========================
EXEC silver.load_silver;

SELECT table_name, rows_loaded, load_time, status
FROM silver.load_log
ORDER BY load_time DESC;

-- Quality spot checks
SELECT * FROM silver.online_order_items WHERE Total_Line_Amount IS NULL;
SELECT * FROM silver.transaction_items   WHERE Total_Line_Amount IS NULL;
SELECT * FROM silver.deliveries          WHERE Delivery_Days < 0;
SELECT * FROM silver.promotions          WHERE Duration_Days < 0;
SELECT * FROM silver.customers           WHERE Full_Name IS NULL;
SELECT * FROM silver.inventory           WHERE Stock_Level < 0;
SELECT Gender, COUNT(*) AS Count FROM silver.employees GROUP BY Gender;
