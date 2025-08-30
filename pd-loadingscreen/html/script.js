const config = {
    videoId: 'yz3VUMpdjfE'
};

let player;
let isInitialized = false;
let totalResources = 0;

// Initialize the loading screen
const handlers = {
    initializeLoadingScreen: (data) => {
        if (data.serverName) {
            document.getElementById('server-name').textContent = data.serverName;
        }
        if (data.logoUrl) {
            const logoImg = document.querySelector('.logo');
            logoImg.onerror = () => {
                logoImg.src = 'images/logo.png'; // Fallback to local logo
            };
            logoImg.src = data.logoUrl;
        }
        if (data.totalResources) {
            totalResources = data.totalResources;
        }
    },

    onFileStart: (data) => {
        // Update progress bar
        const progress = Math.min(Math.max(data.progress, 0), 100);
        document.getElementById('progress').style.width = `${progress}%`;
        document.getElementById('percentage').textContent = `${Math.round(progress)}%`;
        
        // Update loading text with status
        if (data.fileName) {
            const status = data.status === 'starting' ? 'Starting' : 'Loading';
            document.getElementById('status-text').textContent = 
                `${status}: ${data.fileName} (${data.current}/${data.total})`;
        }

        // Handle completion
        if (progress >= 100) {
            setTimeout(() => {
                fetch(`https://${GetParentResourceName()}/loadingComplete`, {
                    method: 'POST',
                    body: JSON.stringify({})
                });
            }, 1000);
        }
    },

    onServerDataReceived: (data) => {
        if (data.serverName) {
            document.getElementById('server-name').textContent = data.serverName;
        }
    }
};

// Initialize YouTube player
function onYouTubeIframeAPIReady() {
    player = new YT.Player('video-container', {
        videoId: config.videoId,
        playerVars: {
            autoplay: 1,
            controls: 0,
            disablekb: 1,
            modestbranding: 1,
            loop: 1,
            playlist: config.videoId,
            mute: 1
        },
        events: {
            onReady: (event) => {
                event.target.playVideo();
                isInitialized = true;
            },
            onStateChange: (event) => {
                if (event.data === YT.PlayerState.ENDED) {
                    event.target.playVideo();
                }
            },
            onError: (event) => {
                console.error('YouTube Player Error:', event.data);
            }
        }
    });
}

// Message handler
window.addEventListener('message', (e) => {
    const handler = handlers[e.data.eventName];
    if (handler) {
        handler(e.data);
    }
});

// Error handling
window.addEventListener('error', (e) => {
    console.error('Loading Screen Error:', e.message);
});