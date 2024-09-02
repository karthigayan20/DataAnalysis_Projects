select * from dbo.Train

-- Remove Duplicates
ALTER TABLE Train
ADD ID INT IDENTITY(1,1) PRIMARY KEY;

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Train';

ALTER TABLE Train
ALTER COLUMN [ADDRESS] NVARCHAR(MAX);

WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY [POSTED_BY], [UNDER_CONSTRUCTION], [RERA], 
                              [BHK_NO], [BHK_OR_RK], [SQUARE_FT], [READY_TO_MOVE], 
                              [RESALE], [ADDRESS], [LONGITUDE], [LATITUDE], 
                              [TARGET_PRICE_IN_LACS] 
                              ORDER BY [ID]) AS rn
    FROM Train
)
DELETE FROM Train
WHERE ID IN (SELECT ID FROM CTE WHERE rn > 1);

-- Check and Convert Data Types

-- Example: Convert SQUARE_FT to INTEGER if needed

ALTER TABLE Train
ALTER COLUMN [SQUARE_FT] INT;

ALTER TABLE Train
ALTER COLUMN [TARGET_PRICE_IN_LACS] DECIMAL(10, 2);

--String Manipulation on ADDRESS column

UPDATE Train 
SET ADDRESS = TRIM(ADDRESS);

--Outlier Detection and Handling

-- Detect outliers in SQUARE_FT
SELECT * FROM Train
WHERE SQUARE_FT > (SELECT AVG(SQUARE_FT) + 3 * STDEV(SQUARE_FT) FROM Train)
   OR SQUARE_FT < (SELECT AVG(SQUARE_FT) - 3 * STDEV(SQUARE_FT) FROM Train);

-- Detect outliers in TARGET(PRICE_IN_LACS)
SELECT * FROM Train
WHERE [TARGET_PRICE_IN_LACS] > (SELECT AVG([TARGET_PRICE_IN_LACS]) + 3 * STDEV([TARGET_PRICE_IN_LACS]) FROM Train)
   OR [TARGET_PRICE_IN_LACS] < (SELECT AVG([TARGET_PRICE_IN_LACS]) - 3 * STDEV([TARGET_PRICE_IN_LACS]) FROM Train);

-- Inconsistent Data Formats
UPDATE Train
SET POSTED_BY = UPPER(POSTED_BY);

-- Checking for Zero or Negative Values
SELECT * FROM Train
WHERE SQUARE_FT <= 0 OR TARGET_PRICE_IN_LACS <= 0;

-- Handling Unwanted Characters or Symbols

SELECT REPLACE(ADDRESS, 'pattern', 'replacement') as updatedAddressPattern
FROM Train;

--  Consistent Representation of Categorical Variables
SELECT DISTINCT POSTED_BY FROM Train;

--  Geographical Data Validation
SELECT * FROM Train
WHERE LONGITUDE < -180 OR LONGITUDE > 180
   OR LATITUDE < -90 OR LATITUDE > 90 ;

ALTER TABLE Train
ALTER COLUMN [LONGITUDE] DECIMAL(10,2);

ALTER TABLE Train
ALTER COLUMN [LATITUDE] DECIMAL(10,2);

