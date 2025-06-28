USE AdventureWorksDW2017;
GO
CREATE SCHEMA analytics;
GO

SELECT TOP 10 * From dbo.DimDate
GO

CREATE OR ALTER VIEW analytics.dim_date
AS
SELECT   DateKey as DIM_DateId
		,FullDateAlternateKey as FullDate
		,CalendarYear
		,EnglishMonthName as CalendarMonthName
		,CalendarQuarter	
		,CalendarSemester
		,FiscalYear
		,FiscalQuarter
		,FiscalSemester
FROM dbo.DimDate

GO

CREATE OR ALTER VIEW analytics.dim_product
AS
SELECT   p.ProductKey as DIM_ProductId
		,p.EnglishProductName as [Name]
		,pc.EnglishProductCategoryName as Category
		,psc.EnglishProductSubcategoryName as SubCategory
FROM dbo.DimProduct as p
JOIN dbo.DimProductSubcategory as psc
	ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
JOIN dbo.DimProductCategory as pc
	ON pc.ProductCategoryKey = psc.ProductCategoryKey

GO

CREATE OR ALTER VIEW analytics.dim_customer
AS
SELECT   c.CustomerKey as DIM_CustomerId
		,c.FirstName
		,c.LastName
		,c.BirthDate
		,c.Gender
		,g.EnglishCountryRegionName as Country  
FROM dbo.DimCustomer as c
JOIN dbo.DimGeography as g
	ON c.GeographyKey = g.GeographyKey

GO

CREATE OR ALTER VIEW analytics.dim_sales_territory
AS
SELECT   SalesTerritoryKey as DIM_SalesTerritoryId
		,SalesTerritoryGroup as SalesGroup
		,SalesTerritoryCountry as Country
		,SalesTerritoryRegion as Region
FROM dbo.DimSalesTerritory

GO

CREATE OR ALTER VIEW analytics.fact_internet_sales
AS
SELECT   ProductKey as DIM_ProductId
		,OrderDateKey as DIM_OrderDateId
		,ShipDateKey as DIM_ShipDateId
		,DueDateKey as DIM_DueDateId
		,CustomerKey as DIM_CustomerId
		,SalesTerritoryKey as DIM_SalesTerritoryId
		,UnitPrice
		,OrderQuantity
		,SalesAmount
FROM dbo.FactInternetSales

GO



