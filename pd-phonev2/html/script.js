console.log('script.js loaded');
// --- Phone Navigation Bar Logic ---
function resetPhoneUI() {
    // Hide all app screens, modals, and reset app-specific state
    // Instead of clearing innerHTML, fire a cleanup event for the current app
    window.dispatchEvent(new CustomEvent('phoneAppCleanup'));
    document.getElementById('app-screen').style.display = 'none';
    document.getElementById('app-grid').style.display = 'flex';
}
window.addEventListener('DOMContentLoaded', () => {
    // Home button: return to app grid and reset everything
    document.getElementById('nav-home').onclick = () => {
        resetPhoneUI();
        loadApps(); // Reload the app grid and reset all app state
    };
    // Back button: go one step back in the current app (handled in each app)
    document.getElementById('nav-back').onclick = () => {
        // Each app should handle its own back logic
        const backEvent = new CustomEvent('phoneBackButton');
        window.dispatchEvent(backEvent);
    };
    // Running Apps button: (future) show running apps modal
    document.getElementById('nav-apps').onclick = () => {
        alert('Running apps feature coming soon!');
    };
});
// Modular phone app loader
console.log('script.js loaded');
let phoneVisible = false;

let loadedApps = [];
let homeLayout = [];
let folders = {};
let dragApp = null;
let dragOverFolder = null;


window.addEventListener('message', function(event) {
    if (event.data.action === 'togglePhone') {
        phoneVisible = !phoneVisible;
        document.getElementById('phone-container').style.display = phoneVisible ? 'block' : 'none';
        if (phoneVisible) {
            renderAppGrid();
        }
    }
});


// Listen for Escape to close phone and notify Lua (let F1 toggle via Lua)
window.addEventListener('keyup', function(event) {
    if (event.key === 'Escape' && phoneVisible) {
        phoneVisible = false;
        document.getElementById('phone-container').style.display = 'none';
        fetch(`https://${GetParentResourceName()}/toggleFocus`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ focus: false })
        });
    }
});


// Dynamically load all app manifests from subfolders in /apps
async function loadApps() {
    console.log('loadApps called');
    const appFolders = ['bank', 'youtube', 'settings', 'browser'];
    const appList = [];
    for (const folder of appFolders) {
        try {
            const resp = await fetch(`appsDirectory/${folder}/manifest.json`);
            if (!resp.ok) throw new Error(`Failed to fetch manifest for ${folder}: ${resp.status}`);
            const manifest = await resp.json();
            manifest._folder = folder;
            appList.push(manifest);
        } catch (err) {
            console.error('Error loading app manifest:', folder, err);
        }
    }
    loadedApps = appList;
    console.log('Loaded apps:', loadedApps);
    // Load home layout from localStorage or default
    const savedLayout = localStorage.getItem('phoneHomeLayout');
    const savedFolders = localStorage.getItem('phoneFolders');
    if(savedLayout) homeLayout = JSON.parse(savedLayout);
    else homeLayout = loadedApps.map(app => ({type:'app', id:app.id}));
    if(savedFolders) folders = JSON.parse(savedFolders);
    else folders = {};
    renderAppGrid();
    console.log('Rendered app grid:', homeLayout);
}


function renderAppGrid() {
    console.log('renderAppGrid called');
    const grid = document.getElementById('app-grid');
    grid.innerHTML = '';
    homeLayout.forEach(item => {
        if(item.type === 'app') {
            const app = loadedApps.find(a => a.id === item.id);
            if(!app) return;
            const icon = document.createElement('div');
            icon.className = 'app-icon';
            icon.draggable = true;
            icon.innerHTML = `<img src="appsDirectory/${app._folder}/${app.icon}"><span class="app-name">${app.name}</span>`;
            icon.onclick = () => openApp(app);
            icon.ondragstart = e => { dragApp = app.id; };
            icon.ondragend = e => { dragApp = null; dragOverFolder = null; };
            icon.ondragover = e => e.preventDefault();
            icon.ondrop = e => {
                if(dragApp && dragApp !== app.id) {
                    createFolder([app.id, dragApp]);
                }
            };
            grid.appendChild(icon);
        } else if(item.type === 'folder') {
            const folder = folders[item.id];
            if(!folder) return;
            const icon = document.createElement('div');
            icon.className = 'folder-icon';
            icon.style.background = folder.color || '#555';
            icon.innerHTML = `<span class="app-name">${folder.name || 'Folder'}</span>`;
            icon.onclick = () => openFolder(item.id);
            icon.ondragover = e => { e.preventDefault(); icon.classList.add('drag-over'); dragOverFolder = item.id; };
            icon.ondragleave = e => { icon.classList.remove('drag-over'); dragOverFolder = null; };
            icon.ondrop = e => {
                if(dragApp && !folder.apps.includes(dragApp)) {
                    folder.apps.push(dragApp);
                    saveLayout();
                    renderAppGrid();
                }
                icon.classList.remove('drag-over');
                dragOverFolder = null;
            };
            grid.appendChild(icon);
        }
    });
}

