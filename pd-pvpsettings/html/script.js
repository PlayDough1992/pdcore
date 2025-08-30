window.addEventListener('message', function(event) {
    if (event.data.type === 'showUI') {
        document.getElementById('settings-container').classList.remove('hidden');
        document.getElementById('pvp-toggle').checked = event.data.pvpEnabled;
    } else if (event.data.type === 'hideUI') {
        document.getElementById('settings-container').classList.add('hidden');
    }
});

document.getElementById('pvp-toggle').addEventListener('change', function(e) {
    fetch(`https://${GetParentResourceName()}/updatePvPSetting`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            pvpEnabled: e.target.checked
        })
    });
});

document.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST'
        });
        document.getElementById('settings-container').classList.add('hidden');
    }
});