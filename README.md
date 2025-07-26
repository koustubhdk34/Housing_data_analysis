 # 🧹 Nashville Housing Data Cleaning Project (MySQL)

## 📌 Project Overview
This project focuses on cleaning raw real estate data from Nashville using MySQL. The goal is to prepare the dataset for future analysis by addressing formatting issues, missing values, inconsistent entries, and duplicates.

---

## 🛠 Dataset
- **Source**: Nashville Housing CSV file
- **Staging Table**: `housing_data_stagging`

---

## 🔧 Cleaning Steps Performed

### 1. ✅ Created a staging table
- Duplicated the original dataset into a working table `housing_data_stagging`.

### 2. 🗓 Converted `SaleDate` to standard date format
- Transformed `SaleDate` (e.g., "April 9, 2013") into a new column `SaleDateConverted` using `STR_TO_DATE`.

### 3. 🏘 Filled missing `PropertyAddress`
- Used self-join logic on `ParcelID` to fill null values in `PropertyAddress` where possible.

### 4. 📍 Split `PropertyAddress` into components
- Extracted street address and city using `SUBSTRING_INDEX`.

### 5. 👤 Split `OwnerAddress` into multiple fields
- Split full owner address into `OwnerSplitAddress`, `OwnerSplitCity`, and `OwnerSplitState`.

### 6. ✅ Cleaned `SoldAsVacant` field
- Standardized values: converted "Y"/"N" to "Yes"/"No".

### 7. 🔁 Removed duplicates
- Used a CTE with `ROW_NUMBER()` to find and delete exact duplicate records.

### 8. 🧹 Dropped unused columns
- Removed columns no longer needed after transformations: `OwnerAddress`, `TaxDistrict`, `PropertyAddress`, `SaleDate`.

---

## ✅ Final Output
Cleaned dataset stored in `housing_data_stagging`, ready for further analysis or export.
