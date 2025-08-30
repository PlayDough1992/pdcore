let inventory = {};
let isDragging = false;
let draggedItem = null;
let config = {
    maxWeight: 50,
    maxSlots: 50,
    hotbarSlots: 9
};

// Event Listeners
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.type) {
        case 'updateInventory':
            updateInventoryDisplay(data.inventory);
            break;
            
        case 'setHotbarVisible':
            const hotbar = document.getElementById('hotbar');
            hotbar.style.display = data.status ? 'block' : 'none';
            // Don't update inventory here
            break;
            
        case 'setVisible':
            const container = document.getElementById('inventory-container');
            container.style.display = data.status ? 'flex' : 'none';
            if (data.inventory) {
                updateInventoryDisplay(data.inventory);
            }
            break;
    }
});

// Generate slots dynamically
function generateSlots() {
    const hotbarWrapper = document.querySelector('.hotbar-wrapper');
    const inventorySlots = document.querySelector('.inventory-slots');
    
    // Generate hotbar slots (1-9)
    for (let i = 1; i <= 9; i++) {
        const slot = document.createElement('div');
        slot.className = 'slot';
        slot.dataset.slot = i;
        slot.dataset.hotbar = true;
        slot.addEventListener('dragover', handleDragOver);
        slot.addEventListener('drop', handleDrop);
        hotbarWrapper.appendChild(slot);
    }
    
    // Generate inventory slots (1-50)
    for (let i = 1; i <= 50; i++) {
        const slot = document.createElement('div');
        slot.className = 'slot';
        slot.dataset.slot = i;
        slot.addEventListener('dragover', handleDragOver);
        slot.addEventListener('drop', handleDrop);
        slot.addEventListener('contextmenu', showContextMenu);
        inventorySlots.appendChild(slot);
    }
}

function updateInventoryDisplay(items) {
    // Store current inventory state after deduplicating weapons
    const deduplicatedItems = {};
    const weaponSlots = new Set();
    
    // First pass - find all weapons and their first occurrence
    Object.entries(items).forEach(([slot, item]) => {
        if (item && item.weapon) {
            const existingSlot = Array.from(weaponSlots).find(s => 
                items[s].name === item.name
            );
            
            if (!existingSlot) {
                weaponSlots.add(slot);
                deduplicatedItems[slot] = item;
            }
        } else if (item) {
            deduplicatedItems[slot] = item;
        }
    });
    
    // Update global inventory state
    inventory = deduplicatedItems;
    
    // Clear all existing items
    const allSlots = document.querySelectorAll('.slot');
    allSlots.forEach(slot => {
        while (slot.firstChild) {
            slot.firstChild.remove();
        }
    });
    
    // Add items to slots
    Object.entries(deduplicatedItems).forEach(([slot, item]) => {
        if (!item) return;
        
        const itemElement = createItemElement(item);
        const slotNum = parseInt(slot);
        
        // Add to hotbar if it's a valid hotbar slot (1-9)
        if (slotNum <= 9) {
            const hotbarSlot = document.querySelector(`.slot[data-hotbar][data-slot="${slot}"]`);
            if (hotbarSlot) {
                const clone = itemElement.cloneNode(true);
                clone.addEventListener('dragstart', handleDragStart);
                clone.addEventListener('dragend', handleDragEnd);
                clone.addEventListener('mouseenter', showTooltip);
                clone.addEventListener('mouseleave', hideTooltip);
                hotbarSlot.appendChild(clone);
            }
        }
        
        // Add to inventory slot
        const invSlot = document.querySelector(`.inventory-slots .slot[data-slot="${slot}"]`);
        if (invSlot) {
            itemElement.addEventListener('dragstart', handleDragStart);
            itemElement.addEventListener('dragend', handleDragEnd);
            itemElement.addEventListener('mouseenter', showTooltip);
            itemElement.addEventListener('mouseleave', hideTooltip);
            invSlot.appendChild(itemElement);
        }
    });
    
    updateWeightBar();
}

function createItemElement(item) {
    const itemElement = document.createElement('div');
    itemElement.className = 'slot-item';
    itemElement.draggable = true;
    
    const spriteClass = item.weapon ? 'weapon-sprite' : 'item-sprite';
    // Updated path to use images folder
    const spritePath = item.weapon ? 
        `images/weapons/${item.name.toLowerCase()}.png` : 
        `images/items/${item.name.toLowerCase()}.png`;
    
    console.log('Loading sprite:', spritePath);
    
    itemElement.innerHTML = `
        <div class="${spriteClass}" style="background-image: url('${spritePath}')"></div>
        ${item.quantity > 1 ? `<span class="quantity">${item.quantity}</span>` : ''}
    `;
    
    itemElement.addEventListener('dragstart', handleDragStart);
    itemElement.addEventListener('dragend', handleDragEnd);
    itemElement.addEventListener('mouseenter', showTooltip);
    itemElement.addEventListener('mouseleave', hideTooltip);
    
    return itemElement;
}

