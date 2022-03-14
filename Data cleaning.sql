-- DATA CLEANING 
SELECT *
FROM PortfolioProject..Housing



-- STANDARDIZING THE DATE FORMAT 
SELECT SaleDate, CONVERT(DATE, SaleDate) AS New_Sales_date
FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
ADD New_Sales_date date;

UPDATE PortfolioProject..Housing
SET New_Sales_date = CONVERT(DATE, SaleDate);



-- POPULATING PROPERTY ADDRESS 
SELECT *
FROM PortfolioProject..Housing
WHERE PropertyAddress IS NULL


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing A
JOIN PortfolioProject..Housing B
 ON A.ParcelID = B.ParcelID
 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing A
JOIN PortfolioProject..Housing B
 ON A.ParcelID = B.ParcelID
 AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL



-- BREAKING PROPERTY ADDRESS INTO DIFFERENT COLUMNS

-- METHOD 1 - (USING SUBSTRING)
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as  Property_address_splitted,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(Propertyaddress)) as Property_address_city_splitted
FROM PortfolioProject..Housing


ALTER TABLE PortfolioProject..Housing
ADD Property_address_splitted nvarchar(255);

UPDATE PortfolioProject..Housing
SET Property_address_splitted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 );

ALTER TABLE PortfolioProject..Housing
ADD Property_address_city_splitted nvarchar(255);

UPDATE PortfolioProject..Housing
SET Property_address_city_splitted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(Propertyaddress));


-- METHOD 2 - (USING PARSENAME AND REPLACE)
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Owner_address_splitted,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..Housing


ALTER TABLE PortfolioProject..Housing
ADD Owner_address_splitted nvarchar(255);

UPDATE PortfolioProject..Housing
SET Owner_address_splitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..Housing
ADD Owner_address_city_splitted nvarchar(255);

UPDATE PortfolioProject..Housing
SET Owner_address_city_splitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..Housing
ADD Owner_address_state_splitted nvarchar(255);

UPDATE PortfolioProject..Housing
SET Owner_address_state_splitted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--	CHANGE Y AND N TO 'YES' AND 'NO'
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Housing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE 
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END 
FROM PortfolioProject..Housing


UPDATE PortfolioProject..Housing
SET SoldAsVacant = CASE 
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END 



-- REMOVING DUPLICATES 
with RowNumCte as 
(
 SELECT *,
 ROW_NUMBER() OVER 
 (
 PARTITION BY 
  ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
  ORDER BY UniqueID
 
 ) row_num
 FROM PortfolioProject..Housing
 )

 Select *
 from RowNumCte
 WHERE row_num > 1



--	DELETING UNUSED COLUMNS
 ALTER TABLE PortfolioProject..Housing
 DROP COLUMN OwnerAddress, PropertyAddress,TaxDistrict

 select *
 from PortfolioProject..Housing
