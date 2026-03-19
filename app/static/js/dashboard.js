// Global Dealership Network Dashboard JavaScript - Fresh Build
console.log('🚀 Dashboard.js LOADED - Fresh Build v3.0');

// API Base URL
const API_BASE = 'http://localhost:5000/api';

// Chart instances
let regionalChart, inventoryStatusChart, fuelTypeChart, serviceRevenueChart;

// Initialize dashboard on page load
document.addEventListener('DOMContentLoaded', function() {
    console.log('✅ DOM Content Loaded');
    console.log('📡 API Base:', API_BASE);
    
    initializeDashboard();
    updateLastUpdateTime();
    setInterval(updateLastUpdateTime, 60000);
});

// Initialize all dashboard components
async function initializeDashboard() {
    console.log('🎯 STARTING Dashboard Initialization');
    
    // Load each component sequentially with detailed logging
    await loadDashboardSummary();
    await loadRegionalSales();
    await loadInventoryOverview();
    await loadTopCustomers();
    await loadAvailableInventory();
    await loadServiceAnalytics();
    await loadTestDriveConversion();
    await loadRecommendations();
    
    console.log('🎉 Dashboard Initialization COMPLETE');
}

// Refresh dashboard
function refreshDashboard() {
    console.log('🔄 Refreshing dashboard...');
    const refreshBtn = document.querySelector('.btn-refresh i');
    if (refreshBtn) refreshBtn.style.animation = 'spin 1s linear';
    
    initializeDashboard().then(() => {
        setTimeout(() => {
            if (refreshBtn) refreshBtn.style.animation = '';
        }, 1000);
    });
}

// Update last update time
function updateLastUpdateTime() {
    const elem = document.getElementById('lastUpdate');
    if (elem) {
        elem.textContent = new Date().toLocaleTimeString();
    }
}

// Load dashboard summary metrics
async function loadDashboardSummary() {
    console.log('📊 [1/8] Loading Dashboard Summary...');
    try {
        const response = await fetch(`${API_BASE}/dashboard/summary`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data);
        
        document.getElementById('availableVehicles').textContent = data.availableVehicles.toLocaleString();
        document.getElementById('revenueLast30Days').textContent = `$${(data.revenueLast30Days / 1000).toFixed(0)}K`;
        document.getElementById('salesLast30Days').textContent = data.salesLast30Days;
        document.getElementById('servicesLast30Days').textContent = data.servicesLast30Days;
        document.getElementById('testDrivesLast7Days').textContent = data.testDrivesLast7Days;
        document.getElementById('totalCustomers').textContent = data.totalCustomers;
        
        console.log('  ✅ Summary loaded');
    } catch (error) {
        console.error('  ❌ Summary failed:', error);
    }
}

// Load regional sales data and create chart
async function loadRegionalSales() {
    console.log('🌍 [2/8] Loading Regional Sales...');
    try {
        const response = await fetch(`${API_BASE}/sales/regional`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data.length, 'regions');
        
        const ctx = document.getElementById('regionalChart');
        if (!ctx) throw new Error('Canvas not found');
        
        if (regionalChart) regionalChart.destroy();
        
        regionalChart = new Chart(ctx.getContext('2d'), {
            type: 'bar',
            data: {
                labels: data.map(d => d.region),
                datasets: [{
                    label: 'Revenue ($)',
                    data: data.map(d => d.totalRevenue),
                    backgroundColor: ['rgba(0, 120, 212, 0.8)', 'rgba(16, 124, 16, 0.8)', 
                                     'rgba(135, 100, 184, 0.8)', 'rgba(255, 140, 0, 0.8)'],
                    borderColor: ['rgba(0, 120, 212, 1)', 'rgba(16, 124, 16, 1)', 
                                 'rgba(135, 100, 184, 1)', 'rgba(255, 140, 0, 1)'],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => `Revenue: $${ctx.parsed.y.toLocaleString()}`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: value => '$' + (value / 1000).toFixed(0) + 'K',
                            color: '#b3b3b3'
                        },
                        grid: { color: 'rgba(255, 255, 255, 0.1)' }
                    },
                    x: {
                        ticks: { color: '#b3b3b3' },
                        grid: { display: false }
                    }
                }
            }
        });
        
        console.log('  ✅ Regional Sales loaded');
    } catch (error) {
        console.error('  ❌ Regional Sales failed:', error);
    }
}

