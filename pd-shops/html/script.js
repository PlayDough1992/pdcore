let currentShop = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === "openShop") {
        currentShop = data.shop;
        document.getElementById('shop-container').classList.remove('hidden');
        loadCategory('weapons');
    }
});

document.querySelectorAll('.category-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        document.querySelectorAll('.category-btn').forEach(b => b.classList.remove('active'));
        e.target.classList.add('active');
        loadCategory(e.target.dataset.category);
    });
});

function loadCategory(category) {
    const container = document.getElementById('itemsList');
    container.innerHTML = '';
    
    currentShop.items[category].forEach(item => {
        const itemCard = document.createElement('div');
        itemCard.className = 'item-card';
        itemCard.innerHTML = `
            <h3>${item.label}</h3>
            <div class="item-price">$${item.price}</div>
            <button class="buy-btn" onclick="purchaseItem('${category}', '${item.name}')">
                Purchase
            </button>
        `;
        container.appendChild(itemCard);
    });
}

function purchaseItem(category, itemName) {
    const item = currentShop.items[category].find(i => i.name === itemName);
    if (item) {
        fetch(`https://${GetParentResourceName()}/purchaseItem`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                type: category,
                ...item
            })
        });
        
        // Add visual feedback without relying on event.target
        const button = document.querySelector(`button[data-item="${itemName}"]`);
        if (button) {
            button.style.backgroundColor = '#27ae60';
            setTimeout(() => {
                button.style.backgroundColor = '';
            }, 200);
        }
    }
}

// Update close shop function
document.getElementById('closeShop').addEventListener('click', () => {
    document.getElementById('shop-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeShop`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

// Handle ESC key
document.addEventListener('keyup', function(event) {
    if (event.keyCode === 27) {
        document.getElementById('closeShop').click();
    }
});