function logError(error) {
    console.error('[PD-Appearance]:', error);
    fetch(`https://${GetParentResourceName()}/logError`, {
        method: 'POST',
        body: JSON.stringify({ error: error.toString() })
    });
}

let menuConfig = {
    components: null,
    props: null,
    currentState: {
        components: {},
        props: {}
    }
};

// Listen for NUI messages
window.addEventListener('message', function(event) {
    try {
        const data = event.data;

        if (data.action === "show") {
            if (!data.components || !data.props) {
                throw new Error('Invalid menu data received');
            }

            menuConfig.components = data.components;
            menuConfig.props = data.props;
            document.getElementById('clothing-menu').style.display = 'block';
            setupMenuContent();
        }
    } catch (error) {
        logError(error);
    }
}); // End of message event listener

// Add initial value display setup
function initializeValueDisplays() {
    try {
        document.querySelectorAll('input[type="range"]').forEach(input => {
            updateValueDisplay(input);
        });
    } catch (error) {
        logError('Failed to initialize value displays: ' + error);
    }
}

// Initialize menu content
function setupMenuContent() {
    try {
        // Setup clothing section
        const clothingSection = document.getElementById('clothing-section');
        if (!clothingSection) throw new Error('Clothing section not found');
        clothingSection.innerHTML = '';

        for (const [key, component] of Object.entries(menuConfig.components)) {
            const componentDiv = createComponentElement(component);
            clothingSection.appendChild(componentDiv);
        }

        // Setup props section
        const propsSection = document.getElementById('props-section');
        if (!propsSection) throw new Error('Props section not found');
        propsSection.innerHTML = '';

        for (const [key, prop] of Object.entries(menuConfig.props)) {
            const propDiv = createPropElement(prop);
            propsSection.appendChild(propDiv);
        }

        setupEventListeners();
        initializeValueDisplays();
    } catch (error) {
        logError(error);
    }
}

// Create component UI element
function createComponentElement(component) {
    const div = document.createElement('div');
    div.className = 'component-item';
    div.innerHTML = `
        <h3>${component.name}</h3>
        <div class="control-group">
            <div class="slider-group">
                <label>Style: <span class="value-display">0</span></label>
                <input type="range" 
                       min="${component.min}" 
                       max="${component.max}" 
                       value="0" 
                       data-component="${component.id}">
            </div>
            <div class="slider-group">
                <label>Texture: <span class="value-display">0</span></label>
                <input type="range" 
                       min="0" 
                       max="3" 
                       value="0" 
                       data-texture="${component.id}">
            </div>
        </div>
    `;

    // Track initial state
    menuConfig.currentState.components[component.id] = {
        drawable: 0,
        texture: 0
    };

    return div;
}

// Create prop UI element
function createPropElement(prop) {
    const div = document.createElement('div');
    div.className = 'prop-item';
    div.innerHTML = `
        <h3>${prop.name}</h3>
        <div class="control-group">
            <div class="slider-group">
                <label>Style: <span class="value-display">-1</span></label>
                <input type="range" 
                       min="${prop.min}" 
                       max="${prop.max}" 
                       value="-1" 
                       data-prop="${prop.id}">
            </div>
            <div class="slider-group">
                <label>Texture: <span class="value-display">0</span></label>
                <input type="range" 
                       min="0" 
                       max="3" 
                       value="0" 
                       data-texture="${prop.id}">
            </div>
        </div>
    `;

    // Track initial state
    menuConfig.currentState.props[prop.id] = {
        drawable: -1,
        texture: 0
    };

    return div;
}