// Load inventory overview and create charts
async function loadInventoryOverview() {
    console.log('📦 [3/8] Loading Inventory Overview...');
    try {
        const response = await fetch(`${API_BASE}/inventory/overview`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data.length, 'items');
        
        // Status Chart
        const statusData = data.reduce((acc, item) => {
            acc[item.status] = (acc[item.status] || 0) + item.totalVehicles;
            return acc;
        }, {});
        
        const statusCtx = document.getElementById('inventoryStatusChart');
        if (!statusCtx) throw new Error('Status canvas not found');
        
        if (inventoryStatusChart) inventoryStatusChart.destroy();
        
        inventoryStatusChart = new Chart(statusCtx.getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: Object.keys(statusData),
                datasets: [{
                    data: Object.values(statusData),
                    backgroundColor: ['rgba(16, 124, 16, 0.8)', 'rgba(0, 120, 212, 0.8)', 
                                     'rgba(209, 52, 56, 0.8)', 'rgba(255, 140, 0, 0.8)'],
                    borderColor: '#2d2d2d',
                    borderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#b3b3b3', padding: 15, font: { size: 12 } }
                    }
                }
            }
        });
        
        // Fuel Type Chart
        const fuelData = data.reduce((acc, item) => {
            acc[item.fuelType] = (acc[item.fuelType] || 0) + item.totalVehicles;
            return acc;
        }, {});
        
        const fuelCtx = document.getElementById('fuelTypeChart');
        if (!fuelCtx) throw new Error('Fuel canvas not found');
        
        if (fuelTypeChart) fuelTypeChart.destroy();
        
        fuelTypeChart = new Chart(fuelCtx.getContext('2d'), {
            type: 'pie',
            data: {
                labels: Object.keys(fuelData),
                datasets: [{
                    data: Object.values(fuelData),
                    backgroundColor: ['rgba(16, 124, 16, 0.8)', 'rgba(0, 120, 212, 0.8)', 
                                     'rgba(135, 100, 184, 0.8)', 'rgba(255, 140, 0, 0.8)'],
                    borderColor: '#2d2d2d',
                    borderWidth: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#b3b3b3', padding: 15, font: { size: 12 } }
                    }
                }
            }
        });
        
        console.log('  ✅ Inventory Overview loaded');
    } catch (error) {
        console.error('  ❌ Inventory Overview failed:', error);
    }
}

// Load top customers
async function loadTopCustomers() {
    console.log('👥 [4/8] Loading Top Customers...');
    try {
        const response = await fetch(`${API_BASE}/customers/top?limit=10`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data.length, 'customers');
        
        const tbody = document.querySelector('#customersTable tbody');
        if (!tbody) throw new Error('Table not found');
        
        tbody.innerHTML = '';
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5">No customer data available</td></tr>';
        } else {
            data.forEach(customer => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${customer.name}</td>
                    <td>${customer.country}</td>
                    <td>${customer.totalPurchases}</td>
                    <td>${customer.loyaltyPoints}</td>
                    <td>$${customer.lifetimeValue.toLocaleString()}</td>
                `;
                tbody.appendChild(row);
            });
        }
        
        console.log('  ✅ Top Customers loaded');
    } catch (error) {
        console.error('  ❌ Top Customers failed:', error);
        const tbody = document.querySelector('#customersTable tbody');
        if (tbody) tbody.innerHTML = `<tr><td colspan="5">Error: ${error.message}</td></tr>`;
    }
}

// Load available inventory
async function loadAvailableInventory() {
    console.log('🚗 [5/8] Loading Available Inventory...');
    try {
        const response = await fetch(`${API_BASE}/inventory/available?page_size=100`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const result = await response.json();
        const vehicles = result.data || [];
        console.log('  ✓ Data received:', vehicles.length, 'vehicles');
        
        const premiumVehicles = vehicles.filter(v => v.price > 70000).slice(0, 10);
        console.log('  ✓ Premium vehicles:', premiumVehicles.length);
        
        const tbody = document.querySelector('#inventoryTable tbody');
        if (!tbody) throw new Error('Table not found');
        
        tbody.innerHTML = '';
        
        if (premiumVehicles.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4">No premium vehicles available</td></tr>';
        } else {
            premiumVehicles.forEach(vehicle => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td><strong>${vehicle.year} ${vehicle.make} ${vehicle.model}</strong><br><small>${vehicle.color}</small></td>
                    <td>${vehicle.city}, ${vehicle.region}</td>
                    <td>${vehicle.fuelType}</td>
                    <td><strong>$${vehicle.price.toLocaleString()}</strong></td>
                `;
                tbody.appendChild(row);
            });
        }
        
        console.log('  ✅ Available Inventory loaded');
    } catch (error) {
        console.error('  ❌ Available Inventory failed:', error);
        const tbody = document.querySelector('#inventoryTable tbody');
        if (tbody) tbody.innerHTML = `<tr><td colspan="4">Error: ${error.message}</td></tr>`;
    }
}

