let currentVehicle = null;
let currentCategory = 'compacts';
let vehicles = {};

// Single message handler for all events
window.addEventListener('message', (event) => {
    const data = event.data;

    switch(data.type) {
        case 'setDisplay':
            const menu = document.getElementById('carspawner-menu');
            menu.style.display = data.display ? 'flex' : 'none';
            SetNuiFocus(data.display);

            if (data.display) {
                vehicles = data.vehicles;
                currentCategory = data.currentCategory;
                renderCategories(data.categories);
                renderVehicleList(vehicles[currentCategory]);
            }
            break;
            
        case 'updateVehicleList':
            vehicles = data.vehicles;
            renderVehicleList(vehicles[currentCategory]);
            break;
            
        case 'updateStats':
            updatePerformanceStats(data.stats);
            break;
    }
});

// Initialize UI elements once DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    setupMenuNavigation();
    setupSearch();
    setupQuickActions();
    setupColorPickers();
    setupSaveModal();

    // Close button click
    const closeBtn = document.querySelector('.close-button');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeMenu);
    }

    // ESC key (as backup)
    document.addEventListener('keyup', (e) => {
        if (e.key === 'Escape') {
            closeMenu();
        }
    });
});

document.addEventListener('DOMContentLoaded', () => {
    // Add dedicated close button handler
    const closeButton = document.querySelector('.close-button');
    if (closeButton) {
        closeButton.addEventListener('click', () => {
            console.log('Close button clicked'); // Debug line
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                body: JSON.stringify({})
            }).then(() => {
                const menu = document.getElementById('carspawner-menu');
                if (menu) {
                    menu.style.display = 'none';
                }
            });
        });
    }
});

function setupMenuNavigation() {
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', () => {
            document.querySelectorAll('.menu-item, .menu-content').forEach(el => 
                el.classList.remove('active'));
            
            item.classList.add('active');
            document.getElementById(`${item.dataset.menu}-menu`).classList.add('active');
            
            handleMenuChange(item.dataset.menu);
        });
    });
}

function handleMenuChange(menu) {
    switch(menu) {
        case 'modify':
            loadVehicleModifications();
            break;
        case 'extras':
            loadVehicleExtras();
            break;
        case 'livery':
            loadVehicleLiveries();
            break;
        case 'performance':
            updatePerformanceStats();
            break;
    }
}

function loadVehicleList() {
    fetch(`https://${GetParentResourceName()}/getVehicleList`)
        .then(resp => resp.json())
        .then(data => {
            vehicleList = data;
            renderVehicleList(data);
        });
}

function renderVehicleList(vehicles) {
    const container = document.querySelector('.vehicle-list');
    container.innerHTML = '';

    vehicles.forEach(vehicle => {
        const div = document.createElement('div');
        div.className = 'vehicle-item';
        div.textContent = vehicle.name;
        div.addEventListener('click', () => spawnVehicle(vehicle.model));
        container.appendChild(div);
    });
}

function spawnVehicle(model) {
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        body: JSON.stringify({
            model: model
        })
    });
}

function setupColorPickers() {
    const colorInputs = ['primary', 'secondary', 'pearl'].map(type => 
        document.getElementById(`${type}Color`));
    
    colorInputs.forEach(input => {
        input.addEventListener('change', (e) => {
            const color = hexToRgb(e.target.value);
            fetch(`https://${GetParentResourceName()}/modifyVehicle`, {
                method: 'POST',
                body: JSON.stringify({
                    modType: 'color',
                    colorType: input.id.replace('Color', ''),
                    color: color
                })
            });
        });
    });
}

function setupSaveModal() {
    const saveBtn = document.querySelector('.save-vehicle');
    const modal = document.getElementById('saveModal');
    const cancelBtn = document.getElementById('saveCancelBtn');
    const confirmBtn = document.getElementById('saveConfirmBtn');

    saveBtn.addEventListener('click', () => {
        modal.classList.add('active');
    });

    cancelBtn.addEventListener('click', () => {
        modal.classList.remove('active');
    });

    confirmBtn.addEventListener('click', () => {
        const name = document.getElementById('saveVehicleName').value;
        if (name) {
            fetch(`https://${GetParentResourceName()}/saveVehicle`, {
                method: 'POST',
                body: JSON.stringify({ name: name })
            });
            modal.classList.remove('active');
        }
    });
}

// Utility functions
function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

function loadVehicleModifications() {
    fetch(`https://${GetParentResourceName()}/loadModifications`, {
        method: 'POST'
    })
    .then(resp => resp.json())
    .then(response => {
        if (response.success) {
            renderModifications(response.mods);
        }
    });
}

function loadVehicleExtras() {
    fetch(`https://${GetParentResourceName()}/loadExtras`, {
        method: 'POST'
    })
    .then(resp => resp.json())
    .then(response => {
        if (response.success) {
            renderExtras(response.extras);
        }
    });
}

