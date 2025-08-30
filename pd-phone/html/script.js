let phoneVisible = false;

window.addEventListener('message', function(event) {
    if (event.data.action === 'togglePhone') {
        phoneVisible = !phoneVisible;
        document.getElementById('phone-container').style.display = phoneVisible ? 'block' : 'none';
        
        if (!phoneVisible) {
            fetch(`https://${GetParentResourceName()}/toggleFocus`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    focus: false
                })
            });
        }
    }
    if (event.data.action === 'updateBalance') {
        document.getElementById('balance').textContent = `${event.data.balance.toLocaleString()}`;
    }
});

// Add this function before any click event listeners
function hideAllScreens() {
    document.getElementById('app-grid').style.display = 'none';
    document.getElementById('pdb-screen').style.display = 'none';
    document.getElementById('youtube-screen').style.display = 'none';
}

document.getElementById('pdb-app').addEventListener('click', function() {
    document.getElementById('app-grid').style.display = 'none';
    document.getElementById('pdb-screen').style.display = 'block';
    fetch(`https://${GetParentResourceName()}/getBankBalance`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

document.getElementById('youtube-app').addEventListener('click', function() {
    hideAllScreens();
    document.getElementById('youtube-screen').style.display = 'block';
});

document.getElementById('youtube-search-button').addEventListener('click', function() {
    const query = document.getElementById('youtube-search-input').value;
    if (query) {
        fetch(`https://www.googleapis.com/youtube/v3/search?part=snippet&q=${encodeURIComponent(query)}&type=video&maxResults=10&key=AIzaSyDi7IOPHFpQ1hmZR7mpI7jN5x8_BGSdJkI`)
            .then(response => response.json())
            .then(data => {
                if (data.items && data.items.length > 0) {
                    const resultsContainer = document.querySelector('.youtube-results');
                    resultsContainer.innerHTML = '';
                    
                    data.items.forEach(item => {
                        const videoDiv = document.createElement('div');
                        videoDiv.className = 'video-result';
                        videoDiv.innerHTML = `
                            <img src="${item.snippet.thumbnails.default.url}" class="video-thumbnail">
                            <div class="video-info">
                                <div class="video-title">${item.snippet.title}</div>
                                <div class="video-channel">${item.snippet.channelTitle}</div>
                            </div>
                        `;
                        
                        videoDiv.addEventListener('click', () => {
                            document.querySelector('.youtube-results').style.display = 'none';
                            document.querySelector('.youtube-player-container').style.display = 'block';
                            const player = document.getElementById('youtube-player');
                            player.src = `https://www.youtube.com/embed/${item.id.videoId}?rel=0&enablejsapi=1&playsinline=1&fs=0`;
                        });
                        
                        resultsContainer.appendChild(videoDiv);
                    });
                }
            });
    }
});

document.getElementById('youtube-search-input').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        document.getElementById('youtube-search-button').click();
    }
});

// Replace the existing back button listener with this updated version
document.querySelectorAll('.back-button').forEach(button => {
    button.addEventListener('click', function() {
        const playerContainer = document.querySelector('.youtube-player-container');
        const resultsContainer = document.querySelector('.youtube-results');
        if (playerContainer.style.display === 'block') {
            playerContainer.style.display = 'none';
            resultsContainer.style.display = 'block';
            const player = document.getElementById('youtube-player');
            player.src = 'about:blank';
            return;
        }
        // Existing back button logic...
        document.getElementById('app-grid').style.display = 'grid';
        document.getElementById('pdb-screen').style.display = 'none';
        document.getElementById('youtube-screen').style.display = 'none';
    });
});

// Update time every minute
function updateTime() {
    const now = new Date();
    const timeString = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    document.querySelector('.time').textContent = timeString;
}

updateTime();
setInterval(updateTime, 60000);

document.onkeyup = function(event) {
    if (event.key === 'F1' && phoneVisible) {
        fetch(`https://${GetParentResourceName()}/toggleFocus`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                focus: false
            })
        });
        phoneVisible = false;
        document.getElementById('phone-container').style.display = 'none';
    }
};