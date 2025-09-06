// --- Modern Settings App Logic ---
window.addEventListener('phoneAppLoaded', function(e) {
  if (!e.detail || e.detail.appId !== 'settings') return;

    const tabBtns = [
        document.getElementById('settings-tab-general'),
        document.getElementById('settings-tab-wallpaper'),
        document.getElementById('settings-tab-sound'),
        document.getElementById('settings-tab-about')
    ];
    const tabContents = [
        document.getElementById('settings-tab-content-general'),
        document.getElementById('settings-tab-content-wallpaper'),
        document.getElementById('settings-tab-content-sound'),
        document.getElementById('settings-tab-content-about')
    ];
    tabBtns.forEach((btn, i) => {
        btn.onclick = () => {
            tabBtns.forEach((b, j) => {
                b.classList.toggle('settings-tab-active', i === j);
                tabContents[j].style.display = i === j ? '' : 'none';
            });
        };
    });
    // Back button
    const backBtn = document.getElementById('settings-back-btn');
    backBtn.onclick = () => {
        document.getElementById('app-screen').style.display = 'none';
        document.getElementById('app-grid').style.display = 'flex';
    };
});
function closeApp() {
    document.getElementById('app-screen').style.display = 'none';
    document.getElementById('app-grid').style.display = 'flex';
}


// Use the global phoneWallpapers array provided by the loader
const wallpapers = window.phoneWallpapers || [];

function loadWallpapers() {
    const container = document.getElementById('wallpaper-options');
    container.innerHTML = '';
    wallpapers.forEach((src, idx) => {
        const img = document.createElement('img');
        img.src = src;
        img.className = 'wallpaper-thumb';
        img.onclick = () => selectWallpaper(idx);
        container.appendChild(img);
    });
}

let selectedWallpaper = 0;
function selectWallpaper(idx) {
    selectedWallpaper = idx;
    document.body.style.setProperty('--phone-wallpaper', `url('${wallpapers[idx]}')`);
}


function saveSettings() {
    localStorage.setItem('phoneWallpaper', selectedWallpaper);
    const volume = document.getElementById('volume-slider').value;
    localStorage.setItem('phoneVolume', volume);
    setPhoneVolume(volume);
    closeApp();
}

function setPhoneVolume(volume) {
    // Set a CSS variable or global JS variable for app volume
    document.body.style.setProperty('--phone-volume', volume);
    // Optionally, set volume on all audio elements
    document.querySelectorAll('audio').forEach(a => a.volume = volume / 100);
}


window.onload = function() {
    loadWallpapers();
    const saved = localStorage.getItem('phoneWallpaper');
    if(saved) selectWallpaper(Number(saved));
    // Volume slider logic
    const slider = document.getElementById('volume-slider');
    const valueSpan = document.getElementById('volume-value');
    const savedVolume = localStorage.getItem('phoneVolume') || '100';
    slider.value = savedVolume;
    valueSpan.textContent = savedVolume;
    setPhoneVolume(savedVolume);
    slider.oninput = function() {
        valueSpan.textContent = slider.value;
        setPhoneVolume(slider.value);
    };
};
