
// Robustly initialize browser app UI only when loaded into the DOM
function initBrowserApp() {
  const urlInput = document.getElementById('browser-url');
  const goBtn = document.getElementById('browser-go');
  const frame = document.getElementById('browser-frame');
  const menuBtn = document.getElementById('browser-menu');
  const menuPopup = document.getElementById('browser-menu-popup');
  const bookmarksDiv = document.getElementById('browser-bookmarks');
  if (!urlInput || !goBtn || !frame || !menuBtn || !menuPopup || !bookmarksDiv) return;

  // List of iframe-compatible bookmarks
  const bookmarks = [
    { name: 'Wikipedia', url: 'https://en.wikipedia.org' },
    { name: 'DuckDuckGo Lite', url: 'https://lite.duckduckgo.com' },
    { name: 'CodePen', url: 'https://codepen.io' },
    { name: 'JSFiddle', url: 'https://jsfiddle.net' },
    { name: 'W3Schools', url: 'https://www.w3schools.com' },
    { name: 'StackBlitz', url: 'https://stackblitz.com' },
    { name: 'OpenStreetMap', url: 'https://www.openstreetmap.org/export/embed.html' },
    { name: 'Twitch (embed)', url: 'https://player.twitch.tv/?channel=monstercat&parent=localhost' },
    { name: 'Vimeo (embed)', url: 'https://player.vimeo.com/video/76979871' },
    { name: 'SoundCloud (embed)', url: 'https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/293' },
    { name: 'Archive.org', url: 'https://archive.org' }
  ];

  function showError(url) {
    frame.style.display = 'none';
    let errorDiv = document.getElementById('browser-error');
    if (!errorDiv) {
      errorDiv = document.createElement('div');
      errorDiv.id = 'browser-error';
      errorDiv.className = 'browser-error';
      frame.parentNode.appendChild(errorDiv);
    }
    errorDiv.innerHTML = `<div style='color:#fff;text-align:center;padding:32px 12px;'><b>Error: Cannot display content</b><br>Reason: iframe blocked by <span style='color:#90caf9;'>${url}</span></div>`;
    errorDiv.style.display = 'block';
  }

  function hideError() {
    let errorDiv = document.getElementById('browser-error');
    if (errorDiv) errorDiv.style.display = 'none';
    frame.style.display = 'block';
  }

  function navigate(url) {
    if (!url) url = urlInput.value.trim();
    if (!url) return;
    if (!/^https?:\/\//i.test(url)) url = 'https://' + url;
    urlInput.value = url;
    hideError();
    frame.src = url;
    setTimeout(() => {
      try {
        const test = frame.contentWindow.location.href;
      } catch (e) {
        showError(url);
      }
    }, 1200);
  }

  goBtn.onclick = () => navigate();
  urlInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') navigate();
  });

  // Menu button logic
  menuBtn.onclick = function(e) {
    e.stopPropagation();
    menuPopup.style.display = menuPopup.style.display === 'block' ? 'none' : 'block';
  };
  document.body.addEventListener('click', function() {
    menuPopup.style.display = 'none';
  });
  menuPopup.onclick = function(e) { e.stopPropagation(); };

  // Populate bookmarks
  bookmarksDiv.innerHTML = '';
  bookmarks.forEach(bm => {
    const a = document.createElement('a');
    a.className = 'browser-bookmark-link';
    a.textContent = bm.name;
    a.href = '#';
    a.onclick = function(ev) {
      ev.preventDefault();
      menuPopup.style.display = 'none';
      navigate(bm.url);
    };
    bookmarksDiv.appendChild(a);
  });

  // Menu actions
  menuPopup.querySelectorAll('.browser-menu-action').forEach(item => {
    item.onclick = function() {
      const action = item.getAttribute('data-action');
      menuPopup.style.display = 'none';
      if (action === 'refresh') {
        frame.src = frame.src;
      } else if (action === 'home') {
        urlInput.value = '';
        frame.src = 'about:blank';
      } else if (action === 'settings') {
        alert('Settings coming soon!');
      } else if (action === 'about') {
        alert('PD Phone Browser\nSupports iframe-friendly sites.');
      }
    };
  });
}

// Robustly re-init on every app load
window.addEventListener('phoneAppLoaded', function(e) {
  if (e.detail && e.detail.appId === 'browser') {
    setTimeout(initBrowserApp, 0);
  }
});
