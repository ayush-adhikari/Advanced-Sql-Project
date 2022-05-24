Select  * from Portfolio_Project..Nashville_housing

--Standardize date format

select convert(date, saledate) as saledate
	from Portfolio_Project..Nashville_housing;

update Portfolio_Project..Nashville_housing
	set SaleDate = CAST(Saledate as date);		--not working. Don't know why :(

Alter table Portfolio_Project..Nashville_housing
	add SaleDate_updated date;

update Portfolio_Project..Nashville_housing
	set SaleDate_updated = CAST(Saledate as date);		--works as intended.

------------------------------------------------------------------------------------------------

-- populate property address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress,a.PropertyAddress)
	from Portfolio_Project..Nashville_housing a
	join Portfolio_Project..Nashville_housing b
		on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null;

update b
	set b.ParcelID = ISNULL(b.PropertyAddress,a.PropertyAddress)
	from Portfolio_Project..Nashville_housing a
	join Portfolio_Project..Nashville_housing b
		on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
	where b.PropertyAddress is null;

------------------------------------------------------------------------------------------------

-- split property address into address and city.


select propertyaddress,
		SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as 'updated_property_address',
		LEFT(propertyaddress, CHARINDEX(',', PropertyAddress)-1) as updated_address
	from Portfolio_Project..Nashville_housing;


Alter table Portfolio_Project..Nashville_housing
	add address nvarchar(255);

update Portfolio_Project..Nashville_housing
	set address = LEFT(propertyaddress, CHARINDEX(',', PropertyAddress)-1);

Alter table Portfolio_Project..Nashville_housing
	add city nvarchar(255);

update Portfolio_Project..Nashville_housing
	set city = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


------------------------------------------------------------------------------------------------

-- split owner address into address, city and State.

select PARSENAME(replace(OwnerAddress, ',', '.'), 3),
		PARSENAME(replace(OwnerAddress, ',', '.'), 2),
		PARSENAME(replace(OwnerAddress, ',', '.'), 1)
	from Portfolio_Project..Nashville_housing;

Alter table Portfolio_Project..Nashville_housing
	add owner_address nvarchar(255);

update Portfolio_Project..Nashville_housing
	set owner_address = PARSENAME(replace(OwnerAddress, ',', '.'), 3);

Alter table Portfolio_Project..Nashville_housing
	add owner_city nvarchar(255);

update Portfolio_Project..Nashville_housing
	set owner_city = PARSENAME(replace(OwnerAddress, ',', '.'), 2);

Alter table Portfolio_Project..Nashville_housing
	add owner_state nvarchar(255);

update Portfolio_Project..Nashville_housing
	set owner_state = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

------------------------------------------------------------------------------------------------

-- split property address into address and city.

Select distinct SoldAsVacant
	from Portfolio_Project..Nashville_housing;

update Portfolio_Project..Nashville_housing
	set SoldAsVacant = 'Yes'
	where SoldAsVacant = 'Y';

update Portfolio_Project..Nashville_housing
	set SoldAsVacant = 'No'
	where SoldAsVacant = 'N';


------------------------------------------------------------------------------------------------

--Deleting duplicates from the table

with cte as (
	select *, ROW_NUMBER() over(partition by ParcelID,
											 PropertyAddress,
											 SaleDate,
											 SalePrice,
											 LegalReference
								order by	UniqueID ) as row
		from Portfolio_Project..Nashville_housing	)
delete
	from cte
	where row>1;

------------------------------------------------------------------------------------------------

-- Deleting Unused columns.

Alter table Portfolio_Project..Nashville_housing
drop column saledate, propertyaddress, taxdistrict, owneraddress;

select *
	from Portfolio_Project..Nashville_housing;
