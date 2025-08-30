let locations = {};

window.addEventListener('message', (event) => {
    const data = event.data;
    console.log('NUI Message received:', data); // Debug log

    if (data.type === "ui") {
        locations = data.locations || {};
        const container = document.getElementById('location-selector');
        
        if (data.status) {
            container.style.display = 'flex';  // Changed to flex when showing
            populateLocations();
        } else {
            container.style.display = 'none';
        }
    } else if (data.type === "showNameInput") {
        document.getElementById('name-input-container').style.display = data.status ? 'flex' : 'none';
    }
});

function populateLocations() {
    const locationsList = document.getElementById('locations-list');
    console.log('Populating locations:', locations); // Debug log
    locationsList.innerHTML = '';

    if (!locations || Object.keys(locations).length === 0) {
        console.log('No locations available');
        return;
    }

    Object.entries(locations).forEach(([id, location]) => {
        const locationElement = document.createElement('div');
        locationElement.className = 'location-item';
        locationElement.innerHTML = `
            <h2>${location.label || 'Unnamed Location'}</h2>
            <p>${location.description || 'No description available'}</p>
        `;
        locationElement.onclick = () => selectLocation(id);
        locationsList.appendChild(locationElement);
    });

    console.log('Populated locations:', Object.keys(locations).length);
}

function selectLocation(locationId) {
    fetch(`https://${GetParentResourceName()}/selectLocation`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            locationId: locationId
        })
    });
}

function saveLocation() {
    const name = document.getElementById('location-name').value;
    if (!name) return;
    
    fetch(`https://${GetParentResourceName()}/saveNewLocation`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            name: name
        })
    });
    
    document.getElementById('name-input-container').style.display = 'none';
    document.getElementById('location-name').value = '';
}

document.onkeyup = function(data) {
    if (data.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
};