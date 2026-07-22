CREATE STORAGE INTEGRATION s3_weather_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::527487952606:role/snowflake-s3-access-role'
STORAGE_ALLOWED_LOCATIONS = ('s3://weatherr-data-buckett/');
DESC INTEGRATION s3_weather_int;


 --Create Database and Schema
 CREATE DATABASE IF NOT EXISTS weather_db;
USE DATABASE weather_db;
CREATE SCHEMA IF NOT EXISTS weather_schema;
USE SCHEMA weather_schema;

--JSON File Format
CREATE FILE FORMAT IF NOT EXISTS json_format
TYPE = 'JSON';

---- External Stage Setup or  S3 Stage Create
CREATE STAGE IF NOT EXISTS weather_stage
URL = 's3://weatherr-data-buckett/'
STORAGE_INTEGRATION = s3_weather_int
FILE_FORMAT = json_format;

LIST @weather_stage;  --stage working anno check cheyan

--  to create Weather Data Table
CREATE TABLE IF NOT EXISTS weather_data (
    raw_data VARIANT
);
----
-- Snowpipe Auto Ingest Setup
CREATE PIPE IF NOT EXISTS weather_pipe
AUTO_INGEST = TRUE
AS
COPY INTO weather_data
FROM @weather_stage
FILE_FORMAT = (FORMAT_NAME = json_format);
--
SHOW PIPES;

-- Snowflake-il Table Check Cheyyan:
SELECT * FROM weather_data LIMIT 10;
-- Pipe Status Check Cheyyn:
SELECT SYSTEM$PIPE_STATUS('weather_pipe');

-- Continuous Data Varunnundo Ennu Verify Cheyyn
SELECT COUNT(*) FROM weather_data;

----Data Better Aayi Kaanan;
SELECT 
    raw_data:city::STRING AS city,
    raw_data:temperature::FLOAT AS temperature,
    raw_data:humidity::FLOAT AS humidity,
    raw_data:time::STRING AS time
FROM weather_data
ORDER BY time DESC
LIMIT 10;

-- Monitoring Setup Cheyyn:
SELECT SYSTEM$PIPE_STATUS('weather_pipe');