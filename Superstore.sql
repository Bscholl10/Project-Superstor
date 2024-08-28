/* General view
*/
SELECT * FROM dbo.Superstore;


/*FINDING THE TOP SELLING PRODUCTS IN SUPERSTORE
*/


/* Finding top selling categorys 
*/ 
SELECT Category, SUM(Sales) AS 'Total Sales' 
FROM dbo.Superstore
GROUP BY Category
ORDER BY 'Total Sales' DESC;


/* Finding top selling sub categorys, in correlation with its
main category.  
*/ 
SELECT Category, Sub_Category, SUM(Sales) AS 'Total Sales'
FROM dbo.Superstore
GROUP BY Category, Sub_Category
ORDER BY Category, 'Total Sales' DESC;


/* Finding top selling products (no top 30 filter)
*/ 
SELECT Category, Sub_Category, Product_Name, 
SUM(Sales) AS 'Total Sales'
FROM dbo.Superstore
GROUP BY Category, Sub_Category, Product_Name
ORDER BY 'Total Sales' DESC;


/* reports the top 30 product names sold and their toal sales
*/
SELECT TOP 30 Product_Name, 
SUM(Sales) AS 'Total Sales'
FROM dbo.Superstore
GROUP BY Product_Name
ORDER BY 'Total Sales' DESC;


/* ANALYZING SALES TRENDS OVER TIME 
*/


/* Monthly Sales Trends over time
*/
SELECT 
CONCAT(YEAR(Order_Date), '-', 
RIGHT('0' + CAST(MONTH(Order_Date) 
AS VARCHAR(2)), 2)) AS Month,
SUM(Sales) AS Total_Sales
FROM dbo.Superstore
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Month;


/* Yearly Sales Trends
*/
SELECT 
YEAR(Order_Date) AS Year,
SUM(Sales) AS Total_Sales
FROM dbo.Superstore
GROUP BY YEAR(Order_Date)
ORDER BY Year;


/* IDENTIFYING THE MOST PROFITABLE CUSTOMER SEGMENTS 
*/
SELECT Segment, SUM(Profit) AS 'Total Profit'
FROM dbo.Superstore
GROUP BY Segment
ORDER BY 'Total Profit' DESC;


/* CALCULATING THE AVERAGE ORDER VALUE BY REGION
*/
SELECT Region, AVG(Sales) AS 'Average Order Value'
FROM dbo.Superstore
GROUP BY Region;


/* FINDING THE TOP # OF CUSTOMERS BY SALES
*/
SELECT TOP 10 Customer_Name, 
SUM(Sales) AS 'Total Sales'
FROM dbo.Superstore
GROUP BY Customer_Name
ORDER BY 'Total Sales' DESC;


/* CALCULATING NUMBER OF ORDERS BY PRODUCT CATEGORY
*/
SELECT Category, COUNT(ORDER_ID) AS 'Number of Orders'
FROM Superstore
GROUP BY Category
ORDER BY 'Number of Orders' DESC;


/* ANALYZING DISCOUNT IMPACT ON PRODUCTS
*/
SELECT Discount, SUM(Profit) AS 'Total Profit'
FROM dbo.Superstore
GROUP BY Discount
ORDER BY Discount;


/* CALCULATING PROFIT MARGIN FOR EACH CATEGORY
*/
SELECT Category, SUM(Profit)/SUM(Sales) AS 'Profit Margin'
FROM dbo.Superstore
GROUP BY Category
ORDER BY 'Profit Margin' DESC;

/* IDENTIFYING MOST PURCHASED PRODUCTS
*/
SELECT TOP 15 Product_Name, COUNT(Order_ID) AS 'Number of Purchases'
FROM dbo.Superstore
GROUP BY Product_Name
ORDER BY 'Number of Purchases' DESC;


/* 
This query calculates the Customer Lifetime Value by summing the total sales and profit for 
each customer, considering their purchase frequency and average order value.
*/
WITH CustomerOrders AS (
    SELECT 
    Customer_ID, 
    Customer_Name, 
    COUNT(Order_ID) AS Order_Count, 
    SUM(Sales) AS Total_Sales, 
    SUM(Profit) AS Total_Profit
FROM 
    dbo.Superstore
GROUP BY 
    Customer_ID, 
    Customer_Name
),
CustomerLifetimeValue AS(
SELECT
    Customer_ID,
    Customer_Name,
    Total_Sales,
    Total_Profit,
    Order_Count, 
    (Total_Sales / Order_Count) AS Avg_Order_Value,
    (Total_Profit / Order_Count) AS Avg_Order_Profit
FROM
CustomerOrders
)
SELECT TOP 10
    Customer_ID,
    Customer_Name,
    Total_Sales,
    Total_Profit, 
    Order_Count,
    Avg_Order_Value,
    Avg_Order_Profit,
    Total_Sales * Order_Count AS Lifetime_Value
FROM 
    CustomerLifetimeValue
ORDER BY 
    Lifetime_Value DESC;


/* This Query identifies product pairs that are frequently bought together.
A simple version of market basket analysis
*/
WITH ProductPairs AS (
    SELECT
        A.Order_ID,
        A.Product_ID AS 'Product_A',
        B.Product_ID AS 'Product_B'
    FROM
        dbo.Superstore A
    JOIN
        dbo.Superstore B ON A.Order_ID = B.Order_ID AND A.Product_ID < B.Product_ID
)
SELECT TOP 60
    Product_A,
    Product_B,
    COUNT(*) AS Pair_Count
FROM
    ProductPairs
GROUP BY
    Product_A,
    Product_B
ORDER BY Pair_Count DESC
