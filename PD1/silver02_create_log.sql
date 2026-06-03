USE DataWarehouse;
GO

CREATE TABLE silver.load_log (
    log_id      INT IDENTITY(1,1) PRIMARY KEY,
    table_name  NVARCHAR(100),
    rows_loaded INT,
    load_time   DATETIME DEFAULT GETDATE(),
    status      NVARCHAR(20),
    notes       NVARCHAR(500)
);
GO