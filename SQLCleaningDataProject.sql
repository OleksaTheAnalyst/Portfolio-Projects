--Cleaning Data in SQL Queries

SELECT *
FROM SQLProjects..ProjectSql2

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT saleDateConverted, CONVERT(DATE, SaleDate)
FROM SQLProjects..ProjectSql2

UPDATE ProjectSql2
SET SaleDate = CONVERT(DATE, SaleDate)

-- If it doesn't Update properly

ALTER TABLE ProjectSql2
Add SaleDateConverted Date;

Update ProjectSql2
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM SQLProjects..ProjectSql2
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT T1.ParcelID, T1.PropertyAddress, T2.ParcelID, T2.PropertyAddress, ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM SQLProjects..ProjectSql2 T1
JOIN SQLProjects..ProjectSql2 T2
ON T1.ParcelID = T2.ParcelID
AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

UPDATE T1
SET PropertyAddress = ISNULL(T1.PropertyAddress, T2.PropertyAddress)
FROM SQLProjects..ProjectSql2 T1
JOIN SQLProjects..ProjectSql2 T2
ON T1.ParcelID = T2.ParcelID
AND T1.[UniqueID ] <> T2.[UniqueID ]
WHERE T1.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM SQLProjects..ProjectSql2
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Adress
FROM SQLProjects..ProjectSql2

ALTER TABLE ProjectSql2
Add PropertySplitAdress NVARCHAR(255);

Update ProjectSql2
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE ProjectSql2
Add PropertySplitCity NVARCHAR(255);

Update ProjectSql2
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM SQLProjects..ProjectSql2
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM SQLProjects..ProjectSql2
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM SQLProjects..ProjectSql2

UPDATE ProjectSql2
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) as row_num
FROM SQLProjects..ProjectSql2
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM SQLProjects..ProjectSql2

ALTER TABLE SQLProjects..ProjectSql2
DROP COLUMN PropertyAddress, TaxDistrict

ALTER TABLE SQLProjects..ProjectSql2
DROP COLUMN SaleDate