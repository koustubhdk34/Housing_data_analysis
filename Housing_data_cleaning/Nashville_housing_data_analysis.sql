# Cleaning Data in SQL Queries
create table housing_data_stagging 
like housing_data;
select * from housing_data_stagging;

insert into housing_data_stagging 
select * from housing_data;

SELECT *
FROM housing_data_stagging;


# Standardize Date Format

SELECT STR_TO_DATE(SaleDate, '%m/%d/%Y') AS saleDateConverted, SaleDate
FROM housing_data_stagging;

ALTER TABLE housing_data_stagging
ADD COLUMN SaleDateConverted DATE;

UPDATE housing_data_stagging
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y');


# Populate Property Address data

SELECT *
FROM housing_data_stagging
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress AS AddressA, b.ParcelID, b.PropertyAddress AS AddressB, 
       IFNULL(a.PropertyAddress, b.PropertyAddress) AS MergedAddress
FROM housing_data_stagging a
JOIN housing_data_stagging b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE housing_data_stagging a
JOIN housing_data_stagging b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

# --------------------------------------------
# Breaking out Address into Individual Columns (Address, City)

SELECT PropertyAddress
FROM housing_data_stagging;
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID;

SELECT
  SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
  TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS City
FROM housing_data_stagging;

ALTER TABLE housing_data_stagging
ADD COLUMN PropertySplitAddress VARCHAR(255);

UPDATE housing_data_stagging
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE housing_data_stagging
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE housing_data_stagging
SET PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));

SELECT *
FROM housing_data_stagging;

# --------------------------------------------
# Split OwnerAddress into Address, City, State

SELECT OwnerAddress
FROM housing_data_stagging;

SELECT
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS OwnerSplitAddress,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerSplitCity,
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerSplitState
FROM housing_data_stagging;

ALTER TABLE housing_data_stagging
ADD COLUMN OwnerSplitAddress VARCHAR(255);

UPDATE housing_data_stagging
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

ALTER TABLE housing_data_stagging
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE housing_data_stagging
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE housing_data_stagging
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE housing_data_stagging
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

SELECT *
FROM housing_data_stagging;

# --------------------------------------------
# Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS Count
FROM housing_data_stagging
GROUP BY SoldAsVacant
ORDER BY Count;

SELECT SoldAsVacant,
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END AS Cleaned
FROM housing_data_stagging;

UPDATE housing_data_stagging
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

# --------------------------------------------
# Remove Duplicates

WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM housing_data_stagging
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

# Delete Duplicates
DELETE FROM housing_data_stagging
WHERE UniqueID IN (
  SELECT UniqueID FROM (
    SELECT UniqueID,
      ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference
        ORDER BY UniqueID
      ) AS row_num
    FROM housing_data_stagging
  ) AS Temp
  WHERE row_num > 1
);

SELECT *
FROM housing_data_stagging;

# --------------------------------------------
# Delete Unused Columns

SELECT *
FROM housing_data_stagging;

ALTER TABLE housing_data_stagging
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;

