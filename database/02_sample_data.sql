-- =====================================================
-- Large Dataset for Car Dealership Network Demo
-- Microsoft Fabric SQL Database
-- =====================================================

SET NOCOUNT ON;
GO

-- =====================================================
-- Insert Dealerships (20 locations - Optimized)
-- =====================================================
INSERT INTO dbo.Dealerships (DealershipName, Region, Country, City, Address, Phone, Email)
VALUES 
    -- USA Dealerships (5)
    ('Premium Motors NYC', 'USA', 'United States', 'New York', '123 Broadway Ave', '+1-212-555-0100', 'info@premiummotorsnyc.com'),
    ('Sunshine Auto LA', 'USA', 'United States', 'Los Angeles', '456 Sunset Blvd', '+1-310-555-0200', 'contact@sunshineautola.com'),
    ('Chicago Elite Motors', 'USA', 'United States', 'Chicago', '100 Michigan Ave', '+1-312-555-0400', 'info@chicagoelite.com'),
    ('Miami Luxury Cars', 'USA', 'United States', 'Miami', '200 Ocean Drive', '+1-305-555-0500', 'sales@miamiluxury.com'),
    ('Seattle Auto Gallery', 'USA', 'United States', 'Seattle', '300 Pike Place', '+1-206-555-0600', 'info@seattleautogallery.com'),
    -- Europe Dealerships (5)
    ('Euro Motors Berlin', 'Europe', 'Germany', 'Berlin', 'Unter den Linden 45', '+49-30-555-0100', 'info@euromotorsberlin.de'),
    ('Paris Auto Elite', 'Europe', 'France', 'Paris', '12 Champs-Élysées', '+33-1-555-0200', 'contact@parisautoelite.fr'),
    ('London Premium Cars', 'Europe', 'United Kingdom', 'London', '78 Piccadilly', '+44-20-555-0300', 'sales@londonpremium.co.uk'),
    ('Munich Bavarian Motors', 'Europe', 'Germany', 'Munich', 'Maximilianstrasse 12', '+49-89-555-0400', 'info@munichbavarian.de'),
    ('Rome Italian Auto', 'Europe', 'Italy', 'Rome', 'Via Veneto 23', '+39-06-555-0500', 'contact@romeitalian.it'),
    -- Asia Dealerships (5)
    ('Tokyo Auto Gallery', 'Asia', 'Japan', 'Tokyo', '5-2-1 Ginza', '+81-3-555-0100', 'info@tokyoautogallery.jp'),
    ('Shanghai Motors', 'Asia', 'China', 'Shanghai', '88 Nanjing Road', '+86-21-555-0200', 'contact@shanghaimotors.cn'),
    ('Singapore Asian Auto', 'Asia', 'Singapore', 'Singapore', '123 Orchard Road', '+65-6555-0300', 'sales@singaporeauto.sg'),
    ('Seoul Korean Motors', 'Asia', 'South Korea', 'Seoul', '45 Gangnam-daero', '+82-2-555-0400', 'info@seoulkorean.kr'),
    ('Mumbai Indian Motors', 'Asia', 'India', 'Mumbai', '45 Marine Drive', '+91-22-555-0800', 'contact@mumbaimotors.in'),
    -- Australia Dealerships (5)
    ('Sydney Auto Hub', 'Australia', 'Australia', 'Sydney', '100 Harbour St', '+61-2-555-0100', 'info@sydneyautohub.com.au'),
    ('Melbourne Elite Cars', 'Australia', 'Australia', 'Melbourne', '50 Collins St', '+61-3-555-0200', 'sales@melbourneelite.com.au'),
    ('Brisbane Sunshine Motors', 'Australia', 'Australia', 'Brisbane', '200 Queen St', '+61-7-555-0300', 'contact@brisbaneauto.com.au'),
    ('Perth Coastal Auto', 'Australia', 'Australia', 'Perth', '300 St Georges Terrace', '+61-8-555-0400', 'info@perthcoastal.com.au'),
    ('Adelaide Southern Cars', 'Australia', 'Australia', 'Adelaide', '400 King William St', '+61-8-555-0500', 'sales@adelaideauto.com.au');
GO

-- =====================================================
-- Insert Customers (100 customers - Optimized)
-- =====================================================
DECLARE @i INT = 1;
DECLARE @FirstNames TABLE (Name NVARCHAR(50));
DECLARE @LastNames TABLE (Name NVARCHAR(50));
DECLARE @Cities TABLE (City NVARCHAR(100), Country NVARCHAR(100), DealershipID INT);

