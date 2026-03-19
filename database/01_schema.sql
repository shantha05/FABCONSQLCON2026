-- =====================================================
-- Fabric SQL Database Schema for Car Dealership Network
-- Operational and Analytical Tables
-- =====================================================

-- Drop existing tables if they exist
IF OBJECT_ID('dbo.PartUsage', 'U') IS NOT NULL DROP TABLE dbo.PartUsage;
IF OBJECT_ID('dbo.ServiceRecords', 'U') IS NOT NULL DROP TABLE dbo.ServiceRecords;
IF OBJECT_ID('dbo.CustomerPurchases', 'U') IS NOT NULL DROP TABLE dbo.CustomerPurchases;
IF OBJECT_ID('dbo.TestDrives', 'U') IS NOT NULL DROP TABLE dbo.TestDrives;
IF OBJECT_ID('dbo.VehicleInventory', 'U') IS NOT NULL DROP TABLE dbo.VehicleInventory;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Parts', 'U') IS NOT NULL DROP TABLE dbo.Parts;
IF OBJECT_ID('dbo.Dealerships', 'U') IS NOT NULL DROP TABLE dbo.Dealerships;
GO

-- =====================================================
-- Dealerships Table
-- =====================================================
CREATE TABLE dbo.Dealerships (
    DealershipID INT PRIMARY KEY IDENTITY(1,1),
    DealershipName NVARCHAR(100) NOT NULL,
    Region NVARCHAR(50) NOT NULL, -- USA, Europe, Asia, Australia
    Country NVARCHAR(50) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT CK_Region CHECK (Region IN ('USA', 'Europe', 'Asia', 'Australia'))
);
GO

-- =====================================================
-- Customers Table
-- =====================================================
CREATE TABLE dbo.Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    City NVARCHAR(100),
    Country NVARCHAR(50),
    PreferredDealership INT,
    RegistrationDate DATETIME2 DEFAULT GETDATE(),
    LoyaltyPoints INT DEFAULT 0,
    FOREIGN KEY (PreferredDealership) REFERENCES dbo.Dealerships(DealershipID)
);
GO

-- =====================================================
-- Vehicle Inventory Table
-- =====================================================
CREATE TABLE dbo.VehicleInventory (
    VehicleID INT PRIMARY KEY IDENTITY(1,1),
    DealershipID INT NOT NULL,
    VIN NVARCHAR(17) NOT NULL UNIQUE,
    Make NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    Color NVARCHAR(30),
    Price DECIMAL(12, 2) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Available', -- Available, Sold, Reserved, InService
    Mileage INT DEFAULT 0,
    FuelType NVARCHAR(20), -- Petrol, Diesel, Electric, Hybrid
    Transmission NVARCHAR(20), -- Automatic, Manual
    Features NVARCHAR(500),
    DateAdded DATETIME2 DEFAULT GETDATE(),
    LastUpdated DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (DealershipID) REFERENCES dbo.Dealerships(DealershipID),
    CONSTRAINT CK_Status CHECK (Status IN ('Available', 'Sold', 'Reserved', 'InService')),
    CONSTRAINT CK_FuelType CHECK (FuelType IN ('Petrol', 'Diesel', 'Electric', 'Hybrid'))
);
GO

-- =====================================================
-- Test Drives Table
-- =====================================================
CREATE TABLE dbo.TestDrives (
    TestDriveID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    VehicleID INT NOT NULL,
    DealershipID INT NOT NULL,
    TestDriveDate DATETIME2 NOT NULL,
    Duration INT, -- In minutes
    CustomerRating INT, -- 1-5 stars
    CustomerFeedback NVARCHAR(500),
    SalesRepName NVARCHAR(100),
    ConvertedToSale BIT DEFAULT 0,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    FOREIGN KEY (VehicleID) REFERENCES dbo.VehicleInventory(VehicleID),
    FOREIGN KEY (DealershipID) REFERENCES dbo.Dealerships(DealershipID),
    CONSTRAINT CK_Rating CHECK (CustomerRating BETWEEN 1 AND 5)
);
GO

-- =====================================================
-- Customer Purchases Table
-- =====================================================
CREATE TABLE dbo.CustomerPurchases (
    PurchaseID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    VehicleID INT NOT NULL,
    DealershipID INT NOT NULL,
    PurchaseDate DATETIME2 DEFAULT GETDATE(),
    SalePrice DECIMAL(12, 2) NOT NULL,
    FinanceType NVARCHAR(30), -- Cash, Loan, Lease
    DownPayment DECIMAL(12, 2),
    MonthlyPayment DECIMAL(12, 2),
    LoanTerm INT, -- In months
    TradeInValue DECIMAL(12, 2) DEFAULT 0,
    SalesRepName NVARCHAR(100),
    WarrantyPurchased BIT DEFAULT 0,
    ExtendedWarrantyYears INT,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    FOREIGN KEY (VehicleID) REFERENCES dbo.VehicleInventory(VehicleID),
    FOREIGN KEY (DealershipID) REFERENCES dbo.Dealerships(DealershipID)
);
GO

