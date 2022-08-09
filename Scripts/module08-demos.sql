use adventureworks

set STATISTICS io on
dbcc dropcleanbuffers
dbcc freeproccache

-- EXEMPLO SEM OVER
SELECT 
    CAST(oh.OrderDate as date) as OrderDate,
    oh.CustomerID,
    od.ProductID,
    od.LineTotal,
    (SELECT SUM(od.LineTotal) FROM SalesLT.SalesOrderDetail od ) as GrandTotal
    -- GrandTotal = SUM(od.LineTotal) OVER()
FROM SalesLT.SalesOrderDetail od
INNER JOIN SalesLT.SalesOrderHeader oh ON oh.SalesOrderID = od.SalesOrderID
option(recompile)

-- USO DO OVER 1
SELECT 
    CAST(oh.OrderDate as date) as OrderDate,
    oh.CustomerID,
    od.ProductID,
    od.LineTotal,
    -- (SELECT SUM(od.LineTotal) FROM SalesLT.SalesOrderDetail od ) as GrandTotal
    GrandTotal = SUM(od.LineTotal) OVER(),
    GrandTotalByCustomer = SUM(od.LineTotal) OVER(PARTITION BY oh.CustomerID),
    QtdSalesByCustomerProduct = COUNT(*) OVER(PARTITION BY oh.CustomerID, od.ProductID),
    GrandTotalByCustomerProduct = SUM(od.LineTotal) OVER(PARTITION BY oh.CustomerID, od.ProductID)
FROM SalesLT.SalesOrderDetail od
INNER JOIN SalesLT.SalesOrderHeader oh ON oh.SalesOrderID = od.SalesOrderID
option(recompile)

SELECT 
    oh.SalesOrderID,
    CAST(oh.OrderDate as date) as OrderDate,
    oh.CustomerID,
    od.ProductID,
    od.LineTotal,
    -- (SELECT SUM(od.LineTotal) FROM SalesLT.SalesOrderDetail od ) as GrandTotal
    GrandTotal = SUM(od.LineTotal) OVER(),
    GrandTotalByCustomer = SUM(od.LineTotal) OVER(PARTITION BY oh.CustomerID),
    GrandTotalByCustomerProduct = SUM(od.LineTotal) OVER(PARTITION BY oh.CustomerID, od.ProductID),
    OrdersCustomerProduct = COUNT(*) OVER(PARTITION BY oh.CustomerID, od.ProductID)  
FROM Sales.SalesOrderDetail od
INNER JOIN Sales.SalesOrderHeader oh ON oh.SalesOrderID = od.SalesOrderID
where oh.CustomerID = 11000
order by 1 ASC

Use AdventureWorksFull
GO
-- OVER 2
SELECT 
    oh.SalesOrderID as OrderID,
    SalesSeq = ROW_NUMBER() OVER(PARTITION BY oh.CustomerID ORDER BY oh.SalesOrderID),
    PreviousOrder = CAST(LAG(oh.OrderDate, 1, NULL) OVER (PARTITION BY oh.CustomerID ORDER BY oh.SalesOrderID) as date),
    CAST(oh.OrderDate as date) as OrderDate,
    NextOrder = CAST(LEAD(oh.OrderDate, 1, NULL) OVER (PARTITION BY oh.CustomerID ORDER BY oh.SalesOrderID) as date),
    DaysToOrder = DATEDIFF(DAY, oh.OrderDate,LEAD(oh.OrderDate, 1, NULL) OVER (PARTITION BY oh.CustomerID ORDER BY oh.SalesOrderID)),
    oh.CustomerID,
    oh.SubTotal,
    SubTotalRunning = SUM(oh.SubTotal) OVER (
            PARTITION BY oh.CustomerID 
            ORDER BY oh.SalesOrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ),
    -- (SELECT SUM(od.LineTotal) FROM SalesLT.SalesOrderDetail od ) as GrandTotal
    GrandTotal = SUM(oh.SubTotal) OVER(),
    GrandTotalByCustomer = SUM(oh.SubTotal) OVER(PARTITION BY oh.CustomerID)
FROM Sales.SalesOrderHeader oh
where oh.CustomerID = 29825
order by 1 ASC

-- OVER 3
WITH cVendas
AS (SELECT  YEAR(oh.OrderDate) AS ANO, MONTH(oh.OrderDate) AS MES, SUM(oh.SubTotal) AS Total FROM Sales.SalesOrderHeader oh group by  YEAR(oh.OrderDate) , MONTH(oh.OrderDate))
SELECT *,
    LAG(Acumuado3MesesPassados, 1, NULL) OVER (order by ano, mes)
FROM (
SELECT v.ANO, v.MES, 
    v.Total,
    AcumuadoAno = SUM(v.Total) OVER (
            PARTITION BY v.ano ORDER BY v.mes ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ),
    Acumuado3MesesFuturos = SUM(v.Total) OVER (
            PARTITION BY v.ano ORDER BY v.mes ASC
            ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING ),
    Acumuado3MesesPassados = SUM(v.Total) OVER (
            PARTITION BY v.ano
            ORDER BY v.mes ASC
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW )
FROM cVendas v
) v
order by ano, mes