INSERT INTO @FirstNames VALUES 
('James'),('John'),('Robert'),('Michael'),('William'),('David'),('Richard'),('Joseph'),('Thomas'),('Charles'),
('Mary'),('Patricia'),('Jennifer'),('Linda'),('Elizabeth'),('Barbara'),('Susan'),('Jessica'),('Sarah'),('Karen'),
('Daniel'),('Matthew'),('Anthony'),('Mark'),('Donald'),('Steven'),('Paul'),('Andrew'),('Joshua'),('Kenneth'),
('Emily'),('Ashley'),('Michelle'),('Amanda'),('Melissa'),('Deborah'),('Stephanie'),('Rebecca'),('Laura'),('Sharon'),
('Hans'),('Klaus'),('Dieter'),('Wolfgang'),('Helmut'),('Pierre'),('Jacques'),('François'),('Jean'),('Antoine'),
('Sophie'),('Marie'),('Isabelle'),('Camille'),('Charlotte'),('Yuki'),('Takeshi'),('Kenji'),('Hiroshi'),('Akiko'),
('Wei'),('Li'),('Chen'),('Wang'),('Zhang'),('Kumar'),('Raj'),('Amit'),('Priya'),('Ananya'),
('Jack'),('Liam'),('Oliver'),('Emma'),('Olivia'),('Ava'),('Sophia'),('Isabella'),('Mia'),('Charlotte');

INSERT INTO @LastNames VALUES 
('Smith'),('Johnson'),('Williams'),('Brown'),('Jones'),('Garcia'),('Miller'),('Davis'),('Rodriguez'),('Martinez'),
('Anderson'),('Taylor'),('Thomas'),('Moore'),('Jackson'),('Martin'),('Lee'),('Thompson'),('White'),('Harris'),
('Mueller'),('Schmidt'),('Schneider'),('Fischer'),('Weber'),('Dubois'),('Bernard'),('Moreau'),('Laurent'),('Simon'),
('Rossi'),('Russo'),('Ferrari'),('Esposito'),('Bianchi'),('Garcia'),('Lopez'),('Martinez'),('Gonzalez'),('Rodriguez'),
('Tanaka'),('Suzuki'),('Takahashi'),('Watanabe'),('Yamamoto'),('Chen'),('Wang'),('Li'),('Zhang'),('Liu'),
('Kumar'),('Singh'),('Sharma'),('Patel'),('Gupta'),('Cooper'),('Wilson'),('Murphy'),('O''Brien'),('Kelly');

INSERT INTO @Cities VALUES 
('New York','United States',1),('Los Angeles','United States',2),('Chicago','United States',3),
('Miami','United States',4),('Seattle','United States',5),
('Berlin','Germany',6),('Paris','France',7),('London','United Kingdom',8),
('Munich','Germany',9),('Rome','Italy',10),
('Tokyo','Japan',11),('Shanghai','China',12),('Singapore','Singapore',13),
('Seoul','South Korea',14),('Mumbai','India',15),
('Sydney','Australia',16),('Melbourne','Australia',17),('Brisbane','Australia',18),
('Perth','Australia',19),('Adelaide','Australia',20);

-- Insert 100 customers with varied data
WHILE @i <= 100
BEGIN
    DECLARE @FirstName NVARCHAR(50) = (SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID());
    DECLARE @LastName NVARCHAR(50) = (SELECT TOP 1 Name FROM @LastNames ORDER BY NEWID());
    DECLARE @City NVARCHAR(100), @Country NVARCHAR(100), @DealershipID INT;
    
    SELECT TOP 1 @City = City, @Country = Country, @DealershipID = DealershipID 
    FROM @Cities ORDER BY NEWID();
    
    INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone, Address, City, Country, PreferredDealership, LoyaltyPoints)
    VALUES (
        @FirstName,
        @LastName,
        LOWER(@FirstName + '.' + @LastName + CAST(@i AS NVARCHAR(10)) + '@email.com'),
        '+' + CAST(ABS(CHECKSUM(NEWID())) % 100 AS NVARCHAR(10)) + '-555-' + RIGHT('0000' + CAST(@i AS NVARCHAR(10)), 4),
        CAST(ABS(CHECKSUM(NEWID())) % 9999 AS NVARCHAR(10)) + ' Main Street',
        @City,
        @Country,
        @DealershipID,
        ABS(CHECKSUM(NEWID())) % 1000
    );
    
    SET @i = @i + 1;
END;
GO

