/*
===============================================================
Insert Data to `Bronze` layer
===============================================================
Script Purpose:
This scripts insert data from CSV files to the Database (Postgres). We are doing full load of the data.
There are to types of commands:
- For local PostgreSQL
- For Docker Container

WARNING:
This scripts will TRUNCATE all of the data in the tables before INSERT

*/

-- For local Database, table crm_cust_info
truncate table bronze.crm_cust_info;

COPY bronze.crm_cust_info
FROM '/path_to_your_project/datasets/source_crm/cust_info.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

-- For Docker Contaner Database
psql - h database_ip - p 5432 - U user - d your_database

truncate table bronze.crm_cust_info;

\copy bronze.crm_cust_info
FROM '/path_to_the project/datasets/source_crm/cust_info.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

-- For local Database, table crm_prd_info
truncate table bronze.crm_prd_info;

COPY bronze.crm_cust_info
FROM '/path_to_your_project/datasets/source_crm/prd_info.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

-- For Docker Contaner Database
psql - h database_ip - p 5432 - U user - d your_database

truncate table bronze.crm_prd_info;

\copy bronze.crm_prd_info
FROM '/path_to_your_project/datasets/source_crm/prd_info.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

-- For local Database, table crm_sales_details
truncate table bronze.crm_sales_details;

COPY bronze.crm_sales_details
FROM '/path_to_your_project/datasets/source_crm/sales_details.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

-- For Docker Container Database

psql - h database_ip - p 5432 - U user - d your_database

truncate table bronze.crm_sales_details;

\copy bronze.crm_sales_details
FROM '/path_to_your_project/datasets/source_crm/sales_details.csv'
WITH (
FORMAT csv,
HEADER true,
DELIMITER ','
);

-- For local Database, table erp_cust_az12
truncate table bronze.erp_cust_az12;

COPY bronze.erp_cust_az12
FROM '/path_to_your_project/datasets/source_crm/cust_az12.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

-- For Docker Container Database

psql - h database_ip - p 5432 - U user - d your_database

truncate table bronze.erp_cust_az12;

\copy bronze.erp_cust_az12
FROM '/path_to_your_project/datasets/source_erp/cust_az12.csv'
WITH (
FORMAT csv,
HEADER true,
DELIMITER ','
);

-- For local Database, table erp_loc_a101
truncate table bronze.erp_loc_a101;

COPY bronze.erp_loc_a101
FROM '/path_to_your_project/datasets/source_crm/loc_a101.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

-- For Docker Container Database
psql - h database_ip - p 5432 - U user - d your_database

truncate table bronze.erp_loc_a101;

\copy bronze.erp_loc_a101
FROM '/path_to_your_project/datasets/source_erp/loc_a101.csv'
WITH (
FORMAT csv,
HEADER true,
DELIMITER ','
);

-- For local Database, table erp_px_cat_g1v2
truncate table bronze.erp_px_cat_g1v2;

COPY bronze.erp_px_cat_g1v2
FROM '/path_to_your_project/datasets/source_crm/px_cat_g1v2.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ','
    );

-- For Docker Container Database
psql - h database_ip - p 5432 - U user - d your_database

truncate table bronze.erp_px_cat_g1v2;

\copy bronze.erp_px_cat_g1v2
FROM '/path_to_your_project/datasets/source_erp/px_cat_g1v2.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

/* In case you work on your local computer, you can create a procedure

==================================================================

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
BEGIN
BEGIN TRY
PRINT '=========================================================';
PRINT 'Loading Bronze Layer';
PRINT '=========================================================';

PRINT '---------------------------------------------------------';
PRINT 'Loading CRM Section';
PRINT '---------------------------------------------------------';
TRUNCATE TABLE bronze.crm_cust_info;

COPY bronze.crm_cust_info 
FROM '/data/source_crm/cust_info.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

TRUNCATE TABLE bronze.crm_prd_info;

COPY bronze.crm_prd_info 
FROM '/data/source_crm/prd_info.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

TRUNCATE table bronze.crm_sales_details;

COPY bronze.crm_sales_details
FROM '/path_to_your_project/datasets/source_crm/sales_details.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

PRINT '---------------------------------------------------------';
PRINT 'Loading ERP Section';
PRINT '---------------------------------------------------------';

TRUNCATE table bronze.erp_cust_az12;

COPY bronze.erp_cust_az12
FROM '/path_to_your_project/datasets/source_crm/cust_az12.csv'
WITH (FORMAT csv,HEADER true,DELIMITER ',');

truncate table bronze.erp_loc_a101;

COPY bronze.erp_loc_a101
FROM '/path_to_your_project/datasets/source_crm/loc_a101.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY bronze.erp_px_cat_g1v2
FROM '/path_to_your_project/datasets/source_crm/px_cat_g1v2.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');
PRINT '=========================================================';
PRINT 'Loading Complete';
PRINT '=========================================================';
END TRY
BEGIN CATCH
PRINT '=========================================================';
PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
PRINT 'Error Message' || ERROR_MESSAGE();
PRINT 'Error Message' || CAST(ERROR_NUMBER() AS VARCHAR);
PRINT '=========================================================';
END CATCH
END;
$$;

EXEC bronze.load_bronze();

For Docker developmnet it's better to develop an ETL process where data will be copied to the container or available there

*/