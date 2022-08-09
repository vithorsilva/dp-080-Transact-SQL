-- PIVOT 1
SELECT pvt.CustomerID, pvt.ANO, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]
FROM (
    SELECT  
        YEAR(oh.OrderDate) AS ANO, 
        MONTH(oh.OrderDate) AS MES, 
        oh.CustomerID,
        SUM(oh.SubTotal) AS Total 
        FROM Sales.SalesOrderHeader oh 
    group by  YEAR(oh.OrderDate), MONTH(oh.OrderDate), oh.CustomerID
) as s
PIVOT (SUM(s.Total) FOR MES IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as pvt
order by 1 

-- PIVOT 2
SELECT pvt.*
FROM (
    SELECT  
        FORMAT(oh.OrderDate, 'yyyy-MM') YearMonth, 
        oh.CustomerID,
        SUM(oh.SubTotal) AS Total 
        FROM Sales.SalesOrderHeader oh 
    group by  FORMAT(oh.OrderDate, 'yyyy-MM'), oh.CustomerID
) as s
PIVOT (SUM(s.Total) FOR YearMonth IN (
    [2011-05], [2011-06], [2011-07], [2011-08], [2011-09], [2011-10], [2011-11], [2011-12], 
    [2012-01], [2012-02], [2012-03], [2012-04], [2012-05], [2012-06], [2012-07], [2012-08], [2012-09], [2012-10], [2012-11], [2012-12], 
    [2013-01], [2013-02], [2013-03], [2013-04], [2013-05], [2013-06], [2013-07], [2013-08], [2013-09], [2013-10], [2013-11], [2013-12], 
    [2014-01], [2014-02], [2014-03], [2014-04], [2014-05], [2014-06], [2014-07], [2014-08], [2014-09], [2014-10], [2014-11], [2014-12],
    [2022-09])
) as pvt
order by 1 

SELECT oh.SalesOrderID, oh.CustomerID, SubTotal, TaxAmt, Freight, TotalDue
FROM Sales.SalesOrderHeader oh 

SELECT upvt.CustomerID, upvt.SalesOrderID, upvt.Descricao, upvt.Total
FROM (
    SELECT oh.SalesOrderID, oh.CustomerID, SubTotal, TaxAmt, Freight, TotalDue
    FROM Sales.SalesOrderHeader oh 
) p
UNPIVOT (Total FOR Descricao IN (SubTotal, TaxAmt, Freight, TotalDue)) as upvt