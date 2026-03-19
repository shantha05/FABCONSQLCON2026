-- =====================================================
-- Analytics and Reporting Views
-- For Microsoft Fabric SQL Database Integration
-- =====================================================

-- =====================================================
-- Real-Time Sales Dashboard View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_SalesDashboard AS
SELECT 
    d.Region,
    d.Country,
    d.DealershipName,
    COUNT(DISTINCT cp.PurchaseID) AS TotalSales,
    SUM(cp.SalePrice) AS TotalRevenue,
    AVG(cp.SalePrice) AS AvgSalePrice,
    COUNT(DISTINCT cp.CustomerID) AS UniqueCustomers,
    DATEPART(YEAR, cp.PurchaseDate) AS SaleYear,
    DATEPART(MONTH, cp.PurchaseDate) AS SaleMonth,
    FORMAT(cp.PurchaseDate, 'yyyy-MM') AS YearMonth
FROM dbo.CustomerPurchases cp
INNER JOIN dbo.Dealerships d ON cp.DealershipID = d.DealershipID
GROUP BY 
    d.Region, 
    d.Country, 
    d.DealershipName,
    DATEPART(YEAR, cp.PurchaseDate),
    DATEPART(MONTH, cp.PurchaseDate),
    FORMAT(cp.PurchaseDate, 'yyyy-MM');
GO

-- =====================================================
-- Inventory Overview View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_InventoryOverview AS
SELECT 
    d.Region,
    d.DealershipName,
    v.Status,
    v.Make,
    v.Model,
    v.FuelType,
    COUNT(*) AS VehicleCount,
    AVG(v.Price) AS AvgPrice,
    MIN(v.Price) AS MinPrice,
    MAX(v.Price) AS MaxPrice,
    SUM(CASE WHEN v.Status = 'Available' THEN 1 ELSE 0 END) AS AvailableCount,
    SUM(CASE WHEN v.Status = 'Sold' THEN 1 ELSE 0 END) AS SoldCount,
    SUM(CASE WHEN v.Status = 'Reserved' THEN 1 ELSE 0 END) AS ReservedCount
FROM dbo.VehicleInventory v
INNER JOIN dbo.Dealerships d ON v.DealershipID = d.DealershipID
GROUP BY 
    d.Region,
    d.DealershipName,
    v.Status,
    v.Make,
    v.Model,
    v.FuelType;
GO

-- =====================================================
-- Service Revenue Analytics View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_ServiceAnalytics AS
SELECT 
    d.Region,
    d.DealershipName,
    sr.ServiceType,
    COUNT(*) AS ServiceCount,
    SUM(sr.TotalCost) AS TotalRevenue,
    AVG(sr.TotalCost) AS AvgServiceCost,
    SUM(sr.LaborCost) AS TotalLaborRevenue,
    SUM(sr.PartsCost) AS TotalPartsRevenue,
    DATEPART(YEAR, sr.ServiceDate) AS ServiceYear,
    DATEPART(MONTH, sr.ServiceDate) AS ServiceMonth,
    FORMAT(sr.ServiceDate, 'yyyy-MM') AS YearMonth
FROM dbo.ServiceRecords sr
INNER JOIN dbo.Dealerships d ON sr.DealershipID = d.DealershipID
WHERE sr.Status = 'Completed'
GROUP BY 
    d.Region,
    d.DealershipName,
    sr.ServiceType,
    DATEPART(YEAR, sr.ServiceDate),
    DATEPART(MONTH, sr.ServiceDate),
    FORMAT(sr.ServiceDate, 'yyyy-MM');
GO

-- =====================================================
-- Customer Engagement View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_CustomerEngagement AS
SELECT 
    c.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Email,
    c.Country,
    c.LoyaltyPoints,
    d.DealershipName AS PreferredDealership,
    COUNT(DISTINCT td.TestDriveID) AS TotalTestDrives,
    COUNT(DISTINCT cp.PurchaseID) AS TotalPurchases,
    COUNT(DISTINCT sr.ServiceID) AS TotalServiceVisits,
    SUM(cp.SalePrice) AS LifetimeValue,
    MAX(cp.PurchaseDate) AS LastPurchaseDate,
    MAX(sr.ServiceDate) AS LastServiceDate
FROM dbo.Customers c
LEFT JOIN dbo.Dealerships d ON c.PreferredDealership = d.DealershipID
LEFT JOIN dbo.TestDrives td ON c.CustomerID = td.CustomerID
LEFT JOIN dbo.CustomerPurchases cp ON c.CustomerID = cp.CustomerID
LEFT JOIN dbo.ServiceRecords sr ON c.CustomerID = sr.CustomerID
GROUP BY 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Country,
    c.LoyaltyPoints,
    d.DealershipName;
GO

