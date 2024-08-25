

-- Cleaning Data in SQL Queries

SELECT 
    *
FROM
    dataset;
    
-- Standardize Date Format.

ALTER TABLE dataset
ADD COLUMN SaleDateConverted DATE;

UPDATE dataset 
SET 
    SaleDates = STR_TO_DATE(SaleDate, '%M %e, %Y');
    
    
--  Populate Property Address data

SELECT 
    *
FROM
    dataset
WHERE
    PropertyAddress IS NULL;


SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(a.PropertyAddress, b.PropertyAddress) AS CombinedPropertyAddress
FROM
    dataset a
        JOIN
    dataset b ON a.ParcelID = b.ParcelID
        AND a.UniqueID_ <> b.UniqueID_
WHERE
    a.PropertyAddress IS NULL;

UPDATE dataset a
        JOIN
    dataset b ON a.ParcelID = b.ParcelID
        AND a.UniqueID_ <> b.UniqueID_ 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

--  Breaking out Address into Individual Columns (Address, City, State)

SELECT 
    PropertyAddress
FROM
    dataset;

SELECT 
    SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1) AS Address1,
    SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1) AS Address2
FROM
    dataset;

ALTER TABLE dataset
ADD COLUMN PropertySplitAddress VARCHAR(255);


-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Perform the update
UPDATE dataset 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);

-- Re-enable safe update mode (optional but recommended)
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE dataset
ADD COLUMN PropertySplitCity VARCHAR(255);


-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Perform the update
UPDATE dataset 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1);

-- Re-enable safe update mode (optional but recommended)
SET SQL_SAFE_UPDATES = 1;



SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 3),
            ',',
            1) AS Part1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 2),
            ',',
            1) AS Part2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 1),
            ',',
            1) AS Part3
FROM
    dataset;

ALTER TABLE dataset
ADD COLUMN OwnerSplitAddress VARCHAR(255);


-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

UPDATE dataset 
SET 
    OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 3),
            ',',
            1);

ALTER TABLE dataset
ADD COLUMN OwnerSplitCity VARCHAR(255);

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

UPDATE dataset 
SET 
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', - 2),
                ',',
                1));

ALTER TABLE dataset
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE dataset 
SET 
    OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', - 1));

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
    SoldAsVacant, COUNT(SoldAsVacant) AS Counts
FROM
    dataset
GROUP BY SoldAsVacant
ORDER BY Counts;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    dataset;

UPDATE dataset 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

SELECT DISTINCT
    SoldAsVacant
FROM
    dataset;

-- Identifying Duplicates records.

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID_
           ) AS row_num
    FROM dataset
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Delete Unused Columns



SELECT 
    *
FROM
    dataset;

SELECT 
    COUNT(*) AS NumberOfColumns
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = 'data_cleaning_db'
        AND TABLE_NAME = 'dataset';



ALTER TABLE dataset
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;





















