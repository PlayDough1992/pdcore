window.addEventListener('message', function(event) {
    if (event.data.type === 'chat') {
        showChatMessage(event.data.playerName, event.data.message, event.data.isOwnMessage);
    }
});

function showChatMessage(playerName, message, isOwnMessage) {
    const chatDiv = document.createElement('div');
    chatDiv.className = `chat-message ${isOwnMessage ? 'own-message' : 'other-message'}`;
    
    const nameSpan = document.createElement('span');
    nameSpan.className = 'player-name';
    nameSpan.textContent = playerName + ':';
    
    chatDiv.appendChild(nameSpan);
    chatDiv.appendChild(document.createTextNode(' ' + message));
    
    const container = document.getElementById('chat-messages');
    container.appendChild(chatDiv);
    
    // Force display
    chatDiv.style.opacity = '1';
    
    setTimeout(() => {
        chatDiv.style.opacity = '0';
        setTimeout(() => {
            chatDiv.remove();
        }, 300);
    }, 7000);
}