# Setup Script for Car Dealership Demo
# Microsoft Fabric SQL Database

Write-Host "" -ForegroundColor Cyan
Write-Host "Note: Fabric SQL Database uses Entra ID (Azure AD) authentication" -ForegroundColor Cyan
Write-Host "You will be prompted to sign in with your Microsoft account" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan

# Database Connection Parameters
$SERVER = Read-Host "Enter your Fabric SQL Server name (e.g., workspace-dbname.datawarehouse.fabric.microsoft.com)"
$DATABASE = Read-Host "Enter your database name"
$EMAIL = Read-Host "Enter your Entra ID email (e.g., user@company.com)"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Car Dealership Demo - Setup Wizard" -ForegroundColor Cyan
Write-Host "Microsoft Fabric SQL Database" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check prerequisites
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

# Check if sqlcmd is installed
try {
    $sqlcmdVersion = sqlcmd -?
    Write-Host "✓ SQL Server command-line tools detected" -ForegroundColor Green
} catch {
    Write-Host "✗ SQL Server command-line tools not found" -ForegroundColor Red
    Write-Host "Please install SQL Server command-line tools from:" -ForegroundColor Yellow
    Write-Host "https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility" -ForegroundColor Yellow
    exit 1
}

# Check if Python is installed
try {
    $pythonVersion = python --version
    Write-Host "✓ Python detected: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Python not found" -ForegroundColor Red
    Write-Host "Please install Python 3.8 or later from https://www.python.org" -ForegroundColor Yellow
    exit 1
}

# Step 2: Setup database schema
Write-Host "`n[2/5] Creating database schema..." -ForegroundColor Yellow

$schemaFile = Join-Path $PSScriptRoot "..\database\01_schema.sql"
if (Test-Path $schemaFile) {
    try {
        Write-Host "Running schema creation (browser window will open for authentication)..." -ForegroundColor Cyan
        sqlcmd -S $SERVER -d $DATABASE -U $EMAIL -G -i $schemaFile -I
        Write-Host "✓ Database schema created successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error creating schema: $_" -ForegroundColor Red
        Write-Host "Make sure you have access to the Fabric SQL Database" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✗ Schema file not found: $schemaFile" -ForegroundColor Red
    exit 1
}

# Step 3: Load sample data
Write-Host "`n[3/5] Loading sample data..." -ForegroundColor Yellow

$dataFile = Join-Path $PSScriptRoot "..\database\02_sample_data.sql"
if (Test-Path $dataFile) {
    try {
        Write-Host "Loading sample data (you may need to authenticate again)..." -ForegroundColor Cyan
        sqlcmd -S $SERVER -d $DATABASE -U $EMAIL -G -i $dataFile -I
        Write-Host "✓ Sample data loaded successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error loading data: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Data file not found: $dataFile" -ForegroundColor Red
    exit 1
}

# Step 4: Create analytics views
Write-Host "`n[4/6] Creating analytics views..." -ForegroundColor Yellow

$viewsFile = Join-Path $PSScriptRoot "..\database\03_analytics_views.sql"
if (Test-Path $viewsFile) {
    try {
        Write-Host "Creating analytics views..." -ForegroundColor Cyan
        sqlcmd -S $SERVER -d $DATABASE -U $EMAIL -G -i $viewsFile -I
        Write-Host "✓ Analytics views created successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error creating views: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Views file not found: $viewsFile" -ForegroundColor Red
    exit 1
}

# Step 5: Create performance indexes
Write-Host "`n[5/6] Creating performance indexes..." -ForegroundColor Yellow

$indexesFile = Join-Path $PSScriptRoot "..\database\04_indexes.sql"
if (Test-Path $indexesFile) {
    try {
        Write-Host "Creating indexes for query optimization..." -ForegroundColor Cyan
        sqlcmd -S $SERVER -d $DATABASE -U $EMAIL -G -i $indexesFile -I
        Write-Host "✓ Performance indexes created successfully" -ForegroundColor Green
    } catch {
        Write-Host "✗ Error creating indexes: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Indexes file not found: $indexesFile" -ForegroundColor Red
    exit 1
}

# Step 6: Setup Python environment
Write-Host "`n[6/6] Setting up Python environment..." -ForegroundColor Yellow

$appDir = Join-Path $PSScriptRoot "..\app"
Push-Location $appDir

# Create virtual environment
try {
    Write-Host "Creating virtual environment..." -ForegroundColor Cyan
    python -m venv venv
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
} catch {
    Write-Host "✗ Error creating virtual environment: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Activate virtual environment and install packages
try {
    Write-Host "Installing Python packages..." -ForegroundColor Cyan
    .\venv\Scripts\Activate.ps1
    pip install -r requirements.txt --quiet
    Write-Host "✓ Python packages installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Error installing packages: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Create .env file
Write-Host "Creating environment configuration..." -ForegroundColor Cyan
$envContent = @"
# Database Configuration
DB_SERVER=$SERVER
DB_NAME=$DATABASE

# Authentication Method
# For Fabric SQL Database, use Entra ID authentication
USE_ENTRA_AUTH=True

# Application Configuration
FLASK_ENV=development
FLASK_DEBUG=True
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Host "✓ Environment configuration created" -ForegroundColor Green

Pop-Location

# Final success message
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓ Setup completed successfully!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Navigate to the app directory: cd app" -ForegroundColor White
Write-Host "2. Activate virtual environment: .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "3. Start the application: python app.py" -ForegroundColor White
Write-Host "4. Open browser: http://localhost:5000`n" -ForegroundColor White

Write-Host "Database Details:" -ForegroundColor Cyan
Write-Host "  Server: $SERVER" -ForegroundColor White
Write-Host "  Database: $DATABASE" -ForegroundColor White
Write-Host "  Tables: 8 operational tables" -ForegroundColor White
Write-Host "  Views: 7 analytics views" -ForegroundColor White
Write-Host "  Sample Records: ~100+ records`n" -ForegroundColor White

Write-Host "Authentication:" -ForegroundColor Cyan
Write-Host "  Using Entra ID (Azure AD) authentication" -ForegroundColor White
Write-Host "  No password stored in configuration" -ForegroundColor White
Write-Host "  App will use Azure.Identity for authentication`n" -ForegroundColor White