function createFolder(appIds) {
    // Remove apps from homeLayout
    homeLayout = homeLayout.filter(item => !(item.type==='app' && appIds.includes(item.id)));
    // Create folder
    const folderId = 'folder_' + Date.now();
    folders[folderId] = { name: 'Folder', color: '#555', apps: [...new Set(appIds)] };
    homeLayout.push({type:'folder', id:folderId});
    saveLayout();
    renderAppGrid();
}

function openFolder(folderId) {
    const modal = document.getElementById('folder-modal');
    const content = document.getElementById('folder-content');
    const nameInput = document.getElementById('folder-name');
    const colorInput = document.getElementById('folder-color');
    const appsDiv = document.getElementById('folder-apps');
    const folder = folders[folderId];
    if(!folder) return;
    nameInput.value = folder.name;
    colorInput.value = folder.color;
    appsDiv.innerHTML = '';
    folder.apps.forEach(appId => {
        const app = loadedApps.find(a => a.id === appId);
        if(!app) return;
        const icon = document.createElement('div');
        icon.className = 'app-icon';
    icon.innerHTML = `<img src="appsDirectory/${app._folder}/${app.icon}"><span class="app-name">${app.name}</span>`;
        icon.onclick = () => openApp(app);
        // Drag out of folder
        icon.draggable = true;
        icon.ondragstart = e => { dragApp = app.id; };
        icon.ondragend = e => { dragApp = null; };
        icon.ondragover = e => e.preventDefault();
        icon.ondrop = e => {};
        appsDiv.appendChild(icon);
    });
    // Save on name/color change
    nameInput.oninput = () => { folder.name = nameInput.value; saveLayout(); };
    colorInput.oninput = () => { folder.color = colorInput.value; saveLayout(); renderAppGrid(); };
    // Drag out logic
    appsDiv.ondrop = e => {
        if(dragApp && folder.apps.includes(dragApp)) {
            folder.apps = folder.apps.filter(id => id !== dragApp);
            homeLayout.push({type:'app', id:dragApp});
            saveLayout();
            openFolder(folderId);
            renderAppGrid();
        }
    };
    modal.style.display = 'flex';
    // Close on outside click
    modal.onclick = e => { if(e.target === modal) modal.style.display = 'none'; };
}

function saveLayout() {
    localStorage.setItem('phoneHomeLayout', JSON.stringify(homeLayout));
    localStorage.setItem('phoneFolders', JSON.stringify(folders));
}

function openApp(app) {
    const screen = document.getElementById('app-screen');
    fetch(`appsDirectory/${app._folder}/${app.html}`)
        .then(r => r.text())
        .then(html => {
            screen.innerHTML = html;
            // Optionally load app CSS from app folder
            if(app.css) {
                const link = document.createElement('link');
                link.rel = 'stylesheet';
                link.href = `appsDirectory/${app._folder}/${app.css}`;
                document.head.appendChild(link);
            }
            if(app.js) {
                fetch(`appsDirectory/${app._folder}/${app.js}`)
                    .then(r => r.text())
                    .then(js => {
                        try {
                            // Evaluate the JS in the current context
                            new Function(js)();
                            // Dispatch a custom event for app init
                            window.dispatchEvent(new CustomEvent('phoneAppLoaded', { detail: { appId: app.id } }));
                        } catch (e) {
                            console.error('App JS error:', e);
                        }
                    });
            } else {
                // Still dispatch event for HTML-only apps
                window.dispatchEvent(new CustomEvent('phoneAppLoaded', { detail: { appId: app.id } }));
            }
        });
    screen.style.display = 'block';
    document.getElementById('app-grid').style.display = 'none';
}


// Dynamically list all wallpapers in the wallpapers directory
window.phoneWallpapers = [
    'html/images/wallpapers/wallpaper.jpg'
    // Add more wallpapers here as you add them to the directory
];

window.addEventListener('DOMContentLoaded', loadApps);
