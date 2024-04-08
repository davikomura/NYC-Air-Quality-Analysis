-- Create Table
CREATE TABLE air_quality_data (
    unique_id TEXT,
    indicator_id INT,
    name TEXT,
    measure TEXT,
    measure_info TEXT,
    geo_type_name TEXT,
    geo_join_id TEXT,
    geo_place_name TEXT,
    time_period TEXT,
    start_date DATE,
    data_value NUMERIC,
    message TEXT
);

-- Import Data
COPY air_quality_data FROM 'path/to/Air_Quality.csv' DELIMITER ',' CSV HEADER;

-- Advanced SQL Queries
-- Example 1: Calculate the average data values per indicator and year
SELECT indicator_id, EXTRACT(YEAR FROM start_date) AS year, AVG(data_value) AS avg_data_value
FROM air_quality_data
GROUP BY indicator_id, EXTRACT(YEAR FROM start_date)
ORDER BY indicator_id, year;

-- Example 2: Find the indicators with the highest variability in data values
WITH data_variability AS (
    SELECT indicator_id, STDDEV(data_value) AS data_stddev
    FROM air_quality_data
    GROUP BY indicator_id
)
SELECT name, data_stddev
FROM data_variability
JOIN air_quality_data ON data_variability.indicator_id = air_quality_data.indicator_id
ORDER BY data_stddev DESC
LIMIT 5;

-- Example 3: Calculate the 7-day moving average of data values per indicator and neighborhood
WITH data_avg AS (
    SELECT indicator_id, geo_place_name, start_date, AVG(data_value) OVER (PARTITION BY indicator_id, geo_place_name ORDER BY start_date ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING) AS moving_avg
    FROM air_quality_data
)
SELECT indicator_id, geo_place_name, start_date, moving_avg
FROM data_avg
ORDER BY indicator_id, geo_place_name, start_date;

-- Example 4: Calculate the annual average of data values per indicator and neighborhood
SELECT indicator_id, geo_place_name, EXTRACT(YEAR FROM start_date) AS year, AVG(data_value) AS avg_data_value
FROM air_quality_data
GROUP BY indicator_id, geo_place_name, EXTRACT(YEAR FROM start_date)
ORDER BY indicator_id, geo_place_name, year;

-- Example 5: Find the neighborhoods with the highest average air quality levels
SELECT geo_place_name, AVG(data_value) AS avg_data_value
FROM air_quality_data
GROUP BY geo_place_name
ORDER BY avg_data_value DESC
LIMIT 10;
