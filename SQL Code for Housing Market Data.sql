/*

Cleaning Data in SQL Queries

*/

-- Obtaining all the data from the excel doc imported
Select *
From SQLProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Look at sell date and change format
-- Remove date, time format for ease of observing data

Select saleDateConverted, CONVERT(Date,SaleDate)
From SQLProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly, we can alter table
-- another alternative

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Looking at Property Address data
-- Data contains many houses with null addresses
-- Property Address is fixed, cannot changeso we could populate it
-- If parcel ID same as another parcel ID then same address
-- Unique ID must be unique don't want it to repeat
Select *
From SQLProject.dbo.NashvilleHousing
--Selecting where PropertyAddress is null
order by ParcelID


-- Sticking in another address when it is null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLProject.dbo.NashvilleHousing a
JOIN SQLProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQLProject.dbo.NashvilleHousing a
JOIN SQLProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- adding more delimiters to make it more readable

Select PropertyAddress
From SQLProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

-- looking for commas and beginning search at 1st Value
-- -1 location is just before comma
-- +1 just after comma
-- we go to just the length of the varying property address

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From SQLProject.dbo.NashvilleHousing

-- add results
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From SQLProject.dbo.NashvilleHousing



-- Split Owner address as city,state
-- we will use paresname for delimited addresses 
-- it looks for commas and replaces with periods
Select OwnerAddress
From SQLProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLProject.dbo.NashvilleHousing


-- Updating with new format of owner address
-- Makes it more useable if you have state and city seperated
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From SQLProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Make it clear that it is either yes or no
-- No need for 4 varaibles
-- use case statement

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From SQLProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From SQLProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate data
-- Use a CTE
-- duplicate rows highlight using row number we can also use rank
-- partition by unique properties

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQLProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From SQLProject.dbo.NashvilleHousing



---------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns by dropping them


Select *
From SQLProject.dbo.NashvilleHousing


ALTER TABLE SQLProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate












