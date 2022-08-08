USE adventureworks
GO
-- SETUP
CREATE SCHEMA SALES;
GO
-- *******************************************************************************
-- DEMONSTRAÇÃO DE VIEWS
CREATE OR ALTER VIEW Sales.vwSalesByCustomers
AS
	SELECT 
		oh.CustomerID,
		c.FirstName, c.LastName,
		SUM(oh.SubTotal) Total,
		AVG(oh.SubTotal) AVG_Total,
		MAX(oh.SubTotal) MAX_Total,
		MIN(oh.SubTotal) MIN_Total,
		COUNT(*) QtdVendas
	from salesLT.SalesOrderHeader oh
	INNER JOIN salesLT.Customer c ON c.CustomerID = oh.CustomerID
	group by oh.CustomerID, c.FirstName, c.LastName
GO
-- *******************************************************************************
-- DEMONSTRAÇÃO DE TABLE VALUE FUNCTION
CREATE FUNCTION Sales.ufn_ProductCategory (@pProductid INT, @pCategoryName char(100))
RETURNS TABLE
AS
RETURN 
	SELECT 
		pcat.Name AS ParentCategory, 
		cat.Name AS SubCategory, 	
		prd.Name AS ProductName,
		prd.ProductID
	FROM SalesLT.ProductCategory pcat 
	JOIN SalesLT.ProductCategory as cat ON pcat.ProductCategoryID = cat.ParentProductCategoryID 
	JOIN SalesLT.Product as prd ON prd.ProductCategoryID = cat.ProductCategoryID
	where prd.ProductID = @pProductid OR pcat.Name = @pCategoryName
GO
-- EXEMPLO:
SELECT *
FROM Sales.ufn_ProductCategory(996, 'Bikes') AS p
order by 4 DESC
GO

CREATE OR ALTER FUNCTION Sales.ufn_SalesByCustomersTop (@pTop int)
RETURNS TABLE
AS
RETURN 
	SELECT TOP (@pTop) 
		oh.CustomerID,
		c.FirstName, c.LastName,
		SUM(oh.SubTotal) Total,
		AVG(oh.SubTotal) AVG_Total,
		MAX(oh.SubTotal) MAX_Total,
		MIN(oh.SubTotal) MIN_Total,
		COUNT(*) QtdVendas
	from salesLT.SalesOrderHeader oh
	INNER JOIN salesLT.Customer c ON c.CustomerID = oh.CustomerID
	group by oh.CustomerID, c.FirstName, c.LastName
	order BY Total DESC
GO

SELECT *
FROM Sales.ufn_SalesByCustomersTop(5)

-- 	SELECT TOP (@pTop) 
-- 		c.CustomerID, c.FirstName, c.LastName, c.Total, c.AVG_Total, c.MAX_Total, c.MIN_Total, c.QtdVendas
-- 	FROM Sales.vwSalesByCustomers c
-- 	order by c.Total DESC
-- *******************************************************************************
-- DEMONSTRAÇÃO DE DERIVED TABLE
DECLARE @pTop INT;
SET @pTop = 10;
SELECT 
	c.CustomerID, c.CustomerName, c.Total, c.AVG_Total, c.MAX_Total, c.MIN_Total, c.QtdVendas,
	ad.AddressType
FROM (
	SELECT top (@pTop) 
		p.CustomerID, p.FirstName + ' ' + p.LastName as CustomerName, 
		p.Total, p.AVG_Total, p.MAX_Total, p.MIN_Total, p.QtdVendas
	FROM (
		SELECT 
				oh.CustomerID,
				c.FirstName, c.LastName,
				SUM(oh.SubTotal) Total,
				AVG(oh.SubTotal) AVG_Total,
				MAX(oh.SubTotal) MAX_Total,
				MIN(oh.SubTotal) MIN_Total,
				COUNT(*) QtdVendas
		from salesLT.SalesOrderHeader oh
		INNER JOIN salesLT.Customer c ON c.CustomerID = oh.CustomerID
		group by oh.CustomerID, c.FirstName, c.LastName
	) as p
	ORDER BY p.Total
) as c
INNER JOIN SalesLT.CustomerAddress ad ON ad.CustomerID = c.CustomerID
GO
-- DEMONSTRAÇÃO DE CTE
WITH cteCustomers AS
	(SELECT 
		oh.CustomerID, c.FirstName + ' ' + c.LastName as CustomerName, oh.SalesOrderID,
		oh.TotalDue,
		oh.SubTotal Total
	from salesLT.SalesOrderHeader oh
	INNER JOIN salesLT.Customer c ON c.CustomerID = oh.CustomerID
	) 
SELECT 
	c.SalesOrderID, c.Total, c.TotalDue, c.CustomerID, c.CustomerName,
	p.ProductID, p.Name as ProductName,
	od.OrderQty, od.LineTotal, od.UnitPrice,
	od.LineTotal / c.Total as pctSalesTotal
FROM SalesLT.SalesOrderDetail od
INNER JOIN SalesLT.Product p ON p.ProductID = od.ProductID
INNER JOIN cteCustomers c ON c.SalesOrderID = od.SalesOrderID
where od.LineTotal / c.Total > 0.50

-- CTE 2
WITH cteCustomers AS
	(SELECT 
		oh.CustomerID, c.FirstName + ' ' + c.LastName as CustomerName, oh.SalesOrderID,
		oh.TotalDue,
		oh.SubTotal Total
	from salesLT.SalesOrderHeader oh
	INNER JOIN salesLT.Customer c ON c.CustomerID = oh.CustomerID
	),
	cteVendas as
	(
	SELECT 
		c.SalesOrderID, c.Total, c.TotalDue, c.CustomerID, c.CustomerName,
		p.ProductID, p.Name as ProductName,
		od.OrderQty, od.LineTotal, od.UnitPrice,
		od.LineTotal / c.Total as pctSalesTotal
	FROM SalesLT.SalesOrderDetail od
	INNER JOIN SalesLT.Product p ON p.ProductID = od.ProductID
	INNER JOIN cteCustomers c ON c.SalesOrderID = od.SalesOrderID
	)
SELECT *
FROM cteVendas v
where pctSalesTotal > 0.50