-- =====================================================
-- Insert Vehicle Inventory (200 vehicles - Optimized)
-- =====================================================
DECLARE @i INT;
DECLARE @Makes TABLE (Make NVARCHAR(50));
DECLARE @Models TABLE (Model NVARCHAR(50), Make NVARCHAR(50), BasePrice DECIMAL(10,2));
DECLARE @Colors TABLE (Color NVARCHAR(30));
DECLARE @FuelTypes TABLE (FuelType NVARCHAR(20));
DECLARE @Features TABLE (Feature NVARCHAR(200));

INSERT INTO @Makes VALUES ('Tesla'),('BMW'),('Mercedes-Benz'),('Audi'),('Porsche'),('Ford'),('Chevrolet'),
('Toyota'),('Honda'),('Nissan'),('Hyundai'),('Kia'),('Volkswagen'),('Volvo'),('Lexus'),('Genesis'),
('Jaguar'),('Land Rover'),('Peugeot'),('Renault'),('BYD'),('NIO'),('Lucid'),('Rivian'),('Polestar');

INSERT INTO @Models VALUES 
('Model 3','Tesla',45999),('Model Y','Tesla',58999),('Model S','Tesla',89990),('Model X','Tesla',99990),
('330i','BMW',48500),('iX','BMW',89000),('X5','BMW',72000),('i4','BMW',65000),
('C-Class','Mercedes-Benz',52000),('E-Class','Mercedes-Benz',68000),('EQS','Mercedes-Benz',105000),('GLE','Mercedes-Benz',75000),
('e-tron GT','Audi',105000),('Q4 e-tron','Audi',58000),('A6','Audi',62000),('Q7','Audi',68000),
('911','Porsche',125000),('Taycan','Porsche',92000),('Cayenne','Porsche',82000),('Macan','Porsche',62000),
('F-150 Lightning','Ford',62000),('Mustang Mach-E','Ford',52000),('Explorer','Ford',42000),
('Corvette','Chevrolet',75000),('Blazer EV','Chevrolet',55000),('Silverado EV','Chevrolet',68000),
('Crown','Toyota',48000),('bZ4X','Toyota',46000),('Camry','Toyota',32000),('RAV4','Toyota',35000),
('Accord','Honda',33000),('CR-V','Honda',36000),('Pilot','Honda',42000),
('Ariya','Nissan',52000),('Leaf','Nissan',38000),('Pathfinder','Nissan',45000),
('Ioniq 5','Hyundai',52000),('Ioniq 6','Hyundai',48000),('Palisade','Hyundai',46000),
('EV6','Kia',52000),('EV9','Kia',65000),('Telluride','Kia',48000),
('ID.4','Volkswagen',45000),('ID.Buzz','Volkswagen',58000),('Passat','Volkswagen',35000),
('XC40','Volvo',48000),('XC90','Volvo',62000),('EX30','Volvo',42000),
('RX 450h','Lexus',58000),('ES 300h','Lexus',48000),('NX','Lexus',45000),
('GV70','Genesis',52000),('GV80','Genesis',68000),('Electrified GV70','Genesis',72000),
('I-PACE','Jaguar',79000),('F-PACE','Jaguar',62000),
('Evoque','Land Rover',52000),('Defender','Land Rover',68000),('Range Rover','Land Rover',105000),
('508','Peugeot',42000),('3008','Peugeot',38000),
('Megane E-Tech','Renault',38000),('Zoe','Renault',35000),
('Han EV','BYD',52000),('Tang','BYD',58000),('Seal','BYD',48000),
('ET5','NIO',58000),('ES6','NIO',62000),('ET7','NIO',72000),
('Air','Lucid',95000),('Gravity','Lucid',88000),
('R1T','Rivian',78000),('R1S','Rivian',82000),
('2','Polestar',52000),('3','Polestar',68000);