// Load service analytics
async function loadServiceAnalytics() {
    console.log('🔧 [6/8] Loading Service Analytics...');
    try {
        const response = await fetch(`${API_BASE}/service/analytics`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data.length, 'items');
        
        const serviceData = data.reduce((acc, item) => {
            acc[item.serviceType] = (acc[item.serviceType] || 0) + item.totalRevenue;
            return acc;
        }, {});
        
        const ctx = document.getElementById('serviceRevenueChart');
        if (!ctx) throw new Error('Canvas not found');
        
        if (serviceRevenueChart) serviceRevenueChart.destroy();
        
        serviceRevenueChart = new Chart(ctx.getContext('2d'), {
            type: 'bar',
            data: {
                labels: Object.keys(serviceData),
                datasets: [{
                    label: 'Revenue ($)',
                    data: Object.values(serviceData),
                    backgroundColor: 'rgba(135, 100, 184, 0.8)',
                    borderColor: 'rgba(135, 100, 184, 1)',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                indexAxis: 'y',
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => `Revenue: $${ctx.parsed.x.toLocaleString()}`
                        }
                    }
                },
                scales: {
                    x: {
                        beginAtZero: true,
                        ticks: {
                            callback: value => '$' + (value / 1000).toFixed(0) + 'K',
                            color: '#b3b3b3'
                        },
                        grid: { color: 'rgba(255, 255, 255, 0.1)' }
                    },
                    y: {
                        ticks: { color: '#b3b3b3' },
                        grid: { display: false }
                    }
                }
            }
        });
        
        console.log('  ✅ Service Analytics loaded');
    } catch (error) {
        console.error('  ❌ Service Analytics failed:', error);
    }
}

// Load test drive conversion data
async function loadTestDriveConversion() {
    console.log('📊 [7/8] Loading Test Drive Conversion...');
    try {
        const response = await fetch(`${API_BASE}/testdrives/conversion?page_size=100`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data.length, 'items');
        
        const tbody = document.querySelector('#conversionTable tbody');
        if (!tbody) throw new Error('Table not found');
        
        tbody.innerHTML = '';
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6">No test drive data available</td></tr>';
        } else {
            data.slice(0, 10).forEach(item => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${item.region}</td>
                    <td>${item.make} ${item.model}</td>
                    <td>${item.totalTestDrives}</td>
                    <td>${item.convertedSales}</td>
                    <td><strong>${item.conversionRate}%</strong></td>
                    <td>${item.avgRating.toFixed(1)} ⭐</td>
                `;
                tbody.appendChild(row);
            });
        }
        
        console.log('  ✅ Test Drive Conversion loaded');
    } catch (error) {
        console.error('  ❌ Test Drive Conversion failed:', error);
        const tbody = document.querySelector('#conversionTable tbody');
        if (tbody) tbody.innerHTML = `<tr><td colspan="6">Error: ${error.message}</td></tr>`;
    }
}

// Load AI recommendations
async function loadRecommendations() {
    console.log('🤖 [8/8] Loading AI Recommendations...');
    try {
        const response = await fetch(`${API_BASE}/recommendations/ai`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        
        const data = await response.json();
        console.log('  ✓ Data received:', data.length, 'recommendations');
        
        const container = document.getElementById('recommendationsContainer');
        if (!container) throw new Error('Container not found');
        
        container.innerHTML = '';
        
        if (data.length === 0) {
            container.innerHTML = '<div>No recommendations available</div>';
        } else {
            data.forEach(rec => {
                const item = document.createElement('div');
                item.className = 'recommendation-item';
                
                const priorityClass = rec.priority === 'High' ? 'priority-high' : 'priority-medium';
                
                item.innerHTML = `
                    <div>
                        <span class="recommendation-type">${rec.type}</span>
                        <span class="recommendation-priority ${priorityClass}">${rec.priority}</span>
                    </div>
                    <div class="recommendation-content">
                        <h4>${rec.make ? rec.make + ' ' + rec.model : rec.item || 'System Recommendation'}</h4>
                        <p>${rec.reason}</p>
                        <p class="recommendation-action">💡 ${rec.action}</p>
                    </div>
                `;
                
                container.appendChild(item);
            });
        }
        
        console.log('  ✅ AI Recommendations loaded');
    } catch (error) {
        console.error('  ❌ AI Recommendations failed:', error);
        const container = document.getElementById('recommendationsContainer');
        if (container) container.innerHTML = `<div>Error: ${error.message}</div>`;
    }
}

// Add CSS animation for refresh button
const style = document.createElement('style');
style.textContent = `
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
`;
document.head.appendChild(style);

console.log('📝 Dashboard.js fully initialized');
