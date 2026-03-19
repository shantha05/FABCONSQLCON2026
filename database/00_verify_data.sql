-- =====================================================
-- Verification Script - Check Record Counts
-- Run this after loading sample data
-- =====================================================

PRINT 'Checking record counts...';
GO

SELECT 'Dealerships' AS TableName, COUNT(*) AS RecordCount FROM dbo.Dealerships
UNION ALL
SELECT 'Customers', COUNT(*) FROM dbo.Customers
UNION ALL
SELECT 'Vehicles', COUNT(*) FROM dbo.VehicleInventory
UNION ALL
SELECT 'Test Drives', COUNT(*) FROM dbo.TestDrives
UNION ALL
SELECT 'Purchases', COUNT(*) FROM dbo.CustomerPurchases
UNION ALL
SELECT 'Service Records', COUNT(*) FROM dbo.ServiceRecords
UNION ALL
SELECT 'Parts', COUNT(*) FROM dbo.Parts
UNION ALL
SELECT 'Part Usage', COUNT(*) FROM dbo.PartUsage
ORDER BY TableName;
GO

-- Check for any foreign key constraint violations
PRINT '';
PRINT 'Checking for orphaned records...';
GO

-- Check customers with invalid dealership references
SELECT 'Customers with invalid dealership' AS Issue, COUNT(*) AS Count
FROM dbo.Customers c
WHERE NOT EXISTS (SELECT 1 FROM dbo.Dealerships d WHERE d.DealershipID = c.PreferredDealership);

-- Check vehicles with invalid dealership references  
SELECT 'Vehicles with invalid dealership' AS Issue, COUNT(*) AS Count
FROM dbo.VehicleInventory v
WHERE NOT EXISTS (SELECT 1 FROM dbo.Dealerships d WHERE d.DealershipID = v.DealershipID);

-- Check test drives with invalid references
SELECT 'TestDrives with invalid customer' AS Issue, COUNT(*) AS Count
FROM dbo.TestDrives td
WHERE NOT EXISTS (SELECT 1 FROM dbo.Customers c WHERE c.CustomerID = td.CustomerID);

SELECT 'TestDrives with invalid vehicle' AS Issue, COUNT(*) AS Count
FROM dbo.TestDrives td
WHERE NOT EXISTS (SELECT 1 FROM dbo.VehicleInventory v WHERE v.VehicleID = td.VehicleID);

SELECT 'TestDrives with invalid dealership' AS Issue, COUNT(*) AS Count
FROM dbo.TestDrives td
WHERE NOT EXISTS (SELECT 1 FROM dbo.Dealerships d WHERE d.DealershipID = td.DealershipID);
GO

PRINT '';
PRINT 'Sample data from each table:';
GO

SELECT TOP 3 * FROM dbo.Dealerships ORDER BY DealershipID;
SELECT TOP 3 * FROM dbo.Customers ORDER BY CustomerID;
SELECT TOP 3 * FROM dbo.VehicleInventory ORDER BY VehicleID;
SELECT TOP 3 * FROM dbo.Parts ORDER BY PartID;
GO