INSERT INTO @Colors VALUES ('White'),('Black'),('Silver'),('Gray'),('Blue'),('Red'),('Green'),('Yellow'),('Orange'),('Brown');
INSERT INTO @FuelTypes VALUES ('Electric'),('Petrol'),('Hybrid'),('Diesel');
INSERT INTO @Features VALUES 
('Autopilot, Premium Audio, Glass Roof'),('M Sport Package, Navigation, Heated Seats'),
('AMG Line, Burmester Sound, Panoramic Roof'),('Sport Chrono, PASM, Carbon Ceramic Brakes'),
('Long Range, FSD, Premium Interior'),('Matrix LED, B&O Sound, Adaptive Suspension'),
('Extended Range, Pro Power, BlueCruise'),('Z51 Performance, Carbon Fiber, HUD'),
('Executive Drive, Laser Lights, Massage Seats'),('Pro Performance, IQ.Light, Travel Assist'),
('GT Line, Focal Sound, Night Vision'),('Techno, OpenR Screen, Multi-Sense'),
('HSE, Meridian Sound, Air Suspension'),('SE, ClearSight, Terrain Response'),
('Hybrid Max, JBL Audio, Safety Sense 3.0'),('e-4ORCE, ProPILOT 2.0, Bose Sound'),
('Blade Battery, DiPilot, Dynaudio'),('NAD, NOP+, Premium Interior'),
('Plaid, FSD, 7 Seats'),('AWD, V2L, Highway Drive Assist'),
('GT-Line, Meridian Sound, Ultra Fast Charging'),('Advanced, Lexicon Audio, Highway Driving Assist II'),
('Pilot Assist, Harman Kardon, 360 Camera'),('Sport Plus, Adaptive Dampers, Head-Up Display');

SET @i = 1;
WHILE @i <= 200
BEGIN
    DECLARE @DealerID INT = ((@i - 1) % 20) + 1;
    DECLARE @Make NVARCHAR(50), @Model NVARCHAR(50), @BasePrice DECIMAL(10,2);
    DECLARE @Color NVARCHAR(30), @FuelType NVARCHAR(20), @Feature NVARCHAR(200);
    DECLARE @Year INT = 2024 + (ABS(CHECKSUM(NEWID())) % 2); -- 2024 or 2025
    DECLARE @Price DECIMAL(10,2), @Mileage INT, @Status NVARCHAR(20);
    
    -- Debug: Ensure DealerID is valid
    IF @DealerID IS NULL OR @DealerID < 1 OR @DealerID > 20
        SET @DealerID = 1;
    
    SELECT TOP 1 @Model = Model, @Make = Make, @BasePrice = BasePrice FROM @Models ORDER BY NEWID();
    SELECT TOP 1 @Color = Color FROM @Colors ORDER BY NEWID();
    SELECT TOP 1 @FuelType = FuelType FROM @FuelTypes ORDER BY NEWID();
    SELECT TOP 1 @Feature = Feature FROM @Features ORDER BY NEWID();
    
    -- Adjust price: luxury cars (>70k base) get +/- 5k, others get +/- 3k variation
    IF @BasePrice > 70000
        SET @Price = @BasePrice + (ABS(CHECKSUM(NEWID())) % 10000) - 5000;
    ELSE
        SET @Price = @BasePrice + (ABS(CHECKSUM(NEWID())) % 6000) - 3000;
        
    SET @Mileage = ABS(CHECKSUM(NEWID())) % 500;
    SET @Status = CASE 
        WHEN (@i % 10) < 7 THEN 'Available'
        WHEN (@i % 10) < 9 THEN 'Reserved'
        ELSE 'Sold'
    END;
    
    BEGIN TRY
        INSERT INTO dbo.VehicleInventory (DealershipID, VIN, Make, Model, Year, Color, Price, Status, Mileage, FuelType, Transmission, Features)
    VALUES (
        @DealerID,
        'VIN' + RIGHT('00000000000000' + CAST(@i AS NVARCHAR(10)), 14), -- 'VIN' + 14 digits = exactly 17 chars
        @Make,
        @Model,
        @Year,
        @Color,
        @Price,
        @Status,
        @Mileage,
        @FuelType,
        'Automatic',
        @Feature
    );
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting vehicle ' + CAST(@i AS NVARCHAR(10)) + ': ' + ERROR_MESSAGE();
    END CATCH
    
    SET @i = @i + 1;
END;
GO

