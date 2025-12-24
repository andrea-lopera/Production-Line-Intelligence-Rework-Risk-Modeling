-- Drop any databases with the same name to avoid conflicts
DROP DATABASE production_line;

-- Create a new database
CREATE DATABASE production_line;

-- Make sure you are connected to the right database
SELECT current_database();

-- Create the structure for the table for production logs
CREATE TABLE production_logs (
    prod_timestamp TIMESTAMP NOT NULL,
    unit_id VARCHAR(100) NOT NULL,
	shift VARCHAR(20) NOT NULL,
    machine_id VARCHAR(100) NOT NULL,
    product_type VARCHAR(100) NOT NULL,
    product_category VARCHAR(100) NOT NULL,
    cutting_time NUMERIC(5, 2) NOT NULL,
    tempering_time NUMERIC(5, 2) NOT NULL,
    framing_time NUMERIC(5, 2) NOT NULL,
    PRIMARY KEY (unit_id)
);

-- Create a staging JSON table
CREATE TABLE production_logs_raw(
	payload jsonb
);

-- Copy JSON as text into the staging table
-- Run the following scrip on PSQL Tool Workspace without \n. Again make sure that PSQL Tool Workspace is connected to the correct database.
-- \copy production_logs_raw(payload) FROM '/Users/AndreaLopera//Users/AndreaLopera/Documents/GitHub/Production-Line-Intelligence-Rework-Risk-Modeling/data/Production_Logs.json' WITH (FORMAT text);

-- Insert into the table 
INSERT INTO production_logs (
	prod_timestamp,
	unit_id,
	shift,
	machine_id,
	product_type,
	product_category,
	cutting_time,
	tempering_time,
	framing_time
)
SELECT 
	(payload->>'timestamp')::timestamp,
	(payload->>'unit_id')::varchar(100),
	(payload->>'shift')::varchar(20),
	(payload->>'machine_id')::varchar(100),
	(payload->>'product_type')::varchar(100),
	(payload->>'product_category')::varchar(100),
	(payload->>'cutting_time')::numeric(5,2),
	(payload->>'tempering_time')::numeric(5,2),
	(payload->>'framing_time')::numeric(5,2)
FROM production_logs_raw;

-- Create the structure for the table for quality audit
CREATE TABLE quality_audit (
	unit_id VARCHAR(100) NOT NULL,
	qc_result VARCHAR(100) NOT NULL,
	rework_flag INT NOT NULL,
	downtime_minutes INT NOT NULL,
	rework_reason VARCHAR(100),
	PRIMARY KEY (unit_id),
	FOREIGN KEY (unit_id) REFERENCES production_logs(unit_id)
);

-- Import the data from the CSV file
-- -- Run the following scrip on PSQL Tool Workspace without \n. Again make sure that PSQL Tool Workspace is connected to the correct database.
-- \copy quality_audit FROM '/Users/AndreaLopera//Users/AndreaLopera/Documents/GitHub/Production-Line-Intelligence-Rework-Risk-Modeling/data/Quality_Audit.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

-- Create a view 
-- Perform a JOIN to connect both tables using the primary and foreign key
CREATE VIEW production_with_qc AS
SELECT 
	p.prod_timestamp, 
	p.unit_id,
	p.shift, 
	p.machine_id, 
	p.product_type,
    p.product_category, 
	p.cutting_time, 
	p.tempering_time, 
	p.framing_time, 
	q.qc_result, 
	q.rework_flag, 
	q.downtime_minutes, 
	q.rework_reason
FROM production_logs AS p
JOIN quality_audit AS q
ON q.unit_id = p.unit_id;

--Use view to check the results
SELECT *
FROM production_with_qc;

-- Use a window function to compute a derived column "cumulative downtime per machine over time"
CREATE VIEW production_features AS
SELECT *,
SUM(downtime_minutes) 
OVER (PARTITION BY machine_id ORDER BY prod_timestamp) AS cumulative_downtime
FROM production_with_qc;

SELECT * 
FROM production_features;

-- Inspect before export to CSV
SELECT COUNT(*) AS total_rows FROM production_features;

-- Export production features to a CSV file
-- -- Run the following scrip on PSQL Tool Workspace. Again make sure that PSQL Tool Workspace is connected to the correct database.
-- \copy (SELECT * FROM production_features) TO '/Users/AndreaLopera/Desktop/Data Science Portfolio/Production-Line-Intelligence-Dashboard-main/data/production_features.csv' WITH (FORMAT CSV, HEADER true);



 






