USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @rows INT;

    -- BRANDS
    TRUNCATE TABLE bronze.brands;
    BULK INSERT bronze.brands
    FROM 'C:\Dataset1\BRANDS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.brands);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.brands', @rows, GETDATE(), 'SUCCESS', NULL);

    -- CUSTOMERS
    TRUNCATE TABLE bronze.customers;
    BULK INSERT bronze.customers
    FROM 'C:\Dataset1\CUSTOMERS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.customers);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.customers', @rows, GETDATE(), 'SUCCESS', NULL);

    -- DEPARTMENTS
    TRUNCATE TABLE bronze.departments;
    BULK INSERT bronze.departments
    FROM 'C:\Dataset1\DEPARTMENTS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.departments);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.departments', @rows, GETDATE(), 'SUCCESS', NULL);

    -- STORES
    TRUNCATE TABLE bronze.stores;
    BULK INSERT bronze.stores
    FROM 'C:\Dataset1\STORES.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.stores);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.stores', @rows, GETDATE(), 'SUCCESS', NULL);

    -- WAREHOUSES
    TRUNCATE TABLE bronze.warehouses;
    BULK INSERT bronze.warehouses
    FROM 'C:\Dataset1\WAREHOUSES.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.warehouses);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.warehouses', @rows, GETDATE(), 'SUCCESS', NULL);

    -- EMPLOYEES
    TRUNCATE TABLE bronze.employees;
    BULK INSERT bronze.employees
    FROM 'C:\Dataset1\EMPLOYEES.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.employees);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.employees', @rows, GETDATE(), 'SUCCESS', NULL);

    -- SUPPLIERS
    TRUNCATE TABLE bronze.suppliers;
    BULK INSERT bronze.suppliers
    FROM 'C:\Dataset1\SUPPLIERS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.suppliers);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.suppliers', @rows, GETDATE(), 'SUCCESS', NULL);

    -- PRODUCTS
    TRUNCATE TABLE bronze.products;
    BULK INSERT bronze.products
    FROM 'C:\Dataset1\PRODUCTS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.products);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.products', @rows, GETDATE(), 'SUCCESS', NULL);

    -- PRODUCT_SUPPLIERS
    TRUNCATE TABLE bronze.product_suppliers;
    BULK INSERT bronze.product_suppliers
    FROM 'C:\Dataset1\PRODUCT_SUPPLIERS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.product_suppliers);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.product_suppliers', @rows, GETDATE(), 'SUCCESS', NULL);

    -- PROMOTIONS
    TRUNCATE TABLE bronze.promotions;
    BULK INSERT bronze.promotions
    FROM 'C:\Dataset1\PROMOTIONS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.promotions);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.promotions', @rows, GETDATE(), 'SUCCESS', NULL);

    -- REGISTERS
    TRUNCATE TABLE bronze.registers;
    BULK INSERT bronze.registers
    FROM 'C:\Dataset1\REGISTERS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.registers);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.registers', @rows, GETDATE(), 'SUCCESS', NULL);

    -- DELIVERY_PROVIDERS
    TRUNCATE TABLE bronze.delivery_providers;
    BULK INSERT bronze.delivery_providers
    FROM 'C:\Dataset1\DELIVERY_PROVIDERS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.delivery_providers);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.delivery_providers', @rows, GETDATE(), 'SUCCESS', NULL);

    -- DELIVERIES
    TRUNCATE TABLE bronze.deliveries;
    BULK INSERT bronze.deliveries
    FROM 'C:\Dataset1\DELIVERIES.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.deliveries);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.deliveries', @rows, GETDATE(), 'SUCCESS', NULL);

    -- INVENTORY
    TRUNCATE TABLE bronze.inventory;
    BULK INSERT bronze.inventory
    FROM 'C:\Dataset1\INVENTORY.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.inventory);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.inventory', @rows, GETDATE(), 'SUCCESS', NULL);

    -- ONLINE_ORDERS
    TRUNCATE TABLE bronze.online_orders;
    BULK INSERT bronze.online_orders
    FROM 'C:\Dataset1\ONLINE_ORDERS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.online_orders);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.online_orders', @rows, GETDATE(), 'SUCCESS', NULL);

    -- ONLINE_ORDER_ITEMS
    TRUNCATE TABLE bronze.online_order_items;
    BULK INSERT bronze.online_order_items
    FROM 'C:\Dataset1\ONLINE_ORDER_ITEMS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.online_order_items);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.online_order_items', @rows, GETDATE(), 'SUCCESS', NULL);

    -- PAYMENTS
    TRUNCATE TABLE bronze.payments;
    BULK INSERT bronze.payments
    FROM 'C:\Dataset1\PAYMENTS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.payments);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.payments', @rows, GETDATE(), 'SUCCESS', NULL);

    -- POS_TRANSACTIONS
    TRUNCATE TABLE bronze.pos_transactions;
    BULK INSERT bronze.pos_transactions
    FROM 'C:\Dataset1\POS_TRANSACTIONS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.pos_transactions);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.pos_transactions', @rows, GETDATE(), 'SUCCESS', NULL);

    -- TRANSACTION_ITEMS
    TRUNCATE TABLE bronze.transaction_items;
    BULK INSERT bronze.transaction_items
    FROM 'C:\Dataset1\TRANSACTION_ITEMS.csv'
    WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
    SET @rows = (SELECT COUNT(*) FROM bronze.transaction_items);
    INSERT INTO bronze.load_log (table_name, rows_loaded, load_time, status, notes)
    VALUES ('bronze.transaction_items', @rows, GETDATE(), 'SUCCESS', NULL);

    PRINT 'Bronze load complete.';
END;
GO

EXEC bronze.load_bronze;
GO
SELECT table_name, rows_loaded, load_time, status
FROM bronze.load_log
ORDER BY load_time DESC;