-- =====================================================
-- Insert Parts (50 parts - Optimized)
-- =====================================================
INSERT INTO dbo.Parts (PartNumber, PartName, Category, UnitPrice, StockQuantity, ReorderLevel, Supplier)
VALUES 
    ('ENG-001', 'Oil Filter Standard', 'Engine', 25.00, 5000, 500, 'AutoParts Global'),
    ('ENG-002', 'Oil Filter Premium', 'Engine', 35.00, 3000, 300, 'AutoParts Global'),
    ('ENG-003', 'Air Filter Standard', 'Engine', 30.00, 4000, 400, 'AutoParts Global'),
    ('ENG-004', 'Spark Plugs Standard (Set)', 'Engine', 40.00, 3000, 300, 'Champion Parts'),
    ('ENG-005', 'Spark Plugs Iridium (Set)', 'Engine', 65.00, 2000, 200, 'NGK Parts'),
    ('ENG-006', 'Timing Belt', 'Engine', 85.00, 1500, 150, 'Gates Corporation'),
    ('ENG-007', 'Fuel Filter', 'Engine', 35.00, 2000, 200, 'Bosch Auto'),
    ('ENG-008', 'Fuel Pump', 'Engine', 350.00, 500, 50, 'Bosch Auto'),
    ('BRK-001', 'Brake Pads Front Standard', 'Brakes', 100.00, 3000, 300, 'BrakeMax Inc'),
    ('BRK-002', 'Brake Pads Front Performance', 'Brakes', 180.00, 1500, 150, 'Brembo'),
    ('BRK-003', 'Brake Pads Rear Standard', 'Brakes', 85.00, 3000, 300, 'BrakeMax Inc'),
    ('BRK-004', 'Brake Rotors Front', 'Brakes', 120.00, 2000, 200, 'BrakeMax Inc'),
    ('BRK-005', 'Brake Rotors Rear', 'Brakes', 100.00, 2000, 200, 'BrakeMax Inc'),
    ('BRK-006', 'Brake Fluid DOT 4', 'Brakes', 15.00, 4000, 400, 'FluidTech'),
    ('BRK-007', 'Brake Calipers Front', 'Brakes', 250.00, 800, 80, 'BrakeMax Inc'),
    ('TIR-001', 'All-Season Tire 17"', 'Tires', 160.00, 2000, 200, 'Michelin'),
    ('TIR-002', 'All-Season Tire 18"', 'Tires', 180.00, 1800, 180, 'Michelin'),
    ('TIR-003', 'Winter Tire 17"', 'Tires', 180.00, 1500, 150, 'Bridgestone'),
    ('TIR-004', 'Winter Tire 18"', 'Tires', 200.00, 1300, 130, 'Bridgestone'),
    ('TIR-005', 'Performance Tire 18"', 'Tires', 250.00, 1000, 100, 'Pirelli'),
    ('TIR-006', 'Tire Pressure Sensor', 'Tires', 45.00, 2500, 250, 'TireTech'),
    ('BAT-001', 'Car Battery 12V 60Ah', 'Electrical', 120.00, 1200, 120, 'PowerCell Co'),
    ('BAT-002', 'Car Battery 12V 75Ah', 'Electrical', 150.00, 1000, 100, 'PowerCell Co'),
    ('BAT-003', 'EV Battery Module Small', 'Electrical', 2500.00, 200, 20, 'EV PowerTech'),
    ('BAT-004', 'Alternator', 'Electrical', 280.00, 600, 60, 'Bosch Auto'),
    ('BAT-005', 'Starter Motor', 'Electrical', 320.00, 500, 50, 'Bosch Auto'),
    ('FLU-001', 'Engine Coolant 1L', 'Fluids', 18.00, 5000, 500, 'FluidTech'),
    ('FLU-002', 'Transmission Fluid ATF', 'Fluids', 28.00, 3000, 300, 'FluidTech'),
    ('FLU-003', 'Power Steering Fluid', 'Fluids', 22.00, 2500, 250, 'FluidTech'),
    ('FLU-004', 'Windshield Washer Fluid', 'Fluids', 8.00, 6000, 600, 'FluidTech'),
    ('FLU-005', 'Motor Oil 5W-30 Synthetic', 'Fluids', 45.00, 4000, 400, 'Mobil 1'),
    ('FLU-006', 'Motor Oil 0W-20 Synthetic', 'Fluids', 48.00, 3500, 350, 'Mobil 1'),
    ('WIP-001', 'Wiper Blades 18" (Pair)', 'Accessories', 30.00, 3000, 300, 'ClearView Auto'),
    ('WIP-002', 'Wiper Blades 20" (Pair)', 'Accessories', 35.00, 2800, 280, 'ClearView Auto'),
    ('WIP-003', 'Rear Wiper Blade', 'Accessories', 18.00, 2000, 200, 'ClearView Auto'),
    ('LGT-001', 'LED Headlight Bulb H7', 'Lighting', 85.00, 2000, 200, 'BrightLights Inc'),
    ('LGT-002', 'LED Headlight Bulb H11', 'Lighting', 85.00, 2000, 200, 'BrightLights Inc'),
    ('LGT-003', 'Tail Light Assembly', 'Lighting', 180.00, 1000, 100, 'BrightLights Inc'),
    ('LGT-004', 'Turn Signal Bulb', 'Lighting', 12.00, 4000, 400, 'Philips Auto'),
    ('CLN-001', 'Cabin Air Filter Standard', 'HVAC', 35.00, 3000, 300, 'AirFlow Systems'),
    ('CLN-002', 'AC Compressor', 'HVAC', 450.00, 400, 40, 'Denso'),
    ('CLN-003', 'AC Condenser', 'HVAC', 280.00, 500, 50, 'Denso'),
    ('CLN-004', 'Blower Motor', 'HVAC', 180.00, 600, 60, 'Denso'),
    ('CLN-005', 'AC Refrigerant R134a', 'HVAC', 35.00, 2500, 250, 'DuPont'),
    ('SUS-001', 'Front Shock Absorber', 'Suspension', 180.00, 1000, 100, 'Monroe'),
    ('SUS-002', 'Rear Shock Absorber', 'Suspension', 160.00, 1000, 100, 'Monroe'),
    ('SUS-003', 'Control Arm Front', 'Suspension', 120.00, 700, 70, 'Moog'),
    ('SUS-004', 'Ball Joint', 'Suspension', 45.00, 1500, 150, 'Moog'),
    ('EXH-001', 'Muffler', 'Exhaust', 280.00, 600, 60, 'MagnaFlow'),
    ('EXH-002', 'Catalytic Converter', 'Exhaust', 650.00, 400, 40, 'Walker');
