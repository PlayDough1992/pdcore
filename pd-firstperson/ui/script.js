let settings = {};

// Initialize menu as hidden on page load
document.addEventListener('DOMContentLoaded', function() {
    document.querySelector('.settings-menu').style.display = 'none';
});

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'toggleMenu') {
        settings = data.settings || settings;
        document.querySelector('.settings-menu').style.display = data.show ? 'block' : 'none';
        if (data.show) updateUI();
    }
});

function updateUI() {
    document.getElementById('fov').value = settings.fov || 80;
    document.getElementById('blur').checked = settings.effects?.blur?.enabled || false;
    document.getElementById('bloom').checked = settings.effects?.bloom?.enabled || false;
    document.getElementById('aimAssist').checked = settings.aimAssist || false;
    
    // Update FOV value display
    document.querySelector('#fov + .value').textContent = settings.fov || 80;
}

function saveSettings() {
    settings = {
        ...settings,
        fov: parseInt(document.getElementById('fov').value),
        effects: {
            blur: { enabled: document.getElementById('blur').checked },
            bloom: { enabled: document.getElementById('bloom').checked }
        },
        aimAssist: document.getElementById('aimAssist').checked
    };
    
    fetch(`https://${GetParentResourceName()}/updateSettings`, {
        method: 'POST',
        body: JSON.stringify(settings)
    });
}

function closeMenu() {
    document.querySelector('.settings-menu').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST'
    });
}

// Event listeners
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

document.querySelectorAll('input').forEach(input => {
    input.addEventListener('change', saveSettings);
});