// Setup all event listeners
function setupEventListeners() {
    // Category switching
    document.querySelectorAll('.category').forEach(cat => {
        cat.onclick = function() {
            document.querySelectorAll('.category').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
            
            this.classList.add('active');
            document.getElementById(`${this.dataset.category}-section`).classList.add('active');
        };
    });

    // Camera controls
    document.querySelectorAll('.cam-btn').forEach(btn => {
        btn.onclick = function() {
            fetch(`https://${GetParentResourceName()}/updateView`, {
                method: 'POST',
                body: JSON.stringify({
                    view: this.dataset.view
                })
            });
        };
    });

    // Component changes
    document.querySelectorAll('input[data-component]').forEach(input => {
        input.oninput = function() {
            const textureInput = this.parentElement.querySelector(`input[data-texture="${this.dataset.component}"]`);
            fetch(`https://${GetParentResourceName()}/updateComponent`, {
                method: 'POST',
                body: JSON.stringify({
                    component: parseInt(this.dataset.component),
                    drawable: parseInt(this.value),
                    texture: parseInt(textureInput.value)
                })
            });
        };
    });

    // Prop changes
    document.querySelectorAll('input[data-prop]').forEach(input => {
        input.oninput = function() {
            const textureInput = this.parentElement.querySelector(`input[data-texture="${this.dataset.prop}"]`);
            fetch(`https://${GetParentResourceName()}/updateProp`, {
                method: 'POST',
                body: JSON.stringify({
                    prop: parseInt(this.dataset.prop),
                    drawable: parseInt(this.value),
                    texture: parseInt(textureInput.value)
                })
            });
        };
    });

    // Texture changes for components
    document.querySelectorAll('input[data-texture]').forEach(input => {
        input.oninput = function() {
            const parentGroup = this.parentElement;
            const componentInput = parentGroup.querySelector('input[data-component]');
            const propInput = parentGroup.querySelector('input[data-prop]');

            if (componentInput) {
                fetch(`https://${GetParentResourceName()}/updateComponent`, {
                    method: 'POST',
                    body: JSON.stringify({
                        component: parseInt(componentInput.dataset.component),
                        drawable: parseInt(componentInput.value),
                        texture: parseInt(this.value)
                    })
                });
            } else if (propInput) {
                fetch(`https://${GetParentResourceName()}/updateProp`, {
                    method: 'POST',
                    body: JSON.stringify({
                        prop: parseInt(propInput.dataset.prop),
                        drawable: parseInt(propInput.value),
                        texture: parseInt(this.value)
                    })
                });
            }
        };
    });

    // Save button
    document.getElementById('saveBtn').onclick = function() {
        fetch(`https://${GetParentResourceName()}/saveOutfit`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    };

    // Reset button
    document.getElementById('resetBtn').onclick = function() {
        fetch(`https://${GetParentResourceName()}/resetOutfit`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    };

    // Close button
    document.getElementById('closeBtn').onclick = function() {
        try {
            document.getElementById('clothing-menu').style.display = 'none';
            cleanupMenu();
            fetch(`https://${GetParentResourceName()}/closeMenu`, {
                method: 'POST'
            });
        } catch (error) {
            logError(error);
        }
    };

    // Character rotation
    let isDragging = false;
    let lastX = 0;
    let currentHeading = 0;

    document.addEventListener('mousedown', function(e) {
        if (e.button === 0) {  // Left click only
            isDragging = true;
            lastX = e.clientX;
        }
    });

    document.addEventListener('mouseup', function() {
        isDragging = false;
    });

    document.addEventListener('mousemove', function(e) {
        if (!isDragging) return;
        
        const delta = (e.clientX - lastX) * 0.5;
        currentHeading = (currentHeading + delta) % 360;
        
        fetch(`https://${GetParentResourceName()}/rotateCharacter`, {
            method: 'POST',
            body: JSON.stringify({ 
                heading: currentHeading,
                delta: delta 
            })
        });
        
        lastX = e.clientX;
    });

    // Update value displays for all inputs
    document.querySelectorAll('input[type="range"]').forEach(input => {
        input.addEventListener('input', function() {
            updateValueDisplay(this);
        });
    });
}

function updateValueDisplay(input) {
    const displayElement = input.parentElement.querySelector('.value-display');
    if (displayElement) {
        displayElement.textContent = input.value;
    }
}

// Add cleanup function
function cleanupMenu() {
    menuConfig.currentState = {
        components: {},
        props: {}
    };
    isDragging = false;
    lastX = 0;
    currentHeading = 0;
}