"""Car Dealership Management System - Microsoft Fabric SQL Database Integration"""

from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import pyodbc
import os
import random
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
app.config['TEMPLATES_AUTO_RELOAD'] = True

@app.after_request
def add_header(response):
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '-1'
    return response

def get_pagination_params():
    page = request.args.get('page', 1, type=int)
    page_size = min(request.args.get('page_size', 20, type=int), 100)
    offset = (page - 1) * page_size
    return page, page_size, offset

DB_CONFIG = {
    'server': os.getenv('DB_SERVER', 'workspace-id.database.fabric.microsoft.com'),
    'database': os.getenv('DB_NAME', 'your-database-name'),
    'driver': os.getenv('DB_DRIVER', '{ODBC Driver 18 for SQL Server}'),
    'use_entra_auth': os.getenv('USE_ENTRA_AUTH', 'True').lower() == 'true'
}

AZURE_OPENAI_CONFIG = {
    'endpoint': os.getenv('AZURE_OPENAI_ENDPOINT', ''),
    'api_key': os.getenv('AZURE_OPENAI_API_KEY', ''),
    'deployment': os.getenv('AZURE_OPENAI_DEPLOYMENT', 'gpt-4'),
    'embedding_deployment': os.getenv('AZURE_OPENAI_EMBEDDING_DEPLOYMENT', 'text-embedding-ada-002')
}

def get_db_connection():
    if DB_CONFIG['use_entra_auth']:
        connection_string = (
            f"DRIVER={DB_CONFIG['driver']};"
            f"SERVER={DB_CONFIG['server']};"
            f"DATABASE={DB_CONFIG['database']};"
            "Authentication=ActiveDirectoryInteractive;"
            "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
        )
        print(f"Connecting with Entra ID: {DB_CONFIG['server']}/{DB_CONFIG['database']}")
        return pyodbc.connect(connection_string)
    else:
        username = os.getenv('DB_USERNAME', '')
        password = os.getenv('DB_PASSWORD', '')
        if not username or not password:
            raise ValueError("DB_USERNAME and DB_PASSWORD required for SQL authentication")
        
        connection_string = (
            f"DRIVER={DB_CONFIG['driver']};SERVER={DB_CONFIG['server']};"
            f"DATABASE={DB_CONFIG['database']};UID={username};PWD={password};"
            "Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;"
        )
        return pyodbc.connect(connection_string)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/transactions')
def transactions():
    return render_template('transactions.html')

@app.route('/api-test')
def api_test():
    return render_template('api-test.html')

@app.route('/test-dashboard')
def test_dashboard():
    return render_template('test-dashboard.html')

