// State Management
const state = {
    categories: [],
    currentCategory: null,
    searchTerm: '',
    isAdmin: false
};

// Debug Mode
const DEBUG = true;
function log(...args) {
    if (DEBUG) {
        console.log('[PDCarSpawner]', ...args);
    }
}

// Utility Functions
function fetchNui(eventName, data = {}) {
    return fetch(`https://pd-carspawner/${eventName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }).then(response => response.json());
}

// UI Functions
function showMenu() {
    const menu = document.getElementById('vehicle-menu');
    if (!menu) return;

    menu.style.display = 'block';
    refreshCategories();
    
    // Select first category by default
    if (state.categories.length > 0) {
        selectCategory(state.categories[0].name);
    }
}

function hideMenu() {
    const menu = document.getElementById('vehicle-menu');
    if (!menu) return;
    
    menu.style.display = 'none';
    state.currentCategory = null;
}

function refreshCategories() {
    const categoryList = document.getElementById('categoryList');
    if (!categoryList) return;

    categoryList.innerHTML = '';
    
    state.categories
        .sort((a, b) => (a.order || 0) - (b.order || 0))
        .forEach(category => {
            const button = document.createElement('button');
            button.className = 'category-button';
            if (category.name === state.currentCategory) {
                button.classList.add('active');
            }
            
            button.textContent = category.label || category.name;
            button.onclick = () => selectCategory(category.name);
            
            categoryList.appendChild(button);
        });
}

function selectCategory(categoryName) {
    state.currentCategory = categoryName;
    refreshCategories();
    refreshVehicles();
}

function refreshVehicles() {
    const vehicleList = document.getElementById('vehicleList');
    const noVehicles = document.getElementById('noVehicles');
    if (!vehicleList || !noVehicles) return;

    vehicleList.innerHTML = '';
    
    const category = state.categories.find(c => c.name === state.currentCategory);
    if (!category || !category.vehicles) {
        noVehicles.style.display = 'block';
        return;
    }

    let vehicles = category.vehicles;
    
    // Apply search filter
    if (state.searchTerm) {
        const searchLower = state.searchTerm.toLowerCase();
        vehicles = vehicles.filter(vehicle => 
            vehicle.name.toLowerCase().includes(searchLower) ||
            vehicle.model.toLowerCase().includes(searchLower)
        );
    }

    if (vehicles.length === 0) {
        noVehicles.style.display = 'block';
        return;
    }

    noVehicles.style.display = 'none';
    
    vehicles.forEach(vehicle => {
        const item = document.createElement('div');
        item.className = 'vehicle-item';
        
        // Add restricted class if not authorized
        if (!vehicle.authorized) {
            item.classList.add('restricted');
        }
        
        item.textContent = vehicle.name;
        
        item.onclick = () => {
            log('Vehicle clicked:', vehicle);
            // Always send the request to the server - let server handle authorization
            log('Requesting vehicle spawn:', vehicle.model);
            fetchNui('spawnVehicle', { model: vehicle.model });
        };
        
        vehicleList.appendChild(item);
    });
}

// Event Listeners
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (!data.action) return;
    log('Received message:', data.action);

    switch (data.action) {
        case 'show':
            state.categories = data.categories || [];
            state.isAdmin = data.isAdmin || false;
            showMenu();
            break;
            
        case 'hide':
            hideMenu();
            break;
            
        default:
            log('Unknown action:', data.action);
            break;
    }
});

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    log('Initializing vehicle menu');

    // Set up search
    const searchInput = document.getElementById('vehicleSearch');
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            state.searchTerm = e.target.value.trim();
            refreshVehicles();
        });
    }

    // Set up close button
    const closeBtn = document.getElementById('closeBtn');
    if (closeBtn) {
        closeBtn.onclick = () => fetchNui('close');
    }

    // Set up action buttons
    const actionButtons = {
        'repairBtn': 'repairVehicle',
        'cleanBtn': 'cleanVehicle',
        'flipBtn': 'flipVehicle',
        'deleteBtn': 'deleteVehicle'
    };

    Object.entries(actionButtons).forEach(([btnId, action]) => {
        const btn = document.getElementById(btnId);
        if (btn) {
            btn.onclick = () => fetchNui(action);
        }
    });

    log('Initialization complete');
});
