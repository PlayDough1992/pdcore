let components = [];
let props = [];
let currentData = {
    components: {},
    props: {}
};

document.addEventListener('DOMContentLoaded', () => {
    // Initialize event listeners
    initializeListeners();
    
    // Hide menu and modal by default
    const menu = document.getElementById('clothing-menu');
    const modal = document.getElementById('model-selector');
    menu.style.display = 'none';
    modal.style.display = 'none';
    
    // Model selection buttons
    document.querySelectorAll('.model-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            fetch('https://pd-clothing/selectModel', {
                method: 'POST',
                body: JSON.stringify({ model: btn.dataset.model })
            }).then(() => {
                modal.style.display = 'none';
            });
        });
    });
    
    // Create New Character button
    document.querySelector('.create-new').addEventListener('click', () => {
        modal.style.display = 'flex';
    });
});

function initializeListeners() {
    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => switchTab(btn.dataset.tab));
    });



    // Action buttons
    document.getElementById('closeBtn').addEventListener('click', closeMenu);
    document.getElementById('saveBtn').addEventListener('click', closeMenu);
    document.getElementById('resetBtn').addEventListener('click', resetChanges);
}

function switchTab(tabName) {
    // Update active tab button
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabName);
    });

    // Show corresponding tab content
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.toggle('active', content.id === `${tabName}-tab`);
    });
}



function createComponentUI(component) {
    const div = document.createElement('div');
    div.className = 'item-group';
    div.innerHTML = `
        <h3>${component.label}</h3>
        <div class="control-row">
            <span class="control-label">Style</span>
            <div class="slider-control">
                <button class="control-btn minus-btn" data-action="minus">-</button>
                <div class="slider-container">
                    <input type="range" 
                           min="0" 
                           max="${component.maxDrawable}" 
                           value="${currentData.components[component.id]?.drawable || 0}"
                           data-component="${component.id}"
                           class="drawable-slider" />
                    <span class="value">${currentData.components[component.id]?.drawable || 0}</span>
                </div>
                <button class="control-btn plus-btn" data-action="plus">+</button>
            </div>
        </div>
        ${component.hasTextures ? `
        <div class="control-row">
            <span class="control-label">Texture</span>
            <input type="range" 
                   min="0" 
                   max="${component.maxTexture}" 
                   value="${currentData.components[component.id]?.texture || 0}"
                   data-component="${component.id}"
                   class="texture-slider" />
            <span class="value">${currentData.components[component.id]?.texture || 0}</span>
        </div>
        ` : ''}
    `;

    // Add event listeners
    const drawableSlider = div.querySelector('.drawable-slider');
    const valueSpan = div.querySelector('.value');
    
    // Slider event
    drawableSlider.addEventListener('input', (e) => {
        const value = parseInt(e.target.value);
        valueSpan.textContent = value;
        updateComponent(component.id, value, currentData.components[component.id]?.texture || 0);
    });
    
    // Plus/Minus buttons
    div.querySelectorAll('.control-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const currentValue = parseInt(drawableSlider.value);
            const newValue = btn.dataset.action === 'minus' 
                ? Math.max(parseInt(drawableSlider.min), currentValue - 1)
                : Math.min(parseInt(drawableSlider.max), currentValue + 1);
            
            drawableSlider.value = newValue;
            valueSpan.textContent = newValue;
            updateComponent(component.id, newValue, currentData.components[component.id]?.texture || 0);
        });
    });

    if (component.hasTextures) {
        const textureSlider = div.querySelector('.texture-slider');
        textureSlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            e.target.nextElementSibling.textContent = value;
            updateComponent(component.id, currentData.components[component.id]?.drawable || 0, value);
        });
    }

    return div;
}