-- =====================================================
-- Service Records Table
-- =====================================================
CREATE TABLE dbo.ServiceRecords (
    ServiceID INT PRIMARY KEY IDENTITY(1,1),
    VehicleID INT NOT NULL,
    CustomerID INT NOT NULL,
    DealershipID INT NOT NULL,
    ServiceDate DATETIME2 DEFAULT GETDATE(),
    ServiceType NVARCHAR(50) NOT NULL, -- Oil Change, Tire Rotation, Inspection, Repair, etc.
    Description NVARCHAR(500),
    Mileage INT,
    LaborCost DECIMAL(10, 2),
    PartsCost DECIMAL(10, 2),
    TotalCost AS (LaborCost + PartsCost) PERSISTED,
    TechnicianName NVARCHAR(100),
    Status NVARCHAR(20) DEFAULT 'Completed', -- Scheduled, InProgress, Completed
    NextServiceDue DATETIME2,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (VehicleID) REFERENCES dbo.VehicleInventory(VehicleID),
    FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    FOREIGN KEY (DealershipID) REFERENCES dbo.Dealerships(DealershipID)
);
GO

-- =====================================================
-- Parts Table
-- =====================================================
CREATE TABLE dbo.Parts (
    PartID INT PRIMARY KEY IDENTITY(1,1),
    PartNumber NVARCHAR(50) NOT NULL UNIQUE,
    PartName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50), -- Engine, Transmission, Brakes, Electrical, etc.
    UnitPrice DECIMAL(10, 2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    ReorderLevel INT DEFAULT 10,
    Supplier NVARCHAR(100),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);
GO

-- =====================================================
-- Part Usage Table
-- =====================================================
CREATE TABLE dbo.PartUsage (
    PartUsageID INT PRIMARY KEY IDENTITY(1,1),
    ServiceID INT NOT NULL,
    PartID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    TotalPrice AS (Quantity * UnitPrice) PERSISTED,
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ServiceID) REFERENCES dbo.ServiceRecords(ServiceID),
    FOREIGN KEY (PartID) REFERENCES dbo.Parts(PartID)
);
GO

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Vehicle Inventory Indexes
CREATE INDEX IX_VehicleInventory_Dealership ON dbo.VehicleInventory(DealershipID);
CREATE INDEX IX_VehicleInventory_Status ON dbo.VehicleInventory(Status);
CREATE INDEX IX_VehicleInventory_MakeModel ON dbo.VehicleInventory(Make, Model);

-- Customer Indexes
CREATE INDEX IX_Customers_Email ON dbo.Customers(Email);
CREATE INDEX IX_Customers_Dealership ON dbo.Customers(PreferredDealership);

-- Test Drives Indexes
CREATE INDEX IX_TestDrives_Customer ON dbo.TestDrives(CustomerID);
CREATE INDEX IX_TestDrives_Date ON dbo.TestDrives(TestDriveDate);
CREATE INDEX IX_TestDrives_Dealership ON dbo.TestDrives(DealershipID);

-- Purchases Indexes
CREATE INDEX IX_Purchases_Customer ON dbo.CustomerPurchases(CustomerID);
CREATE INDEX IX_Purchases_Date ON dbo.CustomerPurchases(PurchaseDate);
CREATE INDEX IX_Purchases_Dealership ON dbo.CustomerPurchases(DealershipID);

-- Service Records Indexes
CREATE INDEX IX_ServiceRecords_Vehicle ON dbo.ServiceRecords(VehicleID);
CREATE INDEX IX_ServiceRecords_Customer ON dbo.ServiceRecords(CustomerID);
CREATE INDEX IX_ServiceRecords_Date ON dbo.ServiceRecords(ServiceDate);
CREATE INDEX IX_ServiceRecords_Dealership ON dbo.ServiceRecords(DealershipID);

-- Part Usage Indexes
CREATE INDEX IX_PartUsage_Service ON dbo.PartUsage(ServiceID);
CREATE INDEX IX_PartUsage_Part ON dbo.PartUsage(PartID);

PRINT 'Database schema created successfully!';
GO
