-- =====================================================
-- Performance Indexes for Car Dealership Database
-- Microsoft Fabric SQL Database
-- =====================================================

PRINT 'Creating performance indexes...';
GO

-- =====================================================
-- CustomerPurchases Indexes
-- =====================================================

-- Index for date range queries (sales by date)
CREATE NONCLUSTERED INDEX IX_CustomerPurchases_PurchaseDate 
ON dbo.CustomerPurchases(PurchaseDate DESC)
INCLUDE (DealershipID, SalePrice, CustomerID);
GO

-- Index for dealership queries
CREATE NONCLUSTERED INDEX IX_CustomerPurchases_Dealership 
ON dbo.CustomerPurchases(DealershipID)
INCLUDE (PurchaseDate, SalePrice, CustomerID);
GO

-- Index for customer lookup
CREATE NONCLUSTERED INDEX IX_CustomerPurchases_Customer 
ON dbo.CustomerPurchases(CustomerID)
INCLUDE (PurchaseDate, SalePrice, DealershipID);
GO

-- =====================================================
-- VehicleInventory Indexes
-- =====================================================

-- Index for status and dealership queries (most common)
CREATE NONCLUSTERED INDEX IX_VehicleInventory_Status_Dealership 
ON dbo.VehicleInventory(Status, DealershipID)
INCLUDE (Make, Model, Year, Price, FuelType);
GO

-- Index for dealership inventory queries
CREATE NONCLUSTERED INDEX IX_VehicleInventory_Dealership 
ON dbo.VehicleInventory(DealershipID)
INCLUDE (Status, Make, Model, Price);
GO

-- Index for make/model searches
CREATE NONCLUSTERED INDEX IX_VehicleInventory_Make_Model 
ON dbo.VehicleInventory(Make, Model)
INCLUDE (Status, DealershipID, Price, Year);
GO

-- =====================================================
-- ServiceRecords Indexes
-- =====================================================

-- Index for date and status queries
CREATE NONCLUSTERED INDEX IX_ServiceRecords_Date_Status 
ON dbo.ServiceRecords(ServiceDate DESC, Status)
INCLUDE (DealershipID, ServiceType, TotalCost);
GO

-- Index for dealership queries
CREATE NONCLUSTERED INDEX IX_ServiceRecords_Dealership 
ON dbo.ServiceRecords(DealershipID)
INCLUDE (ServiceDate, Status, ServiceType, TotalCost);
GO

-- Index for customer service history
CREATE NONCLUSTERED INDEX IX_ServiceRecords_Customer 
ON dbo.ServiceRecords(CustomerID)
INCLUDE (ServiceDate, Status, TotalCost, VehicleID);
GO

-- Index for vehicle service history
CREATE NONCLUSTERED INDEX IX_ServiceRecords_Vehicle 
ON dbo.ServiceRecords(VehicleID)
INCLUDE (ServiceDate, Status, CustomerID, TotalCost);
GO

-- =====================================================
-- TestDrives Indexes
-- =====================================================

-- Index for date queries
CREATE NONCLUSTERED INDEX IX_TestDrives_Date 
ON dbo.TestDrives(TestDriveDate DESC)
INCLUDE (DealershipID, VehicleID, CustomerID, ConvertedToSale);
GO

-- Index for dealership queries
CREATE NONCLUSTERED INDEX IX_TestDrives_Dealership 
ON dbo.TestDrives(DealershipID)
INCLUDE (TestDriveDate, VehicleID, ConvertedToSale, CustomerRating);
GO

-- Index for vehicle popularity analysis
CREATE NONCLUSTERED INDEX IX_TestDrives_Vehicle 
ON dbo.TestDrives(VehicleID)
INCLUDE (TestDriveDate, ConvertedToSale, CustomerRating);
GO

-- Index for customer activity
CREATE NONCLUSTERED INDEX IX_TestDrives_Customer 
ON dbo.TestDrives(CustomerID)
INCLUDE (TestDriveDate, VehicleID, ConvertedToSale);
GO

-- =====================================================
-- Customers Indexes
-- =====================================================

-- Index for dealership customer queries
CREATE NONCLUSTERED INDEX IX_Customers_PreferredDealership 
ON dbo.Customers(PreferredDealership)
INCLUDE (FirstName, LastName, Email, Country, LoyaltyPoints);
GO

-- Index for country/region analysis
CREATE NONCLUSTERED INDEX IX_Customers_Country 
ON dbo.Customers(Country)
INCLUDE (PreferredDealership, LoyaltyPoints);
GO

-- Index for email lookup (unique searches)
CREATE NONCLUSTERED INDEX IX_Customers_Email 
ON dbo.Customers(Email)
INCLUDE (CustomerID, FirstName, LastName);
GO

-- =====================================================
-- PartUsage Indexes
-- =====================================================

-- Index for service parts lookup
CREATE NONCLUSTERED INDEX IX_PartUsage_Service 
ON dbo.PartUsage(ServiceID)
INCLUDE (PartID, Quantity, TotalPrice);
GO

-- Index for part usage statistics
CREATE NONCLUSTERED INDEX IX_PartUsage_Part 
ON dbo.PartUsage(PartID)
INCLUDE (ServiceID, Quantity, TotalPrice);
GO

-- =====================================================
-- Parts Indexes
-- =====================================================

-- Index for category queries
CREATE NONCLUSTERED INDEX IX_Parts_Category 
ON dbo.Parts(Category)
INCLUDE (PartNumber, PartName, UnitPrice, StockQuantity);
GO

-- Index for stock level queries
CREATE NONCLUSTERED INDEX IX_Parts_StockLevel 
ON dbo.Parts(StockQuantity, ReorderLevel)
INCLUDE (PartNumber, PartName, Category);
GO

-- Index for part number lookup
CREATE NONCLUSTERED INDEX IX_Parts_PartNumber 
ON dbo.Parts(PartNumber)
INCLUDE (PartName, Category, UnitPrice, StockQuantity);
GO

-- =====================================================
-- Dealerships Indexes
-- =====================================================

-- Index for region queries
CREATE NONCLUSTERED INDEX IX_Dealerships_Region 
ON dbo.Dealerships(Region)
INCLUDE (Country, DealershipName, City);
GO

-- Index for country queries
CREATE NONCLUSTERED INDEX IX_Dealerships_Country 
ON dbo.Dealerships(Country)
INCLUDE (Region, DealershipName, City);
GO

-- =====================================================
-- Statistics Update
-- =====================================================

-- Update statistics for better query optimization
PRINT 'Updating statistics...';
GO

UPDATE STATISTICS dbo.CustomerPurchases WITH FULLSCAN;
UPDATE STATISTICS dbo.VehicleInventory WITH FULLSCAN;
UPDATE STATISTICS dbo.ServiceRecords WITH FULLSCAN;
UPDATE STATISTICS dbo.TestDrives WITH FULLSCAN;
UPDATE STATISTICS dbo.Customers WITH FULLSCAN;
UPDATE STATISTICS dbo.PartUsage WITH FULLSCAN;
UPDATE STATISTICS dbo.Parts WITH FULLSCAN;
UPDATE STATISTICS dbo.Dealerships WITH FULLSCAN;
GO

PRINT 'Performance indexes created successfully!';
PRINT 'Database is now optimized for query performance.';
GO