GO

-- =====================================================
-- Insert Test Drives (100 recent test drives - Optimized)
-- =====================================================
DECLARE @i INT = 1;
DECLARE @SalesReps TABLE (RepName NVARCHAR(100));
INSERT INTO @SalesReps VALUES 
('Tom Richards'),('Lisa Chen'),('Mike Johnson'),('Sarah Williams'),('Klaus Weber'),
('Pierre Dubois'),('Kenji Yamada'),('Wang Lei'),('Matt Cooper'),('Emma Wilson');

WHILE @i <= 100
BEGIN
    DECLARE @CustomerID INT = (ABS(CHECKSUM(NEWID())) % 100) + 1;
    DECLARE @VehicleID INT = (ABS(CHECKSUM(NEWID())) % 200) + 1;
    DECLARE @DealerID INT = (SELECT PreferredDealership FROM dbo.Customers WHERE CustomerID = @CustomerID);
    DECLARE @DaysAgo INT = ABS(CHECKSUM(NEWID())) % 180; -- Last 6 months
    DECLARE @Duration INT = 30 + (ABS(CHECKSUM(NEWID())) % 60); -- 30-90 minutes
    DECLARE @Rating INT = 3 + (ABS(CHECKSUM(NEWID())) % 3); -- 3-5 rating
    DECLARE @SalesRep NVARCHAR(100) = (SELECT TOP 1 RepName FROM @SalesReps ORDER BY NEWID());
    DECLARE @Converted BIT = CASE WHEN @Rating >= 4 AND (ABS(CHECKSUM(NEWID())) % 100) < 30 THEN 1 ELSE 0 END;
    DECLARE @Feedback NVARCHAR(MAX) = CASE @Rating
        WHEN 5 THEN 'Excellent vehicle! Loved everything about it.'
        WHEN 4 THEN 'Great car, considering purchasing.'
        ELSE 'Good test drive experience.'
    END;
    
    BEGIN TRY
        INSERT INTO dbo.TestDrives (CustomerID, VehicleID, DealershipID, TestDriveDate, Duration, CustomerRating, CustomerFeedback, SalesRepName, ConvertedToSale)
        VALUES (@CustomerID, @VehicleID, @DealerID, DATEADD(day, -@DaysAgo, GETDATE()), @Duration, @Rating, @Feedback, @SalesRep, @Converted);
    END TRY
    BEGIN CATCH
        -- Skip if foreign key constraint fails
        PRINT 'Skipping test drive ' + CAST(@i AS NVARCHAR(10));
    END CATCH
    
    SET @i = @i + 1;
END;
GO

-- =====================================================
-- Insert Customer Purchases (60 purchases - Optimized)
-- =====================================================
DECLARE @i INT = 1;
DECLARE @SalesReps TABLE (RepName NVARCHAR(100));
INSERT INTO @SalesReps VALUES 
('Tom Richards'),('Lisa Chen'),('Mike Johnson'),('Sarah Williams'),('Klaus Weber'),
('Pierre Dubois'),('Kenji Yamada'),('Wang Lei'),('Matt Cooper'),('Emma Wilson');