// Drag and Drop Handlers
function handleDragStart(e) {
    e.stopPropagation();
    isDragging = true;
    draggedItem = e.target;
    e.target.classList.add('dragging');
}

function handleDragEnd(e) {
    const draggedItem = e.target;
    draggedItem.classList.remove('dragging');
    
    // If dropped outside of a valid slot
    if (!e.target.closest('.slot')) {
        const slot = draggedItem.closest('.slot').dataset.slot;
        
        // Notify server of item drop
        fetch(`https://${GetParentResourceName()}/itemDropped`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                slot: slot
            })
        });
        
        // Remove item from UI
        draggedItem.remove();
    }
}

function handleDragOver(e) {
    e.preventDefault();
    if (!isDragging) return;
    e.currentTarget.classList.add('drag-over');
}

function handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const fromSlot = draggedItem.closest('.slot').dataset.slot;
    const toSlot = e.currentTarget.dataset.slot;
    
    if (fromSlot === toSlot) return;
    
    // Send move request to client
    fetch(`https://${GetParentResourceName()}/moveItem`, {
        method: 'POST',
        body: JSON.stringify({
            fromSlot: fromSlot,
            toSlot: toSlot
        })
    });
}

// Tooltip Handlers
function showTooltip(e) {
    const tooltip = document.getElementById('item-tooltip');
    const slotElement = e.target.closest('.slot');
    const slot = slotElement.dataset.slot;
    const item = inventory[slot];
    
    if (item) {
        tooltip.innerHTML = `
            <h3>${item.label || item.name}</h3>
            <p>${item.description || ''}</p>
            ${item.weapon ? '<p>Press corresponding number key to equip</p>' : ''}
        `;
        
        tooltip.style.display = 'block';
        
        // Position tooltip near mouse but keep in viewport
        const x = Math.min(e.pageX + 10, window.innerWidth - tooltip.offsetWidth - 10);
        const y = Math.min(e.pageY + 10, window.innerHeight - tooltip.offsetHeight - 10);
        
        tooltip.style.left = `${x}px`;
        tooltip.style.top = `${y}px`;
        
        console.log('^2[DEBUG]^7 Showing tooltip for item:', item);
    }
}

function hideTooltip() {
    document.getElementById('item-tooltip').style.display = 'none';
}

// Context Menu
function showContextMenu(e) {
    e.preventDefault();
    const slot = e.currentTarget;
    const item = inventory[slot.dataset.slot];
    if (!item) return;
    
    const contextMenu = document.createElement('div');
    contextMenu.className = 'context-menu';
    contextMenu.innerHTML = `
        <div class="context-item" onclick="useItem('${slot.dataset.slot}')">Use</div>
        <div class="context-item" onclick="dropItem('${slot.dataset.slot}')">Drop</div>
        ${!slot.dataset.hotbar ? 
            `<div class="context-item" onclick="moveToHotbar('${slot.dataset.slot}')">Move to Hotbar</div>` : 
            `<div class="context-item" onclick="removeFromHotbar('${slot.dataset.slot}')">Remove from Hotbar</div>`}
    `;
    
    document.body.appendChild(contextMenu);
    
    // Position menu
    const x = Math.min(e.pageX, window.innerWidth - contextMenu.offsetWidth - 5);
    const y = Math.min(e.pageY, window.innerHeight - contextMenu.offsetHeight - 5);
    
    contextMenu.style.left = `${x}px`;
    contextMenu.style.top = `${y}px`;
    
    // Remove menu when clicking outside
    function removeMenu(e) {
        if (!contextMenu.contains(e.target)) {
            contextMenu.remove();
            document.removeEventListener('click', removeMenu);
        }
    }
    
    document.addEventListener('click', removeMenu);
}

function updateDropOnDeath(enabled) {
    document.getElementById('dropOnDeath').checked = enabled;
}

function updateWeightBar() {
    let totalWeight = 0;
    Object.values(inventory).forEach(item => {
        if (item && item.weight) {
            totalWeight += item.weight * (item.quantity || 1);
        }
    });
    
    const percentage = (totalWeight / config.maxWeight) * 100;
    const weightFill = document.getElementById('weight-fill');
    const weightText = document.getElementById('weight-text');
    
    weightFill.style.width = `${Math.min(percentage, 100)}%`;
    weightText.textContent = `${totalWeight.toFixed(1)}/${config.maxWeight}`;
    
    weightFill.className = 'weight-fill ' + 
        (percentage > 90 ? 'full' : percentage > 75 ? 'warning' : '');
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    generateSlots();
    
    // Close inventory on Escape
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            fetch(`https://${GetParentResourceName()}/closeInventory`, {
                method: 'POST'
            });
        }
    });
});