function createPropUI(prop) {
    const div = document.createElement('div');
    div.className = 'item-group';
    div.innerHTML = `
        <h3>${prop.label}</h3>
        <div class="control-row">
            <span class="control-label">Style</span>
            <div class="slider-control">
                <button class="control-btn minus-btn" data-action="minus">-</button>
                <div class="slider-container">
                    <input type="range" 
                           min="-1" 
                           max="${prop.maxDrawable}" 
                           value="${currentData.props[prop.id]?.drawable || -1}"
                           class="drawable-slider"
                           data-prop="${prop.id}"
                           class="drawable-slider" />
                    <span class="value">${currentData.props[prop.id]?.drawable || -1}</span>
                </div>
                <button class="control-btn plus-btn" data-action="plus">+</button>
            </div>
        </div>
        ${prop.hasTextures ? `
        <div class="control-row">
            <span class="control-label">Texture</span>
            <input type="range" 
                   min="0" 
                   max="${prop.maxTexture}" 
                   value="${currentData.props[prop.id]?.texture || 0}"
                   data-prop="${prop.id}"
                   class="texture-slider" />
            <span class="value">${currentData.props[prop.id]?.texture || 0}</span>
        </div>
        ` : ''}
    `;

    // Add event listeners
    const drawableSlider = div.querySelector('.drawable-slider');
    const valueSpan = div.querySelector('.value');
    
    // Slider event
    drawableSlider.addEventListener('input', (e) => {
        const value = parseInt(e.target.value);
        valueSpan.textContent = value;
        updateProp(prop.id, value, currentData.props[prop.id]?.texture || 0);
    });
    
    // Plus/Minus buttons
    div.querySelectorAll('.control-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const currentValue = parseInt(drawableSlider.value);
            const newValue = btn.dataset.action === 'minus' 
                ? Math.max(parseInt(drawableSlider.min), currentValue - 1)
                : Math.min(parseInt(drawableSlider.max), currentValue + 1);
            
            drawableSlider.value = newValue;
            valueSpan.textContent = newValue;
            updateProp(prop.id, newValue, currentData.props[prop.id]?.texture || 0);
        });
    });

    if (prop.hasTextures) {
        const textureSlider = div.querySelector('.texture-slider');
        textureSlider.addEventListener('input', (e) => {
            const value = parseInt(e.target.value);
            e.target.nextElementSibling.textContent = value;
            updateProp(prop.id, currentData.props[prop.id]?.drawable || -1, value);
        });
    }

    return div;
}

function updateComponent(componentId, drawable, texture) {
    if (!currentData.components[componentId]) {
        currentData.components[componentId] = {};
    }
    currentData.components[componentId].drawable = drawable;
    currentData.components[componentId].texture = texture;

    fetch('https://pd-clothing/updateComponent', {
        method: 'POST',
        body: JSON.stringify({
            component: componentId,
            drawable,
            texture
        })
    });
}

function updateProp(propId, drawable, texture) {
    if (!currentData.props[propId]) {
        currentData.props[propId] = {};
    }
    currentData.props[propId].drawable = drawable;
    currentData.props[propId].texture = texture;

    // Send update to game
    fetch('https://pd-clothing/updateProp', {
        method: 'POST',
        body: JSON.stringify({
            prop: parseInt(propId),
            drawable: parseInt(drawable),
            texture: parseInt(texture)
        })
    });
}

function resetChanges() {
    fetch('https://pd-clothing/resetChanges', {
        method: 'POST'
    }).then(() => {
        // Reset all sliders to original values
        document.querySelectorAll('.drawable-slider, .texture-slider').forEach(slider => {
            const defaultValue = slider.min;
            slider.value = defaultValue;
            slider.nextElementSibling.textContent = defaultValue;
        });
        
        // Reset current data
        currentData = {
            components: {},
            props: {}
        };
    });
}

function closeMenu() {
    const menu = document.getElementById('clothing-menu');
    menu.style.display = 'none';
    
    fetch('https://pd-clothing/closeMenu', {
        method: 'POST'
    });
}

// Message handler from game
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'show') {
        const menu = document.getElementById('clothing-menu');
        menu.style.display = 'flex';
        menu.className = `clothing-menu ${data.position || 'right'}`;
        
        // Store component and prop data
        components = data.components;
        props = data.props;
        currentData = data.currentData || { components: {}, props: {} };
        
        // Create UI elements
        const componentsTab = document.getElementById('components-tab');
        const propsTab = document.getElementById('props-tab');
        
        // Clear existing content
        componentsTab.innerHTML = '';
        propsTab.innerHTML = '';
        
        // Add components
        components.forEach(component => {
            componentsTab.appendChild(createComponentUI(component));
        });
        
        // Add props
        props.forEach(prop => {
            propsTab.appendChild(createPropUI(prop));
        });
        
        // Set default tab and view
        switchTab('components');
        updateCameraView('default');
    }
});
