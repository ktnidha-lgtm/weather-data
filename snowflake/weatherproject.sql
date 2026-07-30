CREATE STORAGE INTEGRATION s3_weather_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN ='arn:aws:iam::527487952606:role/new-snowflake-s3-access-rolee'
STORAGE_ALLOWED_LOCATIONS = ('s3://new-weatherdata-bucket/weather-data/');
DESC INTEGRATION s3_weather_int;


 --Create Database and Schema
 CREATE DATABASE weather_db;
CREATE SCHEMA weather_db.weather_schema;
USE SCHEMA weather_db.weather_schema;

CREATE FILE FORMAT json_format
  TYPE = 'JSON';

CREATE STAGE weather_stage
  URL = 's3://new-weatherdata-bucket/weather-data/'
  STORAGE_INTEGRATION = s3_weather_int
  FILE_FORMAT = json_format;

CREATE TABLE weather_data (
  raw VARIANT
);
LIST @weather_stage;  --stage working anno check cheyan


-- Snowpipe Auto Ingest Setup
CREATE PIPE IF NOT EXISTS weather_pipe
AUTO_INGEST = TRUE
AS
COPY INTO weather_data
FROM @weather_stage
FILE_FORMAT = (FORMAT_NAME = json_format);
--
SHOW PIPES;


-- Continuous Data Varunnundo nokn:
SELECT COUNT(*) FROM weather_data;

-- Ellam Cities Kaananulla Query
SELECT DISTINCT raw:city::STRING AS city
FROM weather_data;

-- Readable format-il Data Kaanan (Presentation-inu ettavum nallath)
SELECT
  raw:city::STRING AS city,
  raw:temperature::FLOAT AS temperature,
  raw:humidity::FLOAT AS humidity,
  raw:weather::STRING AS weather,
  TO_TIMESTAMP(raw:timestamp::NUMBER) AS reading_time
FROM weather_data
ORDER BY reading_time DESC
LIMIT 10;

-- Pipe Status Check Cheyyn (auto-ingest work cheyyunnundo ennu)
SELECT SYSTEM$PIPE_STATUS('weather_pipe');












