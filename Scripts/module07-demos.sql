use AdventureWorksFull

-- 304 registros (registros distintos entre os conjuntos)
SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName
FROM [HumanResources].[vEmployee] e
UNION 
select distinct c.City, c.StateProvinceName, c.CountryRegionName
from sales.vIndividualCustomer c

-- 322 registros
SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName
FROM [HumanResources].[vEmployee] e
UNION ALL
select DISTINCT c.City, c.StateProvinceName, c.CountryRegionName
from sales.vIndividualCustomer c
ORDER BY city ASC

-- 
SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName, 'Empregados' as Origem
FROM [HumanResources].[vEmployee] e
UNION ALL
select DISTINCT c.City, c.StateProvinceName, c.CountryRegionName, 'Clientes' as Origem
from sales.vIndividualCustomer c

SELECT Origem, CountryRegionName, COUNT(*) QtdCidades
FROM (
    SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName, 'Empregados' as Origem
    FROM [HumanResources].[vEmployee] e
    UNION ALL
    select DISTINCT c.City, c.StateProvinceName, c.CountryRegionName, 'Clientes' as Origem
    from sales.vIndividualCustomer c
) as cidades
GROUP BY Origem, CountryRegionName
order by QtdCidades DESC

-- INTERSECT
SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName
FROM [HumanResources].[vEmployee] e
INTERSECT
select DISTINCT c.City, c.StateProvinceName, c.CountryRegionName
from sales.vIndividualCustomer c

-- EXCEPT (EMPREGADOS)
SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName
FROM [HumanResources].[vEmployee] e
EXCEPT
select DISTINCT c.City, c.StateProvinceName, c.CountryRegionName
from sales.vIndividualCustomer c

-- EXCEPT (Clientes)
select DISTINCT c.City, c.StateProvinceName, c.CountryRegionName
from sales.vIndividualCustomer c
EXCEPT
SELECT DISTINCT e.City, e.StateProvinceName, e.CountryRegionName
FROM [HumanResources].[vEmployee] e

-- DEMO: OUTER APPLY
USE adventureworks
-- SELECT BASE
SELECT TOP (3)
    od.SalesOrderID, od.SalesOrderDetailID, od.ProductID, od.OrderQty, od.UnitPrice, od.UnitPriceDiscount, od.LineTotal
FROM SalesLT.SalesOrderDetail od
ORDER BY od.ModifiedDate DESC

SELECT 
    p.ProductID, p.Name as ProductName, p.[Size],
    c.FirstName + ' ' + c.LastName as CustomerName,
    v.SalesOrderID, v.SalesOrderDetailID, v.OrderQty, v.UnitPrice, v.UnitPriceDiscount, v.LineTotal
FROM saleslt.Product p
CROSS APPLY
(
    SELECT TOP (3)
    od.SalesOrderID, od.SalesOrderDetailID, od.ProductID, od.OrderQty, od.UnitPrice, od.UnitPriceDiscount, od.LineTotal
    FROM SalesLT.SalesOrderDetail od
    where od.ProductID = p.ProductID
    ORDER BY od.ModifiedDate DESC
) as v
LEFT JOIN SalesLT.SalesOrderHeader oh ON oh.SalesOrderID = v.SalesOrderID
LEFT JOIN SalesLT.Customer c ON c.CustomerID = oh.CustomerID
GO
-- ABSTRAINDO
CREATE OR ALTER FUNCTION Sales.ufn_LastSalesByProduct (@pProductid INT, @pTopN int)
RETURNS TABLE
AS
RETURN 
    SELECT TOP (@pTopN)
    od.SalesOrderID, od.SalesOrderDetailID, od.ProductID, od.OrderQty, od.UnitPrice, od.UnitPriceDiscount, od.LineTotal
    FROM SalesLT.SalesOrderDetail od
    where od.ProductID = @pProductid
    ORDER BY od.ModifiedDate DESC
GO
-- OUTER
SELECT 
    p.ProductID, p.Name as ProductName, p.[Size],
    c.FirstName + ' ' + c.LastName as CustomerName,
    v.SalesOrderID, v.SalesOrderDetailID, v.OrderQty, v.UnitPrice, v.UnitPriceDiscount, v.LineTotal
FROM saleslt.Product p
OUTER APPLY Sales.ufn_LastSalesByProduct(p.ProductID, 3) as v
LEFT JOIN SalesLT.SalesOrderHeader oh ON oh.SalesOrderID = v.SalesOrderID
LEFT JOIN SalesLT.Customer c ON c.CustomerID = oh.CustomerID
GO