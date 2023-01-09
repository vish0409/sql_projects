-- Data Cleaning using SQL. 
-- Data set used for this is the housing data in Nashville,USA


select * from portfolio_project..Nashville_housing

-- 1. Date formatting

ALTER TABLE portfolio_project..Nashville_housing
Add SaleDateCleaned date;

update portfolio_project..Nashville_housing 
set SaleDateCleaned = CONVERT(date,SaleDate)

select SaleDate,SaleDateCleaned from portfolio_project..Nashville_housing

-- 2. Filling in null property addresses

select * from portfolio_project..Nashville_housing
where PropertyAddress is null -- checking the null values

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolio_project..Nashville_housing a
join portfolio_project..Nashville_housing b -- self joining the table to compare
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] -- parcel id repeats but unique id does not, we can use the unique id to eliminate duplicates
where a.PropertyAddress is null

--populating all the null values of a table with the property address of b table
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..Nashville_housing a
join portfolio_project..Nashville_housing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null


update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..Nashville_housing a
join portfolio_project..Nashville_housing b -- self joining the table to compare
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] -- parcel id repeats but unique id does not, we can use the unique id to eliminate duplicates
where a.PropertyAddress is null

-- checking if table has any nulls left in property address column
select * from portfolio_project..Nashville_housing
where PropertyAddress is null

-- 3. Splitting Address columns into Address, City, State

--splitting property address
select PropertyAddress
from portfolio_project..Nashville_housing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from portfolio_project..Nashville_housing

ALTER TABLE portfolio_project..Nashville_housing
Add PropertySplitAddress Nvarchar(255);

update portfolio_project..Nashville_housing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE portfolio_project..Nashville_housing
Add PropertySplitCity Nvarchar(255);

update portfolio_project..Nashville_housing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select * from 
portfolio_project..Nashville_housing

--splitting owner address

select OwnerAddress 
from portfolio_project..Nashville_housing

select PARSENAME(OwnerAddress,1) -- parsename only delimits by periods
from portfolio_project..Nashville_housing

select 
PARSENAME(replace(OwnerAddress,',','.'), 3) as Owner_Address,
PARSENAME(replace(OwnerAddress,',','.'), 2)as Owner_City,
PARSENAME(replace(OwnerAddress,',','.'), 1)as Owner_State 
from portfolio_project..Nashville_housing

ALTER TABLE portfolio_project..Nashville_housing
Add Owner_Address Nvarchar(255);

update portfolio_project..Nashville_housing
set Owner_Address=PARSENAME(replace(OwnerAddress,',','.'), 3)

ALTER TABLE portfolio_project..Nashville_housing
Add Owner_City Nvarchar(255);

update portfolio_project..Nashville_housing
set Owner_City=PARSENAME(replace(OwnerAddress,',','.'), 2)

ALTER TABLE portfolio_project..Nashville_housing
Add Owner_State Nvarchar(255);

update portfolio_project..Nashville_housing
set Owner_State=PARSENAME(replace(OwnerAddress,',','.'), 1)

select * from portfolio_project..Nashville_housing

-- 4. Changing Y and N into Yes and No in Sold as Vacant 

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolio_project..Nashville_housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end as cleaned_col
from portfolio_project..Nashville_housing

update portfolio_project..Nashville_housing
set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end  

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolio_project..Nashville_housing
group by SoldAsVacant
order by 2

--5. Remove duplicates

-- Tempt Table:
with RowNumCTE as(
select *,
     ROW_NUMBER()Over(
	 partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
				 ) row_num

from portfolio_project..Nashville_housing
--order by UniqueID
)
-- deleting duplicates 
delete
from RowNumCTE
where row_num>1 