@app.route('/api/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'message': 'API is running',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/dashboard/summary')
def dashboard_summary():
    """Get overall dashboard summary statistics"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get key metrics
        query = """
        SELECT 
            (SELECT COUNT(*) FROM dbo.VehicleInventory WHERE Status = 'Available') AS AvailableVehicles,
            (SELECT COUNT(*) FROM dbo.CustomerPurchases WHERE PurchaseDate >= DATEADD(day, -30, GETDATE())) AS SalesLast30Days,
            (SELECT ISNULL(SUM(SalePrice), 0) FROM dbo.CustomerPurchases WHERE PurchaseDate >= DATEADD(day, -30, GETDATE())) AS RevenueLast30Days,
            (SELECT COUNT(*) FROM dbo.ServiceRecords WHERE ServiceDate >= DATEADD(day, -30, GETDATE()) AND Status = 'Completed') AS ServicesLast30Days,
            (SELECT COUNT(*) FROM dbo.TestDrives WHERE TestDriveDate >= DATEADD(day, -7, GETDATE())) AS TestDrivesLast7Days,
            (SELECT COUNT(*) FROM dbo.Customers) AS TotalCustomers
        """
        
        cursor.execute(query)
        row = cursor.fetchone()
        
        summary = {
            'availableVehicles': row[0],
            'salesLast30Days': row[1],
            'revenueLast30Days': float(row[2]),
            'servicesLast30Days': row[3],
            'testDrivesLast7Days': row[4],
            'totalCustomers': row[5]
        }
        
        conn.close()
        return jsonify(summary)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/sales/regional')
def sales_by_region():
    """Get sales data by region"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Optimized query without view for better performance
        query = """
        SELECT 
            d.Region,
            COUNT(DISTINCT d.DealershipID) AS Dealerships,
            COUNT(cp.PurchaseID) AS TotalSales,
            SUM(cp.SalePrice) AS TotalRevenue,
            AVG(cp.SalePrice) AS AvgSalePrice
        FROM dbo.CustomerPurchases cp
        INNER JOIN dbo.Dealerships d ON cp.DealershipID = d.DealershipID
        WHERE YEAR(cp.PurchaseDate) = YEAR(GETDATE())
        GROUP BY d.Region
        ORDER BY TotalRevenue DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        
        data = []
        for row in rows:
            data.append({
                'region': row[0],
                'dealerships': row[1],
                'totalSales': row[2],
                'totalRevenue': float(row[3]),
                'avgSalePrice': float(row[4])
            })
        
        conn.close()
        return jsonify(data)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/inventory/overview')
def inventory_overview():
    """Get inventory overview by status and region"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Optimized direct query
        query = """
        SELECT 
            d.Region,
            v.Status,
            v.FuelType,
            COUNT(*) AS TotalVehicles,
            AVG(v.Price) AS AvgPrice
        FROM dbo.VehicleInventory v
        INNER JOIN dbo.Dealerships d ON v.DealershipID = d.DealershipID
        GROUP BY d.Region, v.Status, v.FuelType
        ORDER BY d.Region, v.Status
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        
        data = []
        for row in rows:
            data.append({
                'region': row[0],
                'status': row[1],
                'fuelType': row[2],
                'totalVehicles': row[3],
                'avgPrice': float(row[4]) if row[4] else 0
            })
        
        conn.close()
        return jsonify(data)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/inventory/available')
def available_inventory():
    """Get available vehicles with details (paginated)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        region = request.args.get('region', None)
        page, page_size, offset = get_pagination_params()
        
        # Count total records
        count_query = """
        SELECT COUNT(*) 
        FROM dbo.VehicleInventory v
        INNER JOIN dbo.Dealerships d ON v.DealershipID = d.DealershipID
        WHERE v.Status = 'Available'
        """
        
        if region:
            count_query += " AND d.Region = ?"
            cursor.execute(count_query, region)
        else:
            cursor.execute(count_query)
        
        total_count = cursor.fetchone()[0]
        
        # Get paginated data
        query = """
        SELECT 
            v.VehicleID,
            v.Make,
            v.Model,
            v.Year,
            v.Color,
            v.Price,
            v.Mileage,
            v.FuelType,
            v.Transmission,
            v.Features,
            d.DealershipName,
            d.Region,
            d.City
        FROM dbo.VehicleInventory v
        INNER JOIN dbo.Dealerships d ON v.DealershipID = d.DealershipID
        WHERE v.Status = 'Available'
        """
        
        if region:
            query += " AND d.Region = ? ORDER BY v.VehicleID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
            cursor.execute(query, region, offset, page_size)
        else:
            query += " ORDER BY v.VehicleID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY"
            cursor.execute(query, offset, page_size)
        
        rows = cursor.fetchall()
        
        vehicles = []
        for row in rows:
            vehicles.append({
                'vehicleId': row[0],
                'make': row[1],
                'model': row[2],
                'year': row[3],
                'color': row[4],
                'price': float(row[5]),
                'mileage': row[6],
                'fuelType': row[7],
                'transmission': row[8],
                'features': row[9],
                'dealership': row[10],
                'region': row[11],
                'city': row[12]
            })
        
        conn.close()
        return jsonify({
            'data': vehicles,
            'pagination': {
                'page': page,
                'page_size': page_size,
                'total_count': total_count,
                'total_pages': (total_count + page_size - 1) // page_size
            }
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/customers/top')
def top_customers():
    """Get top customers by lifetime value"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        limit = min(request.args.get('limit', 20, type=int), 100)
        
        # Optimized direct query
        query = """
        SELECT TOP (?)
            c.CustomerID,
            c.FirstName + ' ' + c.LastName AS CustomerName,
            c.Email,
            c.Country,
            c.LoyaltyPoints,
            COUNT(DISTINCT cp.PurchaseID) AS TotalPurchases,
            COUNT(DISTINCT sr.ServiceID) AS TotalServiceVisits,
            ISNULL(SUM(cp.SalePrice), 0) AS LifetimeValue,
            MAX(cp.PurchaseDate) AS LastPurchaseDate
        FROM dbo.Customers c
        LEFT JOIN dbo.CustomerPurchases cp ON c.CustomerID = cp.CustomerID
        LEFT JOIN dbo.ServiceRecords sr ON c.CustomerID = sr.CustomerID
        GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email, c.Country, c.LoyaltyPoints
        HAVING COUNT(DISTINCT cp.PurchaseID) > 0
        ORDER BY LifetimeValue DESC
        """
        
        cursor.execute(query, limit)
        rows = cursor.fetchall()
        
        customers = []
        for row in rows:
            customers.append({
                'name': row[1],  # CustomerName (FirstName + LastName)
                'email': row[2],
                'country': row[3],
                'loyaltyPoints': row[4],
                'totalPurchases': row[5],
                'totalServiceVisits': row[6],
                'lifetimeValue': float(row[7]) if row[7] else 0,
                'lastPurchaseDate': row[8].strftime('%Y-%m-%d') if row[8] else None
            })
        
        conn.close()
        return jsonify(customers)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/service/analytics')
def service_analytics():
    """Get service department analytics"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Optimized direct query
        query = """
        SELECT 
            d.Region,
            sr.ServiceType,
            COUNT(*) AS TotalServices,
            SUM(sr.TotalCost) AS TotalRevenue,
            AVG(sr.TotalCost) AS AvgCost
        FROM dbo.ServiceRecords sr
        INNER JOIN dbo.Dealerships d ON sr.DealershipID = d.DealershipID
        WHERE sr.Status = 'Completed' AND YEAR(sr.ServiceDate) = YEAR(GETDATE())
        GROUP BY d.Region, sr.ServiceType
        ORDER BY TotalRevenue DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        
        services = []
        for row in rows:
            services.append({
                'region': row[0],
                'serviceType': row[1],
                'totalServices': row[2],
                'totalRevenue': float(row[3]),
                'avgCost': float(row[4])
            })
        
        conn.close()
        return jsonify(services)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/testdrives/conversion')
def testdrive_conversion():
    """Get test drive conversion rates (paginated)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        page, page_size, offset = get_pagination_params()
        
        # Optimized direct query with pagination
        query = """
        SELECT 
            d.Region,
            v.Make,
            v.Model,
            COUNT(*) AS TotalTestDrives,
            SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) AS ConvertedSales,
            CAST(SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ConversionRate,
            AVG(CAST(td.CustomerRating AS FLOAT)) AS AvgRating
        FROM dbo.TestDrives td
        INNER JOIN dbo.Dealerships d ON td.DealershipID = d.DealershipID
        INNER JOIN dbo.VehicleInventory v ON td.VehicleID = v.VehicleID
        GROUP BY d.Region, v.Make, v.Model
        ORDER BY ConversionRate DESC
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        cursor.execute(query, offset, page_size)
        rows = cursor.fetchall()
        
        conversions = []
        for row in rows:
            conversions.append({
                'region': row[0],
                'make': row[1],
                'model': row[2],
                'totalTestDrives': row[3],
                'convertedSales': row[4],
                'conversionRate': float(row[5]),
                'avgRating': float(row[6]) if row[6] else 0
            })
        
        conn.close()
        return jsonify(conversions)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/parts/inventory')
def parts_inventory():
    """Get parts inventory status (paginated)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        status_filter = request.args.get('status', None)
        page, page_size, offset = get_pagination_params()
        
        # Optimized direct query with pagination
        query = """
        SELECT 
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
            ISNULL(SUM(pu.TotalPrice), 0) AS TotalRevenue
        FROM dbo.Parts p
        LEFT JOIN dbo.PartUsage pu ON p.PartID = pu.PartID
        """
        
        if status_filter:
            query += """
        GROUP BY p.PartNumber, p.PartName, p.Category, p.UnitPrice, p.StockQuantity, p.ReorderLevel
        HAVING CASE 
                WHEN p.StockQuantity <= p.ReorderLevel THEN 'Reorder Needed'
                WHEN p.StockQuantity <= p.ReorderLevel * 1.5 THEN 'Low Stock'
                ELSE 'In Stock'
            END = ?
        ORDER BY p.PartNumber
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            """
            cursor.execute(query, status_filter, offset, page_size)
        else:
            query += """
        GROUP BY p.PartNumber, p.PartName, p.Category, p.UnitPrice, p.StockQuantity, p.ReorderLevel
        ORDER BY p.PartNumber
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            """
            cursor.execute(query, offset, page_size)
        
        rows = cursor.fetchall()
        
        parts = []
        for row in rows:
            parts.append({
                'partNumber': row[0],
                'partName': row[1],
                'category': row[2],
                'unitPrice': float(row[3]),
                'stockQuantity': row[4],
                'reorderLevel': row[5],
                'stockStatus': row[6],
                'usageCount': row[7] if row[7] else 0,
                'totalRevenue': float(row[8]) if row[8] else 0
            })
        
        conn.close()
        return jsonify(parts)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/regional/performance')
def regional_performance():
    """Get comprehensive regional performance metrics"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        SELECT 
            Region,
            TotalDealerships,
            TotalInventory,
            AvailableVehicles,
            TotalSales,
            TotalSalesRevenue,
            TotalServices,
            TotalServiceRevenue,
            TotalRevenue,
            TotalCustomers
        FROM dbo.vw_RegionalPerformance
        ORDER BY TotalRevenue DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        
        performance = []
        for row in rows:
            performance.append({
                'region': row[0],
                'totalDealerships': row[1],
                'totalInventory': row[2],
                'availableVehicles': row[3],
                'totalSales': row[4],
                'totalSalesRevenue': float(row[5]) if row[5] else 0,
                'totalServices': row[6],
                'totalServiceRevenue': float(row[7]) if row[7] else 0,
                'totalRevenue': float(row[8]) if row[8] else 0,
                'totalCustomers': row[9]
            })
        
        conn.close()
        return jsonify(performance)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/recommendations/ai')
def ai_recommendations():
    """Get AI-powered recommendations (mock implementation)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get data for recommendations
        query = """
        SELECT TOP 5
            v.Make,
            v.Model,
            COUNT(td.TestDriveID) AS TestDriveCount,
            AVG(td.CustomerRating) AS AvgRating,
            SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) AS Conversions
        FROM dbo.VehicleInventory v
        LEFT JOIN dbo.TestDrives td ON v.VehicleID = td.VehicleID
        WHERE v.Status = 'Available'
        GROUP BY v.Make, v.Model
        HAVING COUNT(td.TestDriveID) > 0
        ORDER BY AvgRating DESC, TestDriveCount DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        
        recommendations = []
        for row in rows:
            recommendations.append({
                'type': 'High Interest Vehicle',
                'make': row[0],
                'model': row[1],
                'reason': f"High customer rating ({row[3]:.1f}/5) with {row[2]} test drives",
                'action': 'Consider increasing inventory or promoting',
                'priority': 'High' if row[3] >= 4.5 else 'Medium'
            })
        
        # Add parts recommendations
        query_parts = """
        SELECT TOP 3
            PartName,
            Category,
            StockQuantity,
            ReorderLevel
        FROM dbo.vw_PartsInventory
        WHERE StockStatus = 'Reorder Needed'
        ORDER BY StockQuantity
        """
        
        cursor.execute(query_parts)
        rows_parts = cursor.fetchall()
        
        for row in rows_parts:
            recommendations.append({
                'type': 'Parts Reorder',
                'item': row[0],
                'category': row[1],
                'reason': f"Stock critically low ({row[2]} units, reorder at {row[3]})",
                'action': 'Reorder immediately',
                'priority': 'High'
            })
        
        conn.close()
        return jsonify(recommendations)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# =====================================================
# TRANSACTIONAL WRITE ENDPOINTS (OLTP Operations)
# =====================================================

@app.route('/api/purchases/create', methods=['POST'])
def create_purchase():
    """Create a new customer purchase (transactional write)"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['customerID', 'vehicleID', 'dealershipID', 'salePrice']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Insert purchase record - using actual schema column names
        query = """
        INSERT INTO dbo.CustomerPurchases 
        (CustomerID, VehicleID, DealershipID, PurchaseDate, SalePrice, 
         FinanceType, DownPayment, MonthlyPayment, LoanTerm, TradeInValue, 
         SalesRepName, WarrantyPurchased, ExtendedWarrantyYears)
        VALUES (?, ?, ?, GETDATE(), ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        # Map paymentMethod to FinanceType
        finance_type = data.get('paymentMethod', 'Cash')
        warranty_purchased = 1 if data.get('warrantyType') else 0
        
        cursor.execute(query, 
            data['customerID'],
            data['vehicleID'],
            data['dealershipID'],
            data['salePrice'],
            finance_type,  # FinanceType (Cash, Loan, Lease)
            data.get('downPayment', 0),
            data.get('monthlyPayment', 0),
            data.get('financeTerm', None),  # LoanTerm in months
            data.get('tradeInValue', 0),
            data.get('salespersonName', 'Online Sale'),  # SalesRepName
            warranty_purchased,  # WarrantyPurchased (BIT)
            data.get('extendedWarrantyYears', None)
        )
        
        # Update vehicle status to Sold
        cursor.execute("""
            UPDATE dbo.VehicleInventory 
            SET Status = 'Sold', LastUpdated = GETDATE()
            WHERE VehicleID = ?
        """, data['vehicleID'])
        
        # Update customer loyalty points (10 points per $1000 spent)
        loyalty_points = int(data['salePrice'] / 1000) * 10
        cursor.execute("""
            UPDATE dbo.Customers 
            SET LoyaltyPoints = LoyaltyPoints + ?
            WHERE CustomerID = ?
        """, loyalty_points, data['customerID'])
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Purchase created successfully',
            'loyaltyPointsAdded': loyalty_points
        }), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/testdrives/schedule', methods=['POST'])
def schedule_testdrive():
    """Schedule a new test drive (transactional write)"""
    try:
        data = request.get_json()
        
        required_fields = ['customerID', 'vehicleID', 'dealershipID', 'testDriveDate']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        # Parse and format the datetime properly for SQL Server
        test_drive_date = data['testDriveDate']
        try:
            # Parse datetime-local format (YYYY-MM-DDTHH:MM)
            dt = datetime.fromisoformat(test_drive_date.replace('Z', '+00:00'))
            # Format for SQL Server (YYYY-MM-DD HH:MM:SS)
            formatted_date = dt.strftime('%Y-%m-%d %H:%M:%S')
        except ValueError:
            return jsonify({'error': 'Invalid date format. Expected ISO format (YYYY-MM-DDTHH:MM)'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Fixed to use actual schema column names
        query = """
        INSERT INTO dbo.TestDrives 
        (CustomerID, VehicleID, DealershipID, TestDriveDate, Duration, 
         CustomerRating, CustomerFeedback, SalesRepName, ConvertedToSale)
        VALUES (?, ?, ?, ?, ?, NULL, NULL, NULL, 0)
        """
        
        cursor.execute(query,
            data['customerID'],
            data['vehicleID'],
            data['dealershipID'],
            formatted_date,
            data.get('duration', 30)  # Default 30 minutes
        )
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Test drive scheduled successfully'
        }), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/testdrives/complete', methods=['PUT'])
def complete_testdrive():
    """Complete a test drive with rating and feedback"""
    try:
        data = request.get_json()
        
        if 'testDriveID' not in data:
            return jsonify({'error': 'Missing testDriveID'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        UPDATE dbo.TestDrives 
        SET CustomerRating = ?, Feedback = ?, ConvertedToSale = ?
        WHERE TestDriveID = ?
        """
        
        cursor.execute(query,
            data.get('rating'),
            data.get('feedback'),
            data.get('convertedToSale', 0),
            data['testDriveID']
        )
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Test drive completed successfully'
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/service/schedule', methods=['POST'])
def schedule_service():
    """Schedule a new service appointment (transactional write)"""
    try:
        data = request.get_json()
        
        required_fields = ['customerID', 'vehicleID', 'dealershipID', 'serviceType']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Fixed to use actual schema columns
        # Parse and format the datetime properly for SQL Server
        service_date = data.get('serviceDate')
        if service_date:
            try:
                # Parse datetime-local format (YYYY-MM-DDTHH:MM)
                dt = datetime.fromisoformat(service_date.replace('Z', '+00:00'))
                # Format for SQL Server (YYYY-MM-DD HH:MM:SS)
                formatted_date = dt.strftime('%Y-%m-%d %H:%M:%S')
            except ValueError:
                return jsonify({'error': 'Invalid date format. Expected ISO format (YYYY-MM-DDTHH:MM)'}), 400
        else:
            formatted_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        query = """
        INSERT INTO dbo.ServiceRecords 
        (CustomerID, VehicleID, DealershipID, ServiceDate, ServiceType, Description, 
         Mileage, LaborCost, PartsCost, TechnicianName, Status)
        VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, ?, 'Scheduled')
        """
        
        cursor.execute(query,
            data['customerID'],
            data['vehicleID'],
            data['dealershipID'],
            formatted_date,
            data['serviceType'],
            data.get('description', ''),
            data.get('mileage', 0),
            data.get('technicianName')
        )
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Service appointment scheduled successfully'
        }), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/service/complete', methods=['PUT'])
def complete_service():
    """Complete a service record with parts and costs"""
    try:
        data = request.get_json()
        
        if 'serviceID' not in data:
            return jsonify({'error': 'Missing serviceID'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Update service record
        query = """
        UPDATE dbo.ServiceRecords 
        SET Status = 'Completed', 
            TotalCost = ?,
            TechnicianName = ?,
            CompletionDate = GETDATE()
        WHERE ServiceID = ?
        """
        
        cursor.execute(query,
            data.get('totalCost', 0),
            data.get('technicianName', 'Service Team'),
            data['serviceID']
        )
        
        # Add parts usage if provided
        if 'parts' in data:
            for part in data['parts']:
                cursor.execute("""
                    INSERT INTO dbo.PartUsage (ServiceID, PartID, Quantity, TotalPrice)
                    VALUES (?, ?, ?, ?)
                """, data['serviceID'], part['partID'], part['quantity'], part['totalPrice'])
                
                # Update parts inventory
                cursor.execute("""
                    UPDATE dbo.Parts 
                    SET StockQuantity = StockQuantity - ?
                    WHERE PartID = ?
                """, part['quantity'], part['partID'])
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Service completed successfully'
        }), 200
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/inventory/add', methods=['POST'])
def add_inventory():
    """Add new vehicle to inventory (transactional write)"""
    try:
        data = request.get_json()
        
        required_fields = ['dealershipID', 'make', 'model', 'year', 'price']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        INSERT INTO dbo.VehicleInventory 
        (DealershipID, VIN, Make, Model, Year, Color, Price, Status, Mileage, 
         FuelType, Transmission, Features, LastUpdated)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'Available', ?, ?, ?, ?, GETDATE())
        """
        
        cursor.execute(query,
            data['dealershipID'],
            data.get('vin', f"VIN{random.randint(100000, 999999)}"),
            data['make'],
            data['model'],
            data['year'],
            data.get('color', 'Black'),
            data['price'],
            data.get('mileage', 0),
            data.get('fuelType', 'Petrol'),
            data.get('transmission', 'Automatic'),
            data.get('features', '')
        )
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'success': True,
            'message': 'Vehicle added to inventory successfully'
        }), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# =====================================================
# IMMEDIATE ANALYTICS ENDPOINTS
# =====================================================

@app.route('/api/analytics/realtime/sales')
def realtime_sales():
    """Get real-time sales analytics (immediate query after writes)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        -- Real-time sales in last hour
        SELECT 
            COUNT(*) AS SalesLastHour,
            SUM(SalePrice) AS RevenueLastHour,
            AVG(SalePrice) AS AvgSalePrice,
            MIN(PurchaseDate) AS FirstSale,
            MAX(PurchaseDate) AS LastSale
        FROM dbo.CustomerPurchases
        WHERE PurchaseDate >= DATEADD(HOUR, -1, GETDATE());
        
        -- Sales by region in last 24 hours
        SELECT 
            d.Region,
            COUNT(cp.PurchaseID) AS Sales24h,
            SUM(cp.SalePrice) AS Revenue24h
        FROM dbo.CustomerPurchases cp
        INNER JOIN dbo.Dealerships d ON cp.DealershipID = d.DealershipID
        WHERE cp.PurchaseDate >= DATEADD(HOUR, -24, GETDATE())
        GROUP BY d.Region
        ORDER BY Revenue24h DESC;
        """
        
        cursor.execute(query)
        summary_row = cursor.fetchone()
        cursor.nextset()  # Move to next result set
        regional_rows = cursor.fetchall()
        
        summary = {
            'salesLastHour': summary_row[0] if summary_row else 0,
            'revenueLastHour': float(summary_row[1]) if summary_row and summary_row[1] else 0,
            'avgSalePrice': float(summary_row[2]) if summary_row and summary_row[2] else 0,
            'firstSale': summary_row[3].isoformat() if summary_row and summary_row[3] else None,
            'lastSale': summary_row[4].isoformat() if summary_row and summary_row[4] else None
        }
        
        regional = []
        for row in regional_rows:
            regional.append({
                'region': row[0],
                'sales24h': row[1],
                'revenue24h': float(row[2])
            })
        
        conn.close()
        return jsonify({
            'summary': summary,
            'regionalBreakdown': regional,
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/analytics/realtime/activity')
def realtime_activity():
    """Get real-time activity stream (recent transactions)"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        -- Recent purchases
        SELECT TOP 10
            'Purchase' AS ActivityType,
            cp.PurchaseDate AS ActivityTime,
            c.FirstName + ' ' + c.LastName AS CustomerName,
            v.Make + ' ' + v.Model AS VehicleInfo,
            d.DealershipName,
            d.Region,
            cp.SalePrice AS Amount
        FROM dbo.CustomerPurchases cp
        INNER JOIN dbo.Customers c ON cp.CustomerID = c.CustomerID
        INNER JOIN dbo.VehicleInventory v ON cp.VehicleID = v.VehicleID
        INNER JOIN dbo.Dealerships d ON cp.DealershipID = d.DealershipID
        
        UNION ALL
        
        -- Recent test drives
        SELECT TOP 10
            'Test Drive' AS ActivityType,
            td.TestDriveDate AS ActivityTime,
            c.FirstName + ' ' + c.LastName AS CustomerName,
            v.Make + ' ' + v.Model AS VehicleInfo,
            d.DealershipName,
            d.Region,
            NULL AS Amount
        FROM dbo.TestDrives td
        INNER JOIN dbo.Customers c ON td.CustomerID = c.CustomerID
        INNER JOIN dbo.VehicleInventory v ON td.VehicleID = v.VehicleID
        INNER JOIN dbo.Dealerships d ON td.DealershipID = d.DealershipID
        
        UNION ALL
        
        -- Recent service completions
        SELECT TOP 10
            'Service' AS ActivityType,
            sr.CompletionDate AS ActivityTime,
            c.FirstName + ' ' + c.LastName AS CustomerName,
            sr.ServiceType AS VehicleInfo,
            d.DealershipName,
            d.Region,
            sr.TotalCost AS Amount
        FROM dbo.ServiceRecords sr
        INNER JOIN dbo.Customers c ON sr.CustomerID = c.CustomerID
        INNER JOIN dbo.Dealerships d ON sr.DealershipID = d.DealershipID
        WHERE sr.Status = 'Completed' AND sr.CompletionDate IS NOT NULL
        
        ORDER BY ActivityTime DESC
        """
        
        cursor.execute(query)
        rows = cursor.fetchall()
        
        activities = []
        for row in rows:
            activities.append({
                'type': row[0],
                'timestamp': row[1].isoformat() if row[1] else None,
                'customer': row[2],
                'details': row[3],
                'dealership': row[4],
                'region': row[5],
                'amount': float(row[6]) if row[6] else None
            })
        
        conn.close()
        return jsonify({
            'activities': activities,
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# =====================================================
# AI-POWERED ENDPOINTS
# =====================================================

@app.route('/api/ai/vehicle-search', methods=['POST'])
def ai_vehicle_search():
    """Semantic search for vehicles using natural language"""
    try:
        data = request.get_json()
        query_text = data.get('query', '')
        
        if not query_text:
            return jsonify({'error': 'Query text required'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Parse natural language query into SQL conditions
        # This is a simplified implementation - in production, use Azure OpenAI
        keywords = query_text.lower()
        
        sql_conditions = []
        params = []
        
        # Price range detection
        if 'under' in keywords or 'less than' in keywords or 'below' in keywords:
            if '30000' in keywords or '30k' in keywords:
                sql_conditions.append('v.Price < ?')
                params.append(30000)
            elif '50000' in keywords or '50k' in keywords:
                sql_conditions.append('v.Price < ?')
                params.append(50000)
        
        # Fuel type
        if 'electric' in keywords or 'ev' in keywords:
            sql_conditions.append('v.FuelType = ?')
            params.append('Electric')
        elif 'hybrid' in keywords:
            sql_conditions.append('v.FuelType = ?')
            params.append('Hybrid')
        
        # Vehicle type
        if 'suv' in keywords:
            sql_conditions.append('v.BodyStyle = ?')
            params.append('SUV')
        elif 'sedan' in keywords:
            sql_conditions.append('v.BodyStyle = ?')
            params.append('Sedan')
        elif 'truck' in keywords:
            sql_conditions.append('v.BodyStyle = ?')
            params.append('Truck')
        
        # Luxury brands
        luxury_brands = ['bmw', 'mercedes', 'audi', 'lexus', 'tesla']
        for brand in luxury_brands:
            if brand in keywords:
                sql_conditions.append('LOWER(v.Make) = ?')
                params.append(brand)
                break
        
        # Build query
        base_query = """
        SELECT TOP 20
            v.VehicleID,
            v.Make,
            v.Model,
            v.Year,
            v.Color,
            v.Price,
            v.Mileage,
            v.FuelType,
            v.Transmission,
            v.BodyStyle,
            v.Features,
            d.DealershipName,
            d.Region,
            d.City,
            -- Calculate relevance score
            CASE 
                WHEN v.Status = 'Available' THEN 100
                ELSE 50
            END AS RelevanceScore
        FROM dbo.VehicleInventory v
        INNER JOIN dbo.Dealerships d ON v.DealershipID = d.DealershipID
        WHERE 1=1
        """
        
        if sql_conditions:
            base_query += ' AND ' + ' AND '.join(sql_conditions)
        
        base_query += ' ORDER BY RelevanceScore DESC, v.Price'
        
        cursor.execute(base_query, *params if params else ())
        rows = cursor.fetchall()
        
        vehicles = []
        for row in rows:
            vehicles.append({
                'vehicleId': row[0],
                'make': row[1],
                'model': row[2],
                'year': row[3],
                'color': row[4],
                'price': float(row[5]),
                'mileage': row[6],
                'fuelType': row[7],
                'transmission': row[8],
                'bodyStyle': row[9],
                'features': row[10],
                'dealership': row[11],
                'region': row[12],
                'city': row[13],
                'relevanceScore': row[14]
            })
        
        conn.close()
        return jsonify({
            'query': query_text,
            'results': vehicles,
            'count': len(vehicles)
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/recommendations/personalized', methods=['POST'])
def ai_personalized_recommendations():
    """Get AI-powered personalized vehicle recommendations"""
    try:
        data = request.get_json()
        customer_id = data.get('customerID')
        
        if not customer_id:
            return jsonify({'error': 'customerID required'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get customer purchase history and preferences
        query = """
        -- Analyze customer preferences from past purchases and test drives
        WITH CustomerPreferences AS (
            SELECT 
                c.CustomerID,
                c.LoyaltyPoints,
                AVG(cp.SalePrice) AS AvgPurchasePrice,
                STRING_AGG(v.Make, ', ') AS PreferredMakes,
                STRING_AGG(v.FuelType, ', ') AS PreferredFuelTypes
            FROM dbo.Customers c
            LEFT JOIN dbo.CustomerPurchases cp ON c.CustomerID = cp.CustomerID
            LEFT JOIN dbo.VehicleInventory v ON cp.VehicleID = v.VehicleID
            WHERE c.CustomerID = ?
            GROUP BY c.CustomerID, c.LoyaltyPoints
        ),
        RecommendedVehicles AS (
            SELECT TOP 10
                v.VehicleID,
                v.Make,
                v.Model,
                v.Year,
                v.Price,
                v.FuelType,
                v.BodyStyle,
                d.DealershipName,
                d.Region,
                -- Calculate recommendation score
                (
                    CASE WHEN v.Status = 'Available' THEN 50 ELSE 0 END +
                    CASE WHEN v.Price BETWEEN cp.AvgPurchasePrice * 0.8 AND cp.AvgPurchasePrice * 1.2 THEN 30 ELSE 0 END +
                    CASE WHEN v.FuelType IN ('Electric', 'Hybrid') THEN 20 ELSE 0 END
                ) AS RecommendationScore,
                'Based on your purchase history' AS Reason
            FROM dbo.VehicleInventory v
            INNER JOIN dbo.Dealerships d ON v.DealershipID = d.DealershipID
            CROSS JOIN CustomerPreferences cp
            WHERE v.Status = 'Available'
            ORDER BY RecommendationScore DESC
        )
        SELECT * FROM RecommendedVehicles
        """
        
        cursor.execute(query, customer_id)
        rows = cursor.fetchall()
        
        recommendations = []
        for row in rows:
            recommendations.append({
                'vehicleId': row[0],
                'make': row[1],
                'model': row[2],
                'year': row[3],
                'price': float(row[4]),
                'fuelType': row[5],
                'bodyStyle': row[6],
                'dealership': row[7],
                'region': row[8],
                'score': row[9],
                'reason': row[10]
            })
        
        conn.close()
        return jsonify({
            'customerID': customer_id,
            'recommendations': recommendations
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/ai/insights/predictive')
def ai_predictive_insights():
    """Get AI-powered predictive insights and trends"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        query = """
        -- Trending vehicles (high test drive to sale conversion)
        SELECT TOP 5
            v.Make,
            v.Model,
            COUNT(DISTINCT td.TestDriveID) AS TestDrives,
            SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) AS Conversions,
            CAST(SUM(CASE WHEN td.ConvertedToSale = 1 THEN 1 ELSE 0 END) * 100.0 / 
                 NULLIF(COUNT(DISTINCT td.TestDriveID), 0) AS DECIMAL(5,2)) AS ConversionRate,
            AVG(v.Price) AS AvgPrice,
            'Hot Seller' AS Insight
        FROM dbo.TestDrives td
        INNER JOIN dbo.VehicleInventory v ON td.VehicleID = v.VehicleID
        WHERE td.TestDriveDate >= DATEADD(DAY, -30, GETDATE())
        GROUP BY v.Make, v.Model
        HAVING COUNT(DISTINCT td.TestDriveID) >= 3
        ORDER BY ConversionRate DESC;
        
        -- Service trends by vehicle age
        SELECT 
            CASE 
                WHEN YEAR(GETDATE()) - v.Year <= 2 THEN '0-2 years'
                WHEN YEAR(GETDATE()) - v.Year <= 5 THEN '3-5 years'
                WHEN YEAR(GETDATE()) - v.Year <= 10 THEN '6-10 years'
                ELSE '10+ years'
            END AS VehicleAge,
            COUNT(DISTINCT sr.ServiceID) AS ServiceCount,
            AVG(sr.TotalCost) AS AvgServiceCost,
            'Preventive maintenance needed' AS Insight
        FROM dbo.ServiceRecords sr
        INNER JOIN dbo.VehicleInventory v ON sr.VehicleID = v.VehicleID
        WHERE sr.ServiceDate >= DATEADD(DAY, -90, GETDATE())
        GROUP BY 
            CASE 
                WHEN YEAR(GETDATE()) - v.Year <= 2 THEN '0-2 years'
                WHEN YEAR(GETDATE()) - v.Year <= 5 THEN '3-5 years'
                WHEN YEAR(GETDATE()) - v.Year <= 10 THEN '6-10 years'
                ELSE '10+ years'
            END
        ORDER BY VehicleAge;
        """
        
        cursor.execute(query)
        trending_rows = cursor.fetchall()
        cursor.nextset()
        service_trend_rows = cursor.fetchall()
        
        trending = []
        for row in trending_rows:
            trending.append({
                'make': row[0],
                'model': row[1],
                'testDrives': row[2],
                'conversions': row[3],
                'conversionRate': float(row[4]) if row[4] else 0,
                'avgPrice': float(row[5]),
                'insight': row[6]
            })
        
        service_trends = []
        for row in service_trend_rows:
            service_trends.append({
                'vehicleAge': row[0],
                'serviceCount': row[1],
                'avgServiceCost': float(row[2]) if row[2] else 0,
                'insight': row[3]
            })
        
        conn.close()
        return jsonify({
            'trendingVehicles': trending,
            'serviceTrends': service_trends,
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# =====================================================
# POWER BI INTEGRATION ENDPOINT
# =====================================================

@app.route('/api/powerbi/refresh-trigger')
def powerbi_refresh_trigger():
    """Endpoint to trigger Power BI dataset refresh"""
    try:
        # This endpoint can be called after data updates to notify Power BI
        # In production, this would call Power BI REST API to trigger refresh
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get data freshness information
        query = """
        SELECT 
            (SELECT MAX(PurchaseDate) FROM dbo.CustomerPurchases) AS LastSale,
            (SELECT MAX(ServiceDate) FROM dbo.ServiceRecords) AS LastService,
            (SELECT MAX(TestDriveDate) FROM dbo.TestDrives) AS LastTestDrive,
            (SELECT MAX(LastUpdated) FROM dbo.VehicleInventory) AS LastInventoryUpdate
        """
        
        cursor.execute(query)
        row = cursor.fetchone()
        
        freshness = {
            'lastSale': row[0].isoformat() if row[0] else None,
            'lastService': row[1].isoformat() if row[1] else None,
            'lastTestDrive': row[2].isoformat() if row[2] else None,
            'lastInventoryUpdate': row[3].isoformat() if row[3] else None,
            'refreshTimestamp': datetime.now().isoformat(),
            'message': 'Data is up-to-date for Power BI refresh'
        }
        
        conn.close()
        return jsonify(freshness)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# =====================================================
# Run Application
# =====================================================

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=5000)