function loadVehicleLiveries() {
    fetch(`https://${GetParentResourceName()}/loadLiveries`, {
        method: 'POST'
    })
    .then(resp => resp.json())
    .then(response => {
        if (response.success) {
            renderLiveries(response.current, response.total, response.customLiveries);
        }
    });
}

function renderModifications(mods) {
    const container = document.querySelector('.mod-options');
    container.innerHTML = '';

    Object.entries(mods).forEach(([type, data]) => {
        const section = document.createElement('div');
        section.className = 'mod-section';
        section.innerHTML = `
            <h3>${data.name}</h3>
            <div class="mod-levels"></div>
        `;

        const levels = section.querySelector('.mod-levels');
        for (let i = -1; i <= data.max; i++) {
            const level = document.createElement('div');
            level.className = 'mod-level';
            level.textContent = i === -1 ? 'Stock' : `Level ${i + 1}`;
            level.classList.toggle('active', i === data.current);
            level.addEventListener('click', () => {
                fetch(`https://${GetParentResourceName()}/applyMod`, {
                    method: 'POST',
                    body: JSON.stringify({
                        modType: type,
                        modIndex: i
                    })
                });
            });
            levels.appendChild(level);
        }

        container.appendChild(section);
    });
}

function applyMod(type, level) {
    fetch(`https://${GetParentResourceName()}/modifyVehicle`, {
        method: 'POST',
        body: JSON.stringify({
            modType: type,
            modIndex: level
        })
    }).then(() => {
        // Update performance stats after modification
        updatePerformanceStats();
    });
}

function updatePerformanceStats(stats = null) {
    if (!stats) {
        fetch(`https://${GetParentResourceName()}/getVehicleStats`)
            .then(resp => resp.json())
            .then(updatePerformanceStats);
        return;
    }

    Object.entries(stats).forEach(([stat, value]) => {
        const bar = document.querySelector(`#${stat}Stat`);
        if (bar) {
            const progress = document.createElement('div');
            progress.style.width = `${value}%`;
            bar.innerHTML = '';
            bar.appendChild(progress);
        }
    });
}

class VehiclePreview {
    constructor() {
        this.canvas = document.getElementById('vehiclePreview');
        this.ctx = this.canvas.getContext('2d');
        this.rotation = 0;
        this.isDragging = false;
        this.lastX = 0;
        
        this.setupEventListeners();
    }

    setupEventListeners() {
        this.canvas.addEventListener('mousedown', (e) => {
            this.isDragging = true;
            this.lastX = e.clientX;
        });

        document.addEventListener('mousemove', (e) => {
            if (!this.isDragging) return;
            
            const delta = e.clientX - this.lastX;
            this.rotation += delta * 0.01;
            this.lastX = e.clientX;
            
            fetch(`https://${GetParentResourceName()}/rotatePreview`, {
                method: 'POST',
                body: JSON.stringify({ rotation: this.rotation })
            });
        });

        document.addEventListener('mouseup', () => {
            this.isDragging = false;
        });
    }

    updatePreview(imageData) {
        const img = new Image();
        img.onload = () => {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.drawImage(img, 0, 0, this.canvas.width, this.canvas.height);
        };
        img.src = imageData;
    }
}

const preview = new VehiclePreview();

function filterVehicles(searchTerm) {
    const vehicleList = document.querySelector('.vehicle-list');
    const vehicles = vehicleList.getElementsByClassName('vehicle-item');
    
    for (let vehicle of vehicles) {
        const name = vehicle.textContent.toLowerCase();
        if (name.includes(searchTerm.toLowerCase())) {
            vehicle.style.display = '';
        } else {
            vehicle.style.display = 'none';
        }
    }
}

document.getElementById('vehicleSearch').addEventListener('input', (e) => {
    filterVehicles(e.target.value);
});

// Add escape key handler
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
});

// Handle initial vehicle list loading
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.type === 'setDisplay') {
        document.getElementById('carspawner-menu').style.display = data.display ? 'flex' : 'none';
        if (data.display) {
            // Load initial vehicle list
            fetch(`https://${GetParentResourceName()}/getVehicleList`, {
                method: 'POST',
                body: JSON.stringify({ category: 'compacts' })
            })
            .then(resp => resp.json())
            .then(response => {
                if (response.success) {
                    renderVehicleList(response.vehicles);
                }
            });
        }
    }
});