WHILE @i <= 60
BEGIN
    DECLARE @CustID INT = (ABS(CHECKSUM(NEWID())) % 100) + 1;
    DECLARE @VehID INT = (ABS(CHECKSUM(NEWID())) % 200) + 1;
    DECLARE @DealID INT = (SELECT PreferredDealership FROM dbo.Customers WHERE CustomerID = @CustID);
    DECLARE @DaysAgo INT = ABS(CHECKSUM(NEWID())) % 365; -- Last year
    DECLARE @VehiclePrice DECIMAL(10,2) = (SELECT Price FROM dbo.VehicleInventory WHERE VehicleID = @VehID);
    DECLARE @SalePrice DECIMAL(10,2) = @VehiclePrice - (ABS(CHECKSUM(NEWID())) % 5000); -- Discount
    DECLARE @FinanceType NVARCHAR(20) = CASE (ABS(CHECKSUM(NEWID())) % 4)
        WHEN 0 THEN 'Cash'
        WHEN 1 THEN 'Loan'
        WHEN 2 THEN 'Lease'
        ELSE 'Loan'
    END;
    DECLARE @DownPayment DECIMAL(10,2) = CASE 
        WHEN @FinanceType = 'Cash' THEN @SalePrice
        ELSE @SalePrice * (0.10 + (ABS(CHECKSUM(NEWID())) % 20) / 100.0)
    END;
    DECLARE @LoanTerm INT = CASE 
        WHEN @FinanceType = 'Cash' THEN NULL
        WHEN @FinanceType = 'Lease' THEN 36
        ELSE 60
    END;
    DECLARE @MonthlyPayment DECIMAL(10,2) = CASE 
        WHEN @FinanceType = 'Cash' THEN NULL
        ELSE (@SalePrice - @DownPayment) / @LoanTerm
    END;
    DECLARE @TradeIn DECIMAL(10,2) = CASE 
        WHEN (ABS(CHECKSUM(NEWID())) % 100) < 40 THEN (ABS(CHECKSUM(NEWID())) % 15000) + 2000
        ELSE 0
    END;
    DECLARE @SalesRep NVARCHAR(100) = (SELECT TOP 1 RepName FROM @SalesReps ORDER BY NEWID());
    DECLARE @WarrantyYears INT = 2 + (ABS(CHECKSUM(NEWID())) % 4); -- 2-5 years
    
    BEGIN TRY
        INSERT INTO dbo.CustomerPurchases (CustomerID, VehicleID, DealershipID, PurchaseDate, SalePrice, FinanceType, DownPayment, MonthlyPayment, LoanTerm, TradeInValue, SalesRepName, WarrantyPurchased, ExtendedWarrantyYears)
        VALUES (@CustID, @VehID, @DealID, DATEADD(day, -@DaysAgo, GETDATE()), @SalePrice, @FinanceType, @DownPayment, @MonthlyPayment, @LoanTerm, @TradeIn, @SalesRep, 1, @WarrantyYears);
        
        -- Mark vehicle as sold
        UPDATE dbo.VehicleInventory SET Status = 'Sold', LastUpdated = DATEADD(day, -@DaysAgo, GETDATE()) WHERE VehicleID = @VehID;
    END TRY
    BEGIN CATCH
        -- Skip if foreign key constraint fails
        PRINT 'Skipping purchase ' + CAST(@i AS NVARCHAR(10));
    END CATCH
    
    SET @i = @i + 1;
END;
GO

-- =====================================================
-- Insert Service Records (150 service records - Optimized)
-- =====================================================
DECLARE @i INT;
DECLARE @Technicians TABLE (TechName NVARCHAR(100));
INSERT INTO @Technicians VALUES 
('Carlos Martinez'),('David Kim'),('Hans Schmidt'),('Peter Brown'),('Takeshi Sato'),
('Ryan O''Brien'),('Sophie Taylor'),('Marco Rossi');

DECLARE @ServiceTypes TABLE (ServiceType NVARCHAR(100), BaseLabor DECIMAL(10,2), BaseParts DECIMAL(10,2), Description NVARCHAR(MAX));
INSERT INTO @ServiceTypes VALUES 
('Oil Change', 50.00, 60.00, 'Routine oil and filter change'),
('Tire Rotation', 40.00, 0, 'Rotated all four tires, checked alignment'),
('Brake Service', 120.00, 240.00, 'Brake pad and rotor service'),
('Major Service', 200.00, 350.00, 'Full service including all filters and fluids'),
('Battery Replacement', 50.00, 150.00, 'Replaced car battery'),
('Tire Replacement', 80.00, 720.00, 'Replaced all four tires'),
('AC Service', 150.00, 180.00, 'AC system inspection and refrigerant refill'),
('Transmission Service', 180.00, 250.00, 'Transmission fluid change'),
('Suspension Repair', 200.00, 450.00, 'Shock absorber replacement'),
('Annual Inspection', 120.00, 80.00, 'Comprehensive annual safety inspection'),
('Exhaust Repair', 150.00, 380.00, 'Exhaust system repair'),
('Wheel Alignment', 90.00, 0, 'Four-wheel alignment');

