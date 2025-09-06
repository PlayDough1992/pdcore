// --- Google OAuth 2.0 Sign-In Integration ---
const GOOGLE_CLIENT_ID = '231818001425-99jdbcbin7gadc7m1m5cf10ssker53ed.apps.googleusercontent.com';
const GOOGLE_CLIENT_SECRET = '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';
const GOOGLE_REDIRECT_URI = 'http://localhost:3000/oauth2callback'; // Change if needed
const GOOGLE_SCOPE = 'https://www.googleapis.com/auth/youtube.force-ssl';

function openGoogleSignIn() {
    const clientId = '231818001425-99jdbcbin7gadc7m1m5cf10ssker53ed.apps.googleusercontent.com';
    const redirectUri = 'http://localhost:3001/oauth-callback';
    const scope = 'https://www.googleapis.com/auth/youtube.readonly https://www.googleapis.com/auth/youtube.force-ssl';
    const state = Math.random().toString(36).substring(2);
    // Get player ID from NUI (FiveM provides this via a global or NUI callback)
    fetch('https://pd-phonev2/getPlayerId', { method: 'POST' })
        .then(res => res.json())
        .then(data => {
            const fivemid = data.playerId || '';
            const oauthUrl = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&response_type=code&scope=${encodeURIComponent(scope)}&state=${state}&access_type=online&prompt=consent&fivemid=${fivemid}`;
            fetch('https://pd-phonev2/openExternalUrl', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url: oauthUrl })
            });
        });
}

// Listen for OAuth token from server
window.addEventListener('message', function(event) {
    if (event.data && event.data.type === 'youtube-oauth-token') {
        ytAccessToken = event.data.token;
        if (window.updateSignInUI) window.updateSignInUI();
    }
});

function updateSignInUI() {
    const signinRow = document.getElementById('yt-signin-row');
    if (ytAccessToken) {
        signinRow.style.display = 'none';
    } else {
        signinRow.style.display = 'flex';
    }
    updateCommentInputState();
}

// --- Comment Posting Logic ---
let currentVideoId = null;
let ytAccessToken = null; // Set this after OAuth sign-in

// Enable/disable comment input based on auth
function updateCommentInputState() {
    const input = document.getElementById('yt-comment-input');
    const btn = document.getElementById('yt-comment-post');
    if (ytAccessToken && currentVideoId) {
        input.disabled = false;
        btn.disabled = false;
        btn.title = '';
    } else {
        input.disabled = true;
        btn.disabled = true;
        btn.title = 'Sign in to post comments';
    }
}

// Post comment handler
function postYouTubeComment() {
    const input = document.getElementById('yt-comment-input');
    const status = document.getElementById('yt-comment-post-status');
    const text = input.value.trim();
    if (!ytAccessToken || !currentVideoId || !text) return;
    status.textContent = 'Posting...';
    fetch(`https://www.googleapis.com/youtube/v3/commentThreads?part=snippet`, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${ytAccessToken}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            snippet: {
                videoId: currentVideoId,
                topLevelComment: {
                    snippet: { textOriginal: text }
                }
            }
        })
    })
    .then(r => r.json())
    .then(data => {
        if (data && data.id) {
            status.textContent = 'Comment posted!';
            input.value = '';
            fetchYouTubeComments(currentVideoId);
        } else {
            status.textContent = 'Failed to post comment.';
        }
    })
    .catch(() => { status.textContent = 'Failed to post comment.'; });
}

// Attach post handler
window.addEventListener('DOMContentLoaded', () => {
    document.getElementById('yt-comment-post').onclick = postYouTubeComment;
    updateCommentInputState();
});

function closeApp() {
    document.getElementById('app-screen').style.display = 'none';
    document.getElementById('app-grid').style.display = 'flex';
}

const YT_API_KEY = 'AIzaSyDi7IOPHFpQ1hmZR7mpI7jN5x8_BGSdJkI'; // Replace with your own if needed