function renderVehicleList(vehicles) {
    const container = document.querySelector('.vehicle-list');
    container.innerHTML = '';
    
    vehicles.forEach(vehicle => {
        const div = document.createElement('div');
        div.className = 'vehicle-item';
        div.textContent = vehicle.name;
        div.dataset.model = vehicle.model;
        div.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
                method: 'POST',
                body: JSON.stringify({ model: vehicle.model })
            });
        });
        container.appendChild(div);
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'setDisplay') {
        const menu = document.getElementById('carspawner-menu');
        menu.style.display = data.display ? 'flex' : 'none';

        if (data.display) {
            // Initialize with data
            vehicles = data.vehicles;
            currentCategory = data.currentCategory;
            renderCategories(data.categories);
            renderVehicleList(vehicles[currentCategory]);
        }
    }
});

function renderCategories(categories) {
    const container = document.querySelector('.categories');
    container.innerHTML = '';

    Object.entries(categories).forEach(([key, name]) => {
        const div = document.createElement('div');
        div.className = 'category';
        div.textContent = name;
        div.dataset.category = key;
        if (key === currentCategory) div.classList.add('active');

        div.addEventListener('click', () => {
            currentCategory = key;
            document.querySelectorAll('.category').forEach(cat => cat.classList.remove('active'));
            div.classList.add('active');
            renderVehicleList(vehicles[key]);
        });

        container.appendChild(div);
    });
}

function renderVehicleList(categoryVehicles) {
    const container = document.querySelector('.vehicle-list');
    container.innerHTML = '';

    if (!categoryVehicles) return;

    categoryVehicles.forEach(vehicle => {
        const div = document.createElement('div');
        div.className = 'vehicle-item';
        div.textContent = vehicle.name;
        div.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
                method: 'POST',
                body: JSON.stringify({
                    model: vehicle.model
                })
            });
        });
        container.appendChild(div);
    });
}

// Search functionality
document.getElementById('vehicleSearch').addEventListener('input', (e) => {
    const searchTerm = e.target.value.toLowerCase();
    const currentVehicles = vehicles[currentCategory];
    
    if (!currentVehicles) return;

    const filtered = currentVehicles.filter(vehicle => 
        vehicle.name.toLowerCase().includes(searchTerm)
    );
    renderVehicleList(filtered);
});

// Close on ESC
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
});

// Helper function to handle NUI focus
function SetNuiFocus(hasFocus) {
    fetch(`https://${GetParentResourceName()}/setNuiFocus`, {
        method: 'POST',
        body: JSON.stringify({ hasFocus })
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'setDisplay') {
        const menu = document.getElementById('carspawner-menu');
        menu.style.display = data.display ? 'flex' : 'none';

        if (data.display) {
            vehicles = data.vehicles;
            currentCategory = data.currentCategory;
            
            // Render categories
            renderCategories(data.categories);
            
            // Render initial vehicle list
            if (vehicles[currentCategory]) {
                renderVehicleList(vehicles[currentCategory]);
            }
        }
    }
});

function renderCategories(categories) {
    const container = document.querySelector('.categories');
    if (!container) return;
    
    container.innerHTML = '';

    Object.entries(categories).forEach(([key, name]) => {
        const div = document.createElement('div');
        div.className = 'category';
        if (key === currentCategory) {
            div.classList.add('active');
        }
        div.textContent = name;
        div.dataset.category = key;

        div.addEventListener('click', () => {
            // Update active state
            document.querySelectorAll('.category').forEach(cat => 
                cat.classList.remove('active'));
            div.classList.add('active');
            
            // Update current category
            currentCategory = key;
            
            // Render vehicles for this category
            if (vehicles[key]) {
                renderVehicleList(vehicles[key]);
            }
        });

        container.appendChild(div);
    });
}

function renderVehicleList(categoryVehicles) {
    const container = document.querySelector('.vehicle-list');
    if (!container) return;
    
    container.innerHTML = '';

    if (!categoryVehicles) return;

    categoryVehicles.forEach(vehicle => {
        const div = document.createElement('div');
        div.className = 'vehicle-item';
        div.textContent = vehicle.name;
        div.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
                method: 'POST',
                body: JSON.stringify({ model: vehicle.model })
            });
        });
        container.appendChild(div);
    });
}

// Search functionality
const searchInput = document.getElementById('vehicleSearch');
if (searchInput) {
    searchInput.addEventListener('input', (e) => {
        const searchTerm = e.target.value.toLowerCase();
        if (!vehicles[currentCategory]) return;

        const filtered = vehicles[currentCategory].filter(vehicle => 
            vehicle.name.toLowerCase().includes(searchTerm));
        renderVehicleList(filtered);
    });
}

// Close on ESC
document.addEventListener('keyup', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    }
});

// Quick Actions
document.querySelectorAll('.action-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/quickAction`, {
            method: 'POST',
            body: JSON.stringify({
                action: btn.dataset.action
            })
        });
    });
});

