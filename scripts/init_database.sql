/*
===============================================================
Create Database and Schemas
===============================================================
Script Purpose:
This script creates a new database names 'Data Warehouse' after checking if it already exists.
The scrip also sets up three layesr: bronze, silver and gold.

*/

-- Create the `datawarehouse` database
CREATE DATABASE IF NOT EXISTS datawarehouse;

-- Create layers according to `medalion` approach
-- Bronze Layer
CREATE SCHEMA IF NOT EXISTS bronze;

-- Sliver layer
CREATE SCHEMA IF NOT EXISTS silver;

-- Gold layer
CREATE SCHEMA IF NOT EXISTS gold;