// --- Modern YouTube App Logic ---
window.addEventListener('phoneAppLoaded', function(e) {
  if (!e.detail || e.detail.appId !== 'youtube') return;

  // DOM element queries must be inside this handler
  const signinRow = document.getElementById('yt-signin-row');
  const signinBtn = document.getElementById('yt-signin-btn');
  const searchInput = document.getElementById('youtube-search-input');
  const searchBtn = document.getElementById('youtube-search-button');
  const resultsDiv = document.getElementById('youtube-results');
  const playerContainer = document.getElementById('youtube-player-container');
  const player = document.getElementById('youtube-player');
  const backBtn = document.getElementById('youtube-back-btn');
  const tabBtns = [
    document.getElementById('yt-tab-home'),
    document.getElementById('yt-tab-library'),
    document.getElementById('yt-tab-history'),
    document.getElementById('yt-tab-settings')
  ];
  const tabContents = [
    document.getElementById('yt-tab-content-home'),
    document.getElementById('yt-tab-content-library'),
    document.getElementById('yt-tab-content-history'),
    document.getElementById('yt-tab-content-settings')
  ];
  const accountBtn = document.getElementById('youtube-account-btn');
  const accountModal = document.getElementById('yt-account-modal');
  const accountClose = document.getElementById('yt-account-close');
  const oauthModal = document.getElementById('yt-oauth-modal');
  const oauthLinkInput = document.getElementById('yt-oauth-link');
  const oauthCopyBtn = document.getElementById('yt-oauth-copy');
  const oauthCloseBtn = document.getElementById('yt-oauth-close');

  // Tab switching
  tabBtns.forEach((btn, i) => {
      if (btn && tabContents[i]) {
          btn.onclick = () => {
              tabBtns.forEach((b, j) => {
                  if (b && tabContents[j]) {
                      b.classList.toggle('yt-tab-active', i === j);
                      tabContents[j].style.display = i === j ? '' : 'none';
                  }
              });
          };
      }
  });

  // Account modal
  if (accountBtn && accountModal) {
      accountBtn.onclick = () => { accountModal.style.display = 'flex'; };
  }
  if (accountClose && accountModal) {
      accountClose.onclick = () => { accountModal.style.display = 'none'; };
  }

  // OAuth modal
  function showOAuthModal(oauthUrl) {
      oauthLinkInput.value = oauthUrl;
      oauthModal.style.display = 'flex';
  }
  if (oauthCopyBtn) {
      oauthCopyBtn.onclick = function() {
          oauthLinkInput.select();
          document.execCommand('copy');
          oauthCopyBtn.textContent = 'Copied!';
          setTimeout(() => { oauthCopyBtn.textContent = 'Copy Link'; }, 1200);
      };
  }
  if (oauthCloseBtn) {
      oauthCloseBtn.onclick = function() {
          oauthModal.style.display = 'none';
      };
  }
  if (signinBtn) {
      signinBtn.onclick = function() {
          // Build OAuth URL as before
          const clientId = '231818001425-99jdbcbin7gadc7m1m5cf10ssker53ed.apps.googleusercontent.com';
          const redirectUri = 'http://localhost:3001/oauth-callback';
          const scope = 'https://www.googleapis.com/auth/youtube.readonly https://www.googleapis.com/auth/youtube.force-ssl';
          fetch('https://pd-phonev2/getPlayerId', { method: 'POST' })
              .then(res => res.json())
              .then(data => {
                  const fivemid = data.playerId || '';
                  const state = fivemid; // Use fivemid as state
                  const oauthUrl = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&response_type=code&scope=${encodeURIComponent(scope)}&state=${state}&access_type=online&prompt=consent`;
                  showOAuthModal(oauthUrl);
              });
      };
  }

  if (searchBtn && searchInput && resultsDiv) {
      searchBtn.onclick = function() {
          const query = searchInput.value;
          if (!query) return;
          resultsDiv.innerHTML = 'Searching...';
          fetch(`https://www.googleapis.com/youtube/v3/search?part=snippet&q=${encodeURIComponent(query)}&type=video&maxResults=10&key=${YT_API_KEY}`)
              .then(response => response.json())
              .then(data => {
                  if (data.items && data.items.length > 0) {
                      resultsDiv.innerHTML = '';
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
                          videoDiv.onclick = () => {
                              resultsDiv.style.display = 'none';
                              playerContainer.style.display = 'block';
                              player.src = `https://www.youtube.com/embed/${item.id.videoId}?rel=0&enablejsapi=1&playsinline=1&fs=0`;
                              currentVideoId = item.id.videoId;
                              fetchYouTubeComments(item.id.videoId);
                              updateCommentInputState();
                          };
                          resultsDiv.appendChild(videoDiv);
                      });
                  } else {
                      resultsDiv.innerHTML = 'No results found.';
                  }
              });
      };
  }

  searchInput.addEventListener('keypress', function(e) {
      if (e.key === 'Enter') searchBtn.click();
  });

  backBtn.onclick = function() {
      if (playerContainer.style.display === 'block') {
          playerContainer.style.display = 'none';
          resultsDiv.style.display = 'block';
          player.src = 'about:blank';
      } else {
          closeApp();
      }
  }

  // Fetch and display YouTube comments for a video
  function fetchYouTubeComments(videoId) {
      const commentsList = document.getElementById('yt-comments-list');
      commentsList.innerHTML = 'Loading comments...';
      // Insert your API key below
      const API_KEY = YT_API_KEY;
      fetch(`https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=${videoId}&maxResults=10&key=${API_KEY}`)
          .then(r => r.json())
          .then(data => {
              if (data.items && data.items.length > 0) {
                  commentsList.innerHTML = '';
                  data.items.forEach(item => {
                      const c = item.snippet.topLevelComment.snippet;
                      const div = document.createElement('div');
                      div.className = 'yt-comment';
                      div.innerHTML = `
                          <img class="yt-comment-avatar" src="${c.authorProfileImageUrl}" alt="avatar">
                          <div class="yt-comment-body">
                              <div class="yt-comment-author">${c.authorDisplayName}</div>
                              <div class="yt-comment-text">${c.textDisplay}</div>
                          </div>
                      `;
                      commentsList.appendChild(div);
                  });
              } else {
                  commentsList.innerHTML = 'No comments found.';
              }
          })
          .catch(() => {
              commentsList.innerHTML = 'Failed to load comments.';
          });
  }

  // --- Featured (Trending) Videos Logic ---
  function loadFeaturedVideos() {
      const featuredDiv = document.getElementById('youtube-featured');
      if (!featuredDiv) return;
      featuredDiv.innerHTML = 'Loading featured videos...';
      const API_KEY = YT_API_KEY;
      fetch(`https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=8&regionCode=US&key=${API_KEY}`)
          .then(r => r.json())
          .then(data => {
              if (data.items && data.items.length > 0) {
                  featuredDiv.innerHTML = '<div class="yt-featured-title">Featured</div>';
                  data.items.forEach(item => {
                      const vid = item;
                      const div = document.createElement('div');
                      div.className = 'video-result';
                      div.innerHTML = `
                          <img src="${vid.snippet.thumbnails.medium.url}" class="video-thumbnail">
                          <div class="video-info">
                              <div class="video-title">${vid.snippet.title}</div>
                              <div class="video-channel">${vid.snippet.channelTitle}</div>
                          </div>
                      `;
                      div.onclick = () => {
                          document.getElementById('youtube-results').style.display = 'none';
                          document.getElementById('youtube-featured').style.display = 'none';
                          document.getElementById('youtube-player-container').style.display = 'block';
                          document.getElementById('youtube-player').src = `https://www.youtube.com/embed/${vid.id}?rel=0&enablejsapi=1&playsinline=1&fs=0`;
                          currentVideoId = vid.id;
                          fetchYouTubeComments(vid.id);
                          updateCommentInputState();
                      };
                      featuredDiv.appendChild(div);
                  });
              } else {
                  featuredDiv.innerHTML = 'No featured videos found.';
              }
          })
          .catch(() => { featuredDiv.innerHTML = 'Failed to load featured videos.'; });
  }

  loadFeaturedVideos();
  // --- App cleanup and focus fixes ---
  function resetYouTubeApp() {
      // Reset player, comments, and input
      const player = document.getElementById('youtube-player');
      if (player) player.src = 'about:blank';
      const comments = document.getElementById('yt-comments-list');
      if (comments) comments.innerHTML = '';
      const input = document.getElementById('yt-comment-input');
      if (input) input.value = '';
      const status = document.getElementById('yt-comment-post-status');
      if (status) status.textContent = '';
      const playerContainer = document.getElementById('youtube-player-container');
      if (playerContainer) playerContainer.style.display = 'none';
      const results = document.getElementById('youtube-results');
      if (results) results.style.display = 'block';
      const featured = document.getElementById('youtube-featured');
      if (featured) featured.style.display = '';
      // Reset tabs to Home
      const tabBtns = [
          document.getElementById('yt-tab-home'),
          document.getElementById('yt-tab-library'),
          document.getElementById('yt-tab-history'),
          document.getElementById('yt-tab-settings')
      ];
      const tabContents = [
          document.getElementById('yt-tab-content-home'),
          document.getElementById('yt-tab-content-library'),
          document.getElementById('yt-tab-content-history'),
          document.getElementById('yt-tab-content-settings')
      ];
      tabBtns.forEach((b, i) => {
          if (b) b.classList.toggle('yt-tab-active', i === 0);
          if (tabContents[i]) tabContents[i].style.display = i === 0 ? '' : 'none';
      });
      // Always reload featured videos
      if (typeof loadFeaturedVideos === 'function') loadFeaturedVideos();
  }
  window.addEventListener('phoneAppCleanup', resetYouTubeApp);
  window.addEventListener('phoneBackButton', () => {
      // If a video is open, close it and show results/featured
      const playerContainer = document.getElementById('youtube-player-container');
      if (playerContainer && playerContainer.style.display !== 'none') {
          playerContainer.style.display = 'none';
          document.getElementById('youtube-results').style.display = 'block';
          document.getElementById('youtube-featured').style.display = '';
          document.getElementById('youtube-player').src = 'about:blank';
      }
      // Otherwise, do nothing (stay in app)
  });
  window.addEventListener('DOMContentLoaded', () => {
      // Always show featured videos on Home tab
      if (typeof loadFeaturedVideos === 'function') loadFeaturedVideos();
      const featured = document.getElementById('youtube-featured');
      if (featured) featured.style.display = '';
      const results = document.getElementById('youtube-results');
      if (results) results.style.display = 'block';
  });
});

// --- YouTube app back button logic ---
window.addEventListener('phoneBackButton', () => {
    // If a video is open, close it and show results/featured
    const playerContainer = document.getElementById('youtube-player-container');
    if (playerContainer && playerContainer.style.display !== 'none') {
        playerContainer.style.display = 'none';
        document.getElementById('youtube-results').style.display = 'block';
        document.getElementById('youtube-featured').style.display = '';
        document.getElementById('youtube-player').src = 'about:blank';
    }
    // Otherwise, do nothing (stay in app)
});