SET @i = 1;
WHILE @i <= 150
BEGIN
    -- 80% historical, 20% scheduled future services
    DECLARE @IsFuture BIT = CASE WHEN @i > 120 THEN 1 ELSE 0 END;
    DECLARE @VehID INT = (ABS(CHECKSUM(NEWID())) % 200) + 1;
    DECLARE @CustID INT = (ABS(CHECKSUM(NEWID())) % 100) + 1;
    DECLARE @DealID INT = (SELECT TOP 1 DealershipID FROM dbo.Dealerships ORDER BY NEWID());
    DECLARE @ServiceDate DATETIME, @Status NVARCHAR(20), @NextServiceDue DATETIME;
    DECLARE @ServiceType NVARCHAR(100), @Description NVARCHAR(MAX), @LaborCost DECIMAL(10,2), @PartsCost DECIMAL(10,2);
    DECLARE @Mileage INT = 5000 + (ABS(CHECKSUM(NEWID())) % 50000);
    DECLARE @Technician NVARCHAR(100) = (SELECT TOP 1 TechName FROM @Technicians ORDER BY NEWID());
    
    SELECT TOP 1 @ServiceType = ServiceType, @Description = Description, @LaborCost = BaseLabor, @PartsCost = BaseParts
    FROM @ServiceTypes ORDER BY NEWID();
    
    IF @IsFuture = 1
    BEGIN
        SET @ServiceDate = DATEADD(day, ABS(CHECKSUM(NEWID())) % 60, GETDATE());
        SET @Status = 'Scheduled';
        SET @NextServiceDue = NULL;
    END
    ELSE
    BEGIN
        SET @ServiceDate = DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE());
        SET @Status = 'Completed';
        SET @NextServiceDue = DATEADD(month, 3 + (ABS(CHECKSUM(NEWID())) % 9), @ServiceDate);
    END
    
    BEGIN TRY
        INSERT INTO dbo.ServiceRecords (VehicleID, CustomerID, DealershipID, ServiceDate, ServiceType, Description, Mileage, LaborCost, PartsCost, TechnicianName, Status, NextServiceDue)
        VALUES (@VehID, @CustID, @DealID, @ServiceDate, @ServiceType, @Description, @Mileage, @LaborCost, @PartsCost, @Technician, @Status, @NextServiceDue);
    END TRY
    BEGIN CATCH
        -- Skip if foreign key constraint fails
        PRINT 'Skipping service record ' + CAST(@i AS NVARCHAR(10));
    END CATCH
    
    SET @i = @i + 1;
END;
GO

-- =====================================================
-- Insert Part Usage (300 part usage records - Optimized)
-- =====================================================
DECLARE @i INT = 1;
WHILE @i <= 300
BEGIN
    DECLARE @ServiceID INT = (ABS(CHECKSUM(NEWID())) % 150) + 1;
    DECLARE @PartID INT = (ABS(CHECKSUM(NEWID())) % 50) + 1;
    DECLARE @Quantity INT = 1 + (ABS(CHECKSUM(NEWID())) % 4);
    DECLARE @UnitPrice DECIMAL(10,2) = (SELECT UnitPrice FROM dbo.Parts WHERE PartID = @PartID);
    
    -- Only insert if not duplicate
    IF NOT EXISTS (SELECT 1 FROM dbo.PartUsage WHERE ServiceID = @ServiceID AND PartID = @PartID)
    BEGIN
        BEGIN TRY
            INSERT INTO dbo.PartUsage (ServiceID, PartID, Quantity, UnitPrice)
            VALUES (@ServiceID, @PartID, @Quantity, @UnitPrice);
            
            -- Update parts stock
            UPDATE dbo.Parts 
            SET StockQuantity = StockQuantity - @Quantity
            WHERE PartID = @PartID AND StockQuantity >= @Quantity;
        END TRY
        BEGIN CATCH
            -- Skip if foreign key constraint fails (service doesn't exist)
            PRINT 'Skipping part usage ' + CAST(@i AS NVARCHAR(10));
        END CATCH
    END
    
    SET @i = @i + 1;
END;
GO

PRINT 'Sample data inserted successfully!';
PRINT 'Database contains:';
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
SELECT 'Part Usage', COUNT(*) FROM dbo.PartUsage;
GO