function updatePerformanceStats() {
    fetch(`https://${GetParentResourceName()}/getPerformanceStats`, {
        method: 'POST'
    })
    .then(resp => resp.json())
    .then(response => {
        if (response.success) {
            Object.entries(response.stats).forEach(([stat, value]) => {
                const bar = document.querySelector(`#${stat}Bar div`);
                if (bar) {
                    bar.style.width = `${value}%`;
                }
            });
        }
    });
}

function renderModifications(mods) {
    const container = document.querySelector('.mod-options');
    container.innerHTML = '';

    Object.entries(mods).forEach(([type, data]) => {
        const section = document.createElement('div');
        section.className = 'mod-section';
        section.innerHTML = `
            <h3>${data.name}</h3>
            <div class="mod-levels"></div>
        `;

        const levels = section.querySelector('.mod-levels');
        for (let i = -1; i <= data.max; i++) {
            const level = document.createElement('div');
            level.className = 'mod-level';
            level.textContent = i === -1 ? 'Stock' : `Level ${i + 1}`;
            level.classList.toggle('active', i === data.current);
            level.addEventListener('click', () => {
                fetch(`https://${GetParentResourceName()}/applyMod`, {
                    method: 'POST',
                    body: JSON.stringify({
                        modType: type,
                        modIndex: i
                    })
                });
            });
            levels.appendChild(level);
        }

        container.appendChild(section);
    });
}

function loadLiveries() {
    fetch(`https://${GetParentResourceName()}/loadLiveries`, {
        method: 'POST'
    })
    .then(resp => resp.json())
    .then(response => {
        if (response.success) {
            renderLiveries(response.current, response.total, response.customLiveries);
        }
    });
}

function renderLiveries(current, total, customLiveries) {
    const container = document.querySelector('.livery-list');
    if (!container) return;

    container.innerHTML = '';
    
    // Add stock option
    const stockDiv = document.createElement('div');
    stockDiv.className = 'livery-item' + (current === -1 ? ' active' : '');
    stockDiv.textContent = 'Stock';
    stockDiv.addEventListener('click', () => {
        document.querySelectorAll('.livery-item').forEach(item => 
            item.classList.remove('active'));
        stockDiv.classList.add('active');
        fetch(`https://${GetParentResourceName()}/applyLivery`, {
            method: 'POST',
            body: JSON.stringify({ liveryId: -1 })
        });
    });
    container.appendChild(stockDiv);

    // Add available liveries
    for (let i = 0; i < total; i++) {
        const div = document.createElement('div');
        div.className = 'livery-item' + (i === current ? ' active' : '');
        div.textContent = customLiveries && customLiveries[i] 
            ? `Custom Livery ${customLiveries[i]}` 
            : `Livery ${i + 1}`;
        div.dataset.id = i;
        div.addEventListener('click', () => {
            document.querySelectorAll('.livery-item').forEach(item => 
                item.classList.remove('active'));
            div.classList.add('active');
            fetch(`https://${GetParentResourceName()}/applyLivery`, {
                method: 'POST',
                body: JSON.stringify({ liveryId: i })
            });
        });
        container.appendChild(div);
    }
}

function loadExtras() {
    fetch(`https://${GetParentResourceName()}/loadExtras`, {
        method: 'POST'
    })
    .then(resp => resp.json())
    .then(response => {
        if (response.success) {
            renderExtras(response.extras);
        }
    });
}

function renderExtras(extras) {
    const container = document.querySelector('.extras-list');
    if (!container) return;

    container.innerHTML = '';
    Object.entries(extras).forEach(([id, data]) => {
        const div = document.createElement('div');
        div.className = 'extra-item' + (data.enabled ? ' active' : '');
        div.textContent = `Extra ${id}`;
        div.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/toggleExtra`, {
                method: 'POST',
                body: JSON.stringify({ extraId: parseInt(id) })
            });
            div.classList.toggle('active');
        });
        container.appendChild(div);
    });
}

// Add this after your existing event listeners
document.querySelector('.close-button').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
});

// Remove all other close-related code and add this at the top level:
function closeMenu() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

// Single event listener for all messages
window.addEventListener('message', (event) => {
    const data = event.data;

    switch(data.type) {
        case 'setDisplay':
            const menu = document.getElementById('carspawner-menu');
            menu.style.display = data.display ? 'flex' : 'none';
            if (data.display) {
                // Only update these when opening menu
                vehicles = data.vehicles || {};
                currentCategory = data.currentCategory;
                renderCategories(data.categories);
                renderVehicleList(vehicles[currentCategory]);
            }
            break;
    }
});

// Initialize UI
document.addEventListener('DOMContentLoaded', () => {
    // Add single dedicated close button handler
    const closeButton = document.getElementById('closeButton');
    if (closeButton) {
        closeButton.addEventListener('click', () => {
            console.log('Close button clicked');
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                body: JSON.stringify({})
            });
        });
    }
});