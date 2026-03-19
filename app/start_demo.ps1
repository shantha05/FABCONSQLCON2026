# Conference Demo Startup Script
# Starts the Dealership Application for Demo

Write-Host "`n══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  STARTING CONFERENCE DEMO APPLICATION" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Navigate to app directory
$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $appDir

# Step 1: Check if virtual environment exists
Write-Host "[1/5] Checking Python environment..." -ForegroundColor Yellow
if (Test-Path "venv\Scripts\python.exe") {
    Write-Host "✓ Virtual environment found" -ForegroundColor Green
} else {
    Write-Host "✗ Virtual environment not found. Creating..." -ForegroundColor Red
    python -m venv venv
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Virtual environment created" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create virtual environment" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Activate virtual environment and check packages
Write-Host "`n[2/5] Checking dependencies..." -ForegroundColor Yellow
.\venv\Scripts\Activate.ps1

$requiredPackages = @("flask", "flask-cors", "pyodbc", "python-dotenv")
$installedPackages = pip list | Out-String

$missingPackages = @()
foreach ($package in $requiredPackages) {
    if ($installedPackages -notmatch $package) {
        $missingPackages += $package
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host "✗ Missing packages: $($missingPackages -join ', ')" -ForegroundColor Red
    Write-Host "Installing missing packages..." -ForegroundColor Yellow
    pip install -r requirements.txt --quiet
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✓ All dependencies installed" -ForegroundColor Green
}

# Step 3: Check .env configuration
Write-Host "`n[3/5] Checking configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    $envContent = Get-Content .env -Raw
    if ($envContent -match "USE_ENTRA_AUTH=True") {
        Write-Host "✓ Configuration file found (Entra ID authentication)" -ForegroundColor Green
    } else {
        Write-Host "⚠ Warning: USE_ENTRA_AUTH should be True for Fabric SQL Database" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ .env file not found!" -ForegroundColor Red
    Write-Host "Please create .env file with your Fabric SQL Database connection details" -ForegroundColor Yellow
    exit 1
}

# Step 4: Kill any existing Python processes on port 5000
Write-Host "`n[4/5] Checking for existing processes..." -ForegroundColor Yellow
$existingProcess = Get-Process python -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "*FABCONSQLCON2026*"}
if ($existingProcess) {
    Write-Host "✓ Stopping existing application..." -ForegroundColor Yellow
    $existingProcess | Stop-Process -Force
    Start-Sleep -Seconds 2
}
Write-Host "✓ Port 5000 is ready" -ForegroundColor Green

# Step 5: Start the application
Write-Host "`n[5/5] Starting Flask application..." -ForegroundColor Yellow
Write-Host "`n══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  APPLICATION STARTING - CONFERENCE DEMO MODE" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "`n📊 Dashboard URL: http://localhost:5000" -ForegroundColor Cyan
Write-Host "🔌 API Health: http://localhost:5000/api/health" -ForegroundColor Cyan
Write-Host "`n💡 Press Ctrl+C to stop the application`n" -ForegroundColor Yellow

# Start the app
& .\venv\Scripts\python.exe app.py
