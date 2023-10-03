-- Cleanining Data SQL queries 
Select * 
from NashvilleHousing


--Standardize Date format

Select SaleDate, Convert(Date, SaleDate) as date 
from NashvilleHousing



Update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate) 

Alter table NashvilleHousing 
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate) 


-- Populate Property Address Data 


Select *
from NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


-- Breaking Out Address into individual column( Address, city, state) 

Select PropertyAddress
From NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) As Address

From NashvilleHousing

Alter table NashvilleHousing 
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


Alter table NashvilleHousing 
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) 

Select *
From NashvilleHousing



-- Owner address  Splitting 

Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME (Replace(OwnerAddress,',','.'), 3),
PARSENAME (Replace(OwnerAddress,',','.'), 2),
PARSENAME (Replace(OwnerAddress,',','.'), 1)
From NashvilleHousing


Alter table NashvilleHousing 
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.'), 3)


Alter table NashvilleHousing 
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (Replace(OwnerAddress,',','.'), 2)

Alter table NashvilleHousing 
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (Replace(OwnerAddress,',','.'), 1)

Select *
From NashvilleHousing


--Change Y and N to Yes and NO in "Sold as Vacant" Field 

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order by 2


Select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'YES'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =  case when SoldAsVacant = 'Y' Then 'YES'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

-- Remove Duplicates 
WITH RowNumCTE as(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By 
					UniqueID
					) row_num

From NashvilleHousing
--Order By ParcelID
)

Select *
From RowNumCTE
Where row_num > 1

-- Deleting Unused columns 

select * 
From NashvilleHousing

Alter Table NashvilleHousing
DROP COLUMN SaleDate
