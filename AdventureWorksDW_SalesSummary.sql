-- ==========================================
-- Sales Margin Report (AdventureWorksDW2017)
-- Time Allocation: 2 Hours
-- ==========================================

-- 🎯 Business Scenario:
-- You are working as a Data Engineer for a company that analyzes product performance.
-- The sales team needs a report that shows the profitability of each product subcategory by region.

-- 📌 Business Requirement:
-- The report should include the following for each product subcategory:
--   1. Product Subcategory Name
--   2. Region Name (from geography dimension)
--   3. Total Sales Amount
--   4. Total Product Cost
--   5. Profit Margin Percentage
--   6. Sales Rank based on Total Sales Amount in that region

-- 🧮 Profit Margin Formula:
--     (Total Sales Amount - Total Product Cost) / Total Sales Amount * 100

-- ✅ Deliverables:
-- 1. Create a scalar-valued function:
--      Name: fn_ProfitMargin
--      Inputs: @SalesAmount (MONEY), @TotalCost (MONEY)
--      Output: Profit margin as a DECIMAL(10,2)
--      Note: Return NULL if SalesAmount is 0 or NULL.
USE AdventureWorksDW2017;

GO

CREATE OR ALTER FUNCTION fn_ProfitMargin(@SalesAmount MONEY, @TotalCost MONEY)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @Profit Money, @ProfitPercent DECIMAL(10,2);
	IF @SalesAmount IS NULL OR @SalesAmount = 0
        RETURN NULL;
	SET @Profit = @SalesAmount - @TotalCost;
	SET @ProfitPercent = CAST((@Profit / @SalesAmount)*100 AS decimal(10,2));
	RETURN @ProfitPercent;
END

GO 

-- SELECT dbo.fn_ProfitMargin(100,90) AS ProfitPercent

GO

-- 2. Create a stored procedure:
--      Name: usp_SalesMarginReport
--      Inputs: @Year (INT), @Region (NVARCHAR)
--      Output: A SELECT query showing all required columns
--      Logic:
--          - Use FactResellerSales, DimProduct, DimProductSubcategory, DimGeography, DimDate
--          - Apply the scalar function to compute ProfitMargin%
--          - Use ROW_NUMBER or RANK to get SalesRank by region
--          - Filter by CalendarYear and RegionCountryName

-- SELECT * FROM FactResellerSales ; SELECT * FROM DimGeography
-- SELECT * FROM DimGeography Where EnglishCountryRegionName = 'United States'
-- SELECT * FROM DimProduct
-- SELECT * FROM DimDate

CREATE OR ALTER PROC usp_SalesMarginReport (@Year INT, @Region NVARCHAR(100))
AS
BEGIN
	-- SELECT *, RANK() OVER (Order BY RankedItems.TotalSales DESC) AS TotalSalesRank FROM (
	SELECT d_subcat.EnglishProductSubcategoryName as ProductSubCategory, 
			d_geo.EnglishCountryRegionName as Region,
			SUM(f_sales.SalesAmount) AS TotalSales,
			SUM(f_sales.TotalProductCost) AS TotalProductCost,
			dbo.fn_ProfitMargin(SUM(f_sales.SalesAmount), SUM(f_sales.TotalProductCost)) as ProfitMarginPercentage,
			RANK() OVER (Order BY SUM(f_sales.SalesAmount) DESC) AS TotalSalesRank 
		FROM FactResellerSales as f_sales
		JOIN DimProduct as d_prod
			ON f_sales.ProductKey = d_prod.ProductKey
		JOIN DimProductSubcategory as d_subcat
			ON d_subcat.ProductSubcategoryKey = d_prod.ProductSubcategoryKey
		JOIN DimGeography as d_geo
			ON f_sales.SalesTerritoryKey = d_geo.SalesTerritoryKey
		JOIN DimDate as d_date
			ON d_date.DateKey = f_sales.OrderDateKey 
		WHERE d_geo.EnglishCountryRegionName = @Region AND d_date.CalendarYear=@Year
		GROUP BY d_subcat.EnglishProductSubcategoryName, d_geo.EnglishCountryRegionName
	 -- ) AS RankedItems
END


-- 3. Execute the procedure with test parameters:
--      EXEC usp_SalesMarginReport @Year = 2013, @Region = 'United States';

EXEC usp_SalesMarginReport @Year = 2013, @Region = 'United States';

-- 📂 Tables to Use:
--   - FactResellerSales
--   - DimProduct
--   - DimProductSubcategory
--   - DimGeography
--   - DimDate

-- 🧠 Tips:
--   - Use INNER JOINs to connect the fact and dimension tables
--   - Aggregate using SUM()
--   - Use WHERE clause to filter by input parameters
--   - Function should be called inside SELECT statement

-- 📌 Reminder:
-- Do not include hardcoded values — use the input parameters!
-- Structure your code so it's readable, logical, and reusable.
-- ==========================================


--END 
------------------------------------------------------------------------
-- Test CODE:
SELECT * FROM (SELECT d_subcat.EnglishProductSubcategoryName as ProductSubCategory, 
			SUM(f_sales.SalesAmount) AS TotalSales,
			SUM(f_sales.TotalProductCost) AS TotalProductCost,
			dbo.fn_ProfitMargin(SUM(f_sales.SalesAmount), SUM(f_sales.TotalProductCost)) as ProfitMarginPercentage
			   -- ,RANK() OVER (ORDER BY f_sales.SalesAmount DESC)
			FROM FactResellerSales as f_sales
			JOIN DimProduct as d_prod
				ON f_sales.ProductKey = d_prod.ProductKey
			--JOIN DimProductCategory as d_cat
			--	ON d_cat.ProductCategoryKey = d_prod.ProductKey
			JOIN DimProductSubcategory as d_subcat
				ON d_subcat.ProductSubcategoryKey = d_prod.ProductSubcategoryKey
			JOIN DimGeography as d_geo
				ON f_sales.SalesTerritoryKey = d_geo.SalesTerritoryKey
			JOIN DimDate as d_date
				ON d_date.DateKey = f_sales.OrderDateKey 
			WHERE d_geo.EnglishCountryRegionName='United States'  AND d_date.CalendarYear=2013
			GROUP BY d_subcat.EnglishProductSubcategoryName) AS RegionSales -- sub query not required !
			ORDER BY TotalSales DESC;