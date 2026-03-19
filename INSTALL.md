# 📦 Installation Guide

Complete step-by-step installation guide for the Global Dealership Network application using Microsoft Fabric SQL Database.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Install Required Software](#step-1-install-required-software)
- [Step 2: Setup Microsoft Fabric SQL Database](#step-2-setup-microsoft-fabric-sql-database)
- [Step 3: Initialize Database](#step-3-initialize-database)
- [Step 4: Configure Application](#step-4-configure-application)
- [Step 5: Run the Application](#step-5-run-the-application)
- [Step 6: Setup Power BI (Optional)](#step-6-setup-power-bi-optional)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have:

- ✅ A Microsoft Azure account with access to Microsoft Fabric
- ✅ Windows, Linux, or macOS operating system
- ✅ Administrator/sudo privileges for software installation
- ✅ Internet connection for downloading dependencies

---

## Step 1: Install Required Software

### 1.1 Install Python 3.8 or Later

**Windows:**
1. Download Python from [python.org](https://www.python.org/downloads/)
2. Run the installer
3. ✅ **IMPORTANT:** Check "Add Python to PATH"
4. Click "Install Now"
5. Verify installation:
   ```powershell
   python --version
   # Should output: Python 3.8.x or higher
   ```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
python3 --version
```

**macOS (using Homebrew):**
```bash
brew install python3
python3 --version
```

### 1.2 Install ODBC Driver for SQL Server

**Windows:**
1. Download [ODBC Driver 18](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
2. Run installer and follow prompts
3. Verify installation:
   ```powershell
   python -c "import pyodbc; print(pyodbc.drivers())"
   # Should show: ODBC Driver 18 for SQL Server
   ```

**Linux (Ubuntu/Debian):**
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt update
sudo ACCEPT_EULA=Y apt install msodbcsql18 unixodbc-dev
```

**macOS:**
```bash
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release
brew update
brew install msodbcsql18
```

### 1.3 Install SQL Server Command-Line Tools

**Windows:**
1. Download from [Microsoft Docs](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility)
2. Run installer and follow prompts
3. Verify installation:
   ```powershell
   sqlcmd -?
   ```

**Linux:**
```bash
sudo ACCEPT_EULA=Y apt install mssql-tools18
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```

**macOS:**
```bash
brew install mssql-tools18
```

---

## Step 2: Setup Microsoft Fabric SQL Database

### 2.1 Create Microsoft Fabric Workspace

1. Navigate to [Microsoft Fabric Portal](https://app.fabric.microsoft.com)
2. Click **"Workspaces"** in the left navigation
3. Click **"New workspace"**
4. Enter workspace name (e.g., `CarDealershipDemo`)
5. Select appropriate license mode
6. Click **"Apply"**

### 2.2 Create SQL Database

1. In your workspace, click **"+ New"**
2. Select **"SQL Database"** (under Data Engineering or Data Science section)
3. Enter database name (e.g., `DealershipDB`)
4. Click **"Create"**
5. Wait for provisioning to complete (2-5 minutes)

### 2.3 Get Connection Details

1. Open your SQL Database in Fabric
2. Click **"SQL connection string"** or **"Settings"**
3. Copy the following information:
   - **Server name**: `workspace-id.datawarehouse.fabric.microsoft.com`
   - **Database name**: Your database name
4. Note your **Entra ID email** (Azure AD account)

### 2.4 Grant Yourself Access

1. Open **Azure Data Studio** or **SQL Server Management Studio (SSMS)**
2. Connect to your Fabric SQL Database:
   - Server: `your-workspace-id.datawarehouse.fabric.microsoft.com`
   - Authentication: **Azure Active Directory - Universal with MFA**
   - Database: Your database name
3. Run the following SQL to grant yourself admin access:
   ```sql
   -- Replace with your email
   CREATE USER [your-email@company.com] FROM EXTERNAL PROVIDER;
   GO
   
   ALTER ROLE db_owner ADD MEMBER [your-email@company.com];
   GO
   ```

### 2.5 Test Connection

```powershell
# Windows
sqlcmd -S your-server.datawarehouse.fabric.microsoft.com -d YourDatabase -U your-email@company.com -G

# Linux/macOS  
sqlcmd -S your-server.datawarehouse.fabric.microsoft.com -d YourDatabase -U your-email@company.com -G
```

You should be prompted for authentication via browser.

---

## Step 3: Initialize Database

### 3.1 Clone or Download the Project

```bash
# If using Git
git clone <repository-url>
cd FABCONSQLCON2026

# Or download and extract ZIP file
```

### 3.2 Create Database Schema

**Option A: Using Setup Script (Recommended)**

Windows:
```powershell
cd scripts
.\setup.ps1
```

Linux/macOS:
```bash
cd scripts
chmod +x setup.sh
./setup.sh
```

**Option B: Manual Setup**

```bash
# Navigate to database folder
cd database

# 1. Create schema (tables, indexes, relationships)
sqlcmd -S your-server.datawarehouse.fabric.microsoft.com -d YourDatabase -U your-email@company.com -G -i 01_schema.sql

# 2. Load sample data
sqlcmd -S your-server.datawarehouse.fabric.microsoft.com -d YourDatabase -U your-email@company.com -G -i 02_sample_data.sql

# 3. Create analytics views
sqlcmd -S your-server.datawarehouse.fabric.microsoft.com -d YourDatabase -U your-email@company.com -G -i 03_analytics_views.sql

# 4. Create performance indexes
sqlcmd -S your-server.datawarehouse.fabric.microsoft.com -d YourDatabase -U your-email@company.com -G -i 04_indexes.sql
```

### 3.3 Verify Data

```sql
-- Check tables
SELECT 
    t.name AS TableName,
    COUNT(*) AS RecordCount
FROM sys.tables t
LEFT JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;

-- Expected counts:
-- Dealerships: 10
-- Customers: 15
-- VehicleInventory: 22
-- TestDrives: 12
-- CustomerPurchases: 10
-- ServiceRecords: 12
-- Parts: 15
-- PartUsage: 18
```

---

## Step 4: Configure Application

### 4.1 Navigate to App Directory

```bash
cd app
```

### 4.2 Create Virtual Environment

**Windows:**
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
```

**Linux/macOS:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 4.3 Install Python Dependencies

```bash
pip install -r requirements.txt
```

Expected packages:
- flask==3.0.0
- flask-cors==4.0.0
- pyodbc==5.0.1
- python-dotenv==1.0.0
- msal==1.26.0
- requests==2.31.0
- azure-identity==1.15.0
- openai==1.12.0

### 4.4 Create Configuration File

Create a `.env` file in the `/app` directory:

```env
# Database Connection (REQUIRED)
DB_SERVER=your-workspace-id.datawarehouse.fabric.microsoft.com
DB_NAME=YourDatabaseName
DB_DRIVER={ODBC Driver 18 for SQL Server}

# Authentication (REQUIRED for Fabric SQL Database)
USE_ENTRA_AUTH=True

# Optional: Azure OpenAI for AI features
AZURE_OPENAI_ENDPOINT=https://your-openai.openai.azure.com
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_DEPLOYMENT=gpt-4
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-ada-002
```

**Important Notes:**
- Fabric SQL Database **ONLY** supports Entra ID (Azure AD) authentication
- SQL authentication with username/password is **NOT supported**
- `USE_ENTRA_AUTH=True` is **REQUIRED**

### 4.5 Alternative Authentication Methods

**Service Principal (Production):**
```env
USE_ENTRA_AUTH=True
AZURE_CLIENT_ID=your-app-client-id
AZURE_CLIENT_SECRET=your-app-client-secret
AZURE_TENANT_ID=your-tenant-id
```

**Managed Identity (Azure Deployment):**
```env
USE_ENTRA_AUTH=True
USE_MANAGED_IDENTITY=True
```

---

## Step 5: Run the Application

### 5.1 Start the Flask Server

**Windows:**
```powershell
cd app
.\venv\Scripts\Activate.ps1
python app.py
```

**Linux/macOS:**
```bash
cd app
source venv/bin/activate
python app.py
```

### 5.2 Verify Application is Running

1. Open browser and navigate to: `http://localhost:5000`
2. You should see the dashboard with charts and metrics

### 5.3 Test API Endpoints

```bash
# Health check
curl http://localhost:5000/api/health

# Dashboard summary
curl http://localhost:5000/api/dashboard/summary

# Regional sales
curl http://localhost:5000/api/sales/regional

# Available vehicles
curl http://localhost:5000/api/inventory/available?page=1&page_size=10
```

### 5.4 Test Transactional Operations

**Create a Purchase:**
```bash
curl -X POST http://localhost:5000/api/purchases/create \
  -H "Content-Type: application/json" \
  -d '{
    "customerID": 1,
    "vehicleID": 5,
    "dealershipID": 2,
    "salePrice": 45000,
    "paymentMethod": "Finance"
  }'
```

**Schedule a Test Drive:**
```bash
curl -X POST http://localhost:5000/api/testdrives/schedule \
  -H "Content-Type: application/json" \
  -d '{
    "customerID": 1,
    "vehicleID": 10,
    "dealershipID": 1,
    "testDriveDate": "2026-03-25T14:00:00"
  }'
```

---

## Step 6: Setup Power BI (Optional)

### 6.1 Install Power BI Desktop

Download from: [Power BI Desktop](https://powerbi.microsoft.com/desktop/)

Minimum version: December 2023 or later (for Direct Lake support)

### 6.2 Connect to Fabric SQL Database

**Method 1: Direct Lake (Recommended)**

1. Open Power BI Desktop
2. Click **Get Data** → **OneLake data hub**
3. Sign in with your Fabric account
4. Navigate to your workspace
5. Select your SQL Database item
6. Choose **Direct Lake** mode (automatic)
7. Select tables:
   - Dealerships
   - Customers
   - VehicleInventory
   - CustomerPurchases
   - TestDrives
   - ServiceRecords
   - Parts
   - PartUsage
8. Click **Load**

**Method 2: Direct Query (Alternative)**

1. Click **Get Data** → **SQL Server**
2. Server: `your-workspace-id.datawarehouse.fabric.microsoft.com`
3. Database: Your database name
4. Data Connectivity mode: **DirectQuery**
5. Authentication: **Microsoft account**
6. Click **OK**

### 6.3 Import DAX Measures

1. In Power BI, go to **Modeling** tab
2. Click **New Table**
3. Create a table named: `_Measures`
4. Go to **Modeling** → **New Measure**
5. Copy measures from `/powerbi/*.dax` files
6. Paste into formula bar

**Recommended order:**
1. DateTable.dax (create as Calculated Table)
2. KPIMeasures.dax
3. TimeIntelligenceMeasures.dax
4. AdvancedAnalyticsMeasures.dax
5. RegionalPerformanceMeasures.dax
6. InventoryMeasures.dax
7. FinancialMeasures.dax

### 6.4 Create Relationships

Power BI should auto-detect, but verify:

```
Dealerships (1) ←→ (∞) VehicleInventory
Dealerships (1) ←→ (∞) CustomerPurchases
Dealerships (1) ←→ (∞) ServiceRecords
Dealerships (1) ←→ (∞) TestDrives
Customers (1) ←→ (∞) CustomerPurchases
Customers (1) ←→ (∞) TestDrives
VehicleInventory (1) ←→ (∞) CustomerPurchases
ServiceRecords (1) ←→ (∞) PartUsage
Parts (1) ←→ (∞) PartUsage
DateTable[Date] → CustomerPurchases[PurchaseDate]
DateTable[Date] → ServiceRecords[ServiceDate]
DateTable[Date] → TestDrives[TestDriveDate]
```

### 6.5 Mark Date Table

1. Select the **DateTable**
2. Go to **Table Tools** → **Mark as Date Table**
3. Choose **Date** as the date column

---

## Troubleshooting

### Installation Issues

**Issue:** Python not found
```bash
# Verify Python is installed and in PATH
python --version  # or python3 --version
```

**Issue:** ODBC Driver not found
```bash
# Check installed ODBC drivers
python -c "import pyodbc; print(pyodbc.drivers())"

# Should show: 'ODBC Driver 18 for SQL Server'
```

**Issue:** sqlcmd not found
```bash
# Verify sqlcmd is installed
sqlcmd -?
```

### Database Connection Issues

**Error:** "Login failed for user"
- **Solution:** Create user in database and grant permissions (see Step 2.4)

**Error:** "WITH PASSWORD is not supported"
- **Solution:** Use `USE_ENTRA_AUTH=True` in `.env` file

**Error:** "Server not found"
- **Solution:** Verify server name in Fabric portal, ensure it ends with `.datawarehouse.fabric.microsoft.com`

**Error:** "Database does not exist"
- **Solution:** Verify database name, check spelling and case sensitivity

### Application Errors

**Issue:** Port 5000 already in use
```powershell
# Windows
netstat -ano | findstr :5000
Stop-Process -Id <PID> -Force

# Linux/macOS
lsof -i :5000
kill -9 <PID>
```

**Issue:** Module not found
```bash
# Activate virtual environment first
cd app
.\venv\Scripts\Activate.ps1  # Windows
source venv/bin/activate       # Linux/macOS

# Reinstall dependencies
pip install -r requirements.txt
```

**Issue:** Database connection timeout
- **Solution:** Check firewall settings, verify network connectivity
- Increase timeout in connection string: `Connection Timeout=60`

### Power BI Issues

**Issue:** Cannot find OneLake data hub
- **Solution:** Update Power BI Desktop to December 2023 or later

**Issue:** Direct Lake not available
- **Solution:** Use DirectQuery mode instead, or verify Fabric workspace settings

**Issue:** DAX measure errors
- **Solution:** Verify column names match database schema
- Check measure dependencies (import base measures first)

### Performance Issues

**Issue:** Slow queries
```sql
-- Check if indexes are created
SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('VehicleInventory');

-- Recreate indexes if needed
sqlcmd -i database/04_indexes.sql
```

**Issue:** High memory usage
- Reduce page_size in API calls: `?page_size=20`
- Close unused database connections
- Restart Flask application

---

## Next Steps

After successful installation:

1. **Explore the Dashboard:** Navigate to `http://localhost:5000`
2. **Test API Endpoints:** Use curl or Postman to test REST APIs
3. **Create Power BI Report:** Build visualizations using your data
4. **Customize Application:** Modify code to fit your use case
5. **Deploy to Production:** Consider Azure App Service or Azure Functions

---

## Support Resources

- **Microsoft Fabric:** [Documentation](https://learn.microsoft.com/fabric/)
- **Flask:** [Documentation](https://flask.palletsprojects.com/)
- **Power BI:** [Documentation](https://learn.microsoft.com/power-bi/)
- **Python ODBC:** [pyodbc Wiki](https://github.com/mkleehammer/pyodbc/wiki)

---

**Installation Complete! 🎉**

You now have a fully functional dealership management system powered by Microsoft Fabric SQL Database.