-- =====================================================
-- Test Drive Conversion Analysis View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_TestDriveConversion AS
SELECT 
    d.Region,
    d.DealershipName,
    v.Make,
    v.Model,
    COUNT(*) AS TotalTestDrives,
    SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) AS ConvertedSales,
    CAST(SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ConversionRate,
    AVG(CAST(td.CustomerRating AS FLOAT)) AS AvgRating,
    AVG(td.Duration) AS AvgDurationMinutes
FROM dbo.TestDrives td
INNER JOIN dbo.Dealerships d ON td.DealershipID = d.DealershipID
INNER JOIN dbo.VehicleInventory v ON td.VehicleID = v.VehicleID
GROUP BY 
    d.Region,
    d.DealershipName,
    v.Make,
    v.Model;
GO

-- =====================================================
-- Parts Inventory Management View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_PartsInventory AS
SELECT 
    p.PartID,
    p.PartNumber,
    p.PartName,
    p.Category,
    p.UnitPrice,
    p.StockQuantity,
    p.ReorderLevel,
    CASE 
        WHEN p.StockQuantity <= p.ReorderLevel THEN 'Reorder Needed'
        WHEN p.StockQuantity <= p.ReorderLevel * 1.5 THEN 'Low Stock'
        ELSE 'In Stock'
    END AS StockStatus,
    COUNT(pu.PartUsageID) AS UsageCount,
    SUM(pu.Quantity) AS TotalQuantityUsed,
    SUM(pu.TotalPrice) AS TotalRevenue
FROM dbo.Parts p
LEFT JOIN dbo.PartUsage pu ON p.PartID = pu.PartID
GROUP BY 
    p.PartID,
    p.PartNumber,
    p.PartName,
    p.Category,
    p.UnitPrice,
    p.StockQuantity,
    p.ReorderLevel;
GO

-- =====================================================
-- Regional Performance Summary View
-- =====================================================
CREATE OR ALTER VIEW dbo.vw_RegionalPerformance AS
SELECT 
    d.Region,
    COUNT(DISTINCT d.DealershipID) AS TotalDealerships,
    COUNT(DISTINCT v.VehicleID) AS TotalInventory,
    SUM(CASE WHEN v.Status = 'Available' THEN 1 ELSE 0 END) AS AvailableVehicles,
    COUNT(DISTINCT cp.PurchaseID) AS TotalSales,
    SUM(cp.SalePrice) AS TotalSalesRevenue,
    COUNT(DISTINCT sr.ServiceID) AS TotalServices,
    SUM(sr.TotalCost) AS TotalServiceRevenue,
    (SUM(cp.SalePrice) + SUM(sr.TotalCost)) AS TotalRevenue,
    COUNT(DISTINCT c.CustomerID) AS TotalCustomers
FROM dbo.Dealerships d
LEFT JOIN dbo.VehicleInventory v ON d.DealershipID = v.DealershipID
LEFT JOIN dbo.CustomerPurchases cp ON d.DealershipID = cp.DealershipID
LEFT JOIN dbo.ServiceRecords sr ON d.DealershipID = sr.DealershipID AND sr.Status = 'Completed'
LEFT JOIN dbo.Customers c ON d.DealershipID = c.PreferredDealership
GROUP BY d.Region;
GO

-- =====================================================
-- Sample Analytics Queries
-- =====================================================

-- Query 1: Top Performing Dealerships by Revenue (Last 30 Days)
-- Use this to identify best performers
/*
SELECT TOP 10
    DealershipName,
    Region,
    TotalRevenue,
    TotalSales,
    AvgSalePrice
FROM dbo.vw_SalesDashboard
WHERE YearMonth = FORMAT(GETDATE(), 'yyyy-MM')
ORDER BY TotalRevenue DESC;
*/

-- Query 2: Inventory Alert - Vehicles by Status
-- Use this for inventory optimization
/*
SELECT 
    Region,
    Status,
    FuelType,
    VehicleCount,
    AvgPrice
FROM dbo.vw_InventoryOverview
WHERE Status IN ('Available', 'Reserved')
ORDER BY Region, VehicleCount DESC;
*/

-- Query 3: High-Value Customers
-- Use this for targeted marketing
/*
SELECT TOP 20
    CustomerName,
    Country,
    LoyaltyPoints,
    TotalPurchases,
    LifetimeValue,
    LastPurchaseDate
FROM dbo.vw_CustomerEngagement
WHERE TotalPurchases > 0
ORDER BY LifetimeValue DESC;
*/

-- Query 4: Service Revenue Trends
-- Use this for service department performance
/*
SELECT 
    Region,
    ServiceType,
    ServiceCount,
    TotalRevenue,
    AvgServiceCost
FROM dbo.vw_ServiceAnalytics
WHERE ServiceYear = YEAR(GETDATE())
ORDER BY TotalRevenue DESC;
*/

-- Query 5: Parts Reorder Alert
-- Use this for inventory management
/*
SELECT 
    PartNumber,
    PartName,
    Category,
    StockQuantity,
    ReorderLevel,
    StockStatus
FROM dbo.vw_PartsInventory
WHERE StockStatus IN ('Reorder Needed', 'Low Stock')
ORDER BY StockStatus, StockQuantity;
*/

PRINT 'Analytics views created successfully!';
GO
