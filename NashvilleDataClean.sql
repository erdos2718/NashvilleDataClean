/*

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing

--standardize date format
Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SalesDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SalesDateConverted = CONVERT(Date,SaleDate);

--Populate property address data

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--Separating Address into individual columns

Select PropertyAddress 
From PortfolioProject.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as CITYSTATE
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select * 
From PortfolioProject.dbo.NashvilleHousing

--Fix SoldAsVacantColumn to be consistent

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
) 
Delete
From RowNumCTE
Where row_num > 1

--Looking at summary statistics by the number of bedrooms the property has
Select Bedrooms, AVG(TotalValue) as price, STDEV(TotalValue) as priceVariation, AVG(Acreage) as land, STDEV(Acreage) as landVariation			
From PortfolioProject.dbo.NashvilleHousing
Group By Bedrooms
Order By Bedrooms

 --Looking at summary statistics by the year the house was built 
Select YearBuilt, AVG(TotalValue) as price, STDEV(TotalValue) as priceVariation, AVG(Acreage) as land, STDEV(Acreage) as landVariation, AVG(Bedrooms) as bedrooms, STDEV(Bedrooms) as bedroomVariation			
From PortfolioProject.dbo.NashvilleHousing
Group By YearBuilt
Order By YearBuilt

					