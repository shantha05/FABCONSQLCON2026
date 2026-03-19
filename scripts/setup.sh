#!/bin/bash

# Setup Script for Car Dealership Demo
# Microsoft Fabric SQL Database

echo ""
echo "========================================"
echo "Car Dealership Demo - Setup Wizard"
echo "Microsoft Fabric SQL Database"
echo "========================================"
echo ""

# Get database connection parameters
read -p "Enter your Fabric SQL Server name (e.g., your-server.database.windows.net): " SERVER
read -p "Enter your database name: " DATABASE
read -p "Enter your username: " USERNAME
read -sp "Enter your password: " PASSWORD
echo ""

# Step 1: Check prerequisites
echo ""
echo "[1/5] Checking prerequisites..."

# Check if sqlcmd is installed
if command -v sqlcmd &> /dev/null; then
    echo "✓ SQL Server command-line tools detected"
else
    echo "✗ SQL Server command-line tools not found"
    echo "Please install SQL Server command-line tools from:"
    echo "https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility"
    exit 1
fi

# Check if Python is installed
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✓ Python detected: $PYTHON_VERSION"
else
    echo "✗ Python not found"
    echo "Please install Python 3.8 or later"
    exit 1
fi

# Step 2: Setup database schema
echo ""
echo "[2/5] Creating database schema..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCHEMA_FILE="$SCRIPT_DIR/../database/01_schema.sql"

if [ -f "$SCHEMA_FILE" ]; then
    sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -i "$SCHEMA_FILE" -I
    if [ $? -eq 0 ]; then
        echo "✓ Database schema created successfully"
    else
        echo "✗ Error creating schema"
        exit 1
    fi
else
    echo "✗ Schema file not found: $SCHEMA_FILE"
    exit 1
fi

# Step 3: Load sample data
echo ""
echo "[3/5] Loading sample data..."

DATA_FILE="$SCRIPT_DIR/../database/02_sample_data.sql"

if [ -f "$DATA_FILE" ]; then
    sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -i "$DATA_FILE" -I
    if [ $? -eq 0 ]; then
        echo "✓ Sample data loaded successfully"
    else
        echo "✗ Error loading data"
        exit 1
    fi
else
    echo "✗ Data file not found: $DATA_FILE"
    exit 1
fi

# Step 4: Create analytics views
echo ""
echo "[4/6] Creating analytics views..."

VIEWS_FILE="$SCRIPT_DIR/../database/03_analytics_views.sql"

if [ -f "$VIEWS_FILE" ]; then
    sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -i "$VIEWS_FILE" -I
    if [ $? -eq 0 ]; then
        echo "✓ Analytics views created successfully"
    else
        echo "✗ Error creating views"
        exit 1
    fi
else
    echo "✗ Views file not found: $VIEWS_FILE"
    exit 1
fi

# Step 5: Create performance indexes
echo ""
echo "[5/6] Creating performance indexes..."

INDEXES_FILE="$SCRIPT_DIR/../database/04_indexes.sql"

if [ -f "$INDEXES_FILE" ]; then
    sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -i "$INDEXES_FILE" -I
    if [ $? -eq 0 ]; then
        echo "✓ Performance indexes created successfully"
    else
        echo "✗ Error creating indexes"
        exit 1
    fi
else
    echo "✗ Indexes file not found: $INDEXES_FILE"
    exit 1
fi

# Step 6: Setup Python environment
echo ""
echo "[6/6] Setting up Python environment..."

APP_DIR="$SCRIPT_DIR/../app"
cd "$APP_DIR"

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv venv
if [ $? -eq 0 ]; then
    echo "✓ Virtual environment created"
else
    echo "✗ Error creating virtual environment"
    exit 1
fi

# Activate virtual environment and install packages
echo "Installing Python packages..."
source venv/bin/activate
pip install -r requirements.txt --quiet
if [ $? -eq 0 ]; then
    echo "✓ Python packages installed"
else
    echo "✗ Error installing packages"
    exit 1
fi

# Create .env file
echo "Creating environment configuration..."
cat > .env << EOF
# Database Configuration
DB_SERVER=$SERVER
DB_NAME=$DATABASE
DB_USERNAME=$USERNAME
DB_PASSWORD=$PASSWORD

# Application Configuration
FLASK_ENV=development
FLASK_DEBUG=True
EOF

echo "✓ Environment configuration created"

cd "$SCRIPT_DIR"

# Final success message
echo ""
echo "========================================"
echo "✓ Setup completed successfully!"
echo "========================================"
echo ""

echo "Next steps:"
echo "1. Navigate to the app directory: cd app"
echo "2. Activate virtual environment: source venv/bin/activate"
echo "3. Start the application: python app.py"
echo "4. Open browser: http://localhost:5000"
echo ""

echo "Database Details:"
echo "  Server: $SERVER"
echo "  Database: $DATABASE"
echo "  Tables: 8 operational tables"
echo "  Views: 7 analytics views"
echo "  Sample Records: ~100+ records"
echo ""
