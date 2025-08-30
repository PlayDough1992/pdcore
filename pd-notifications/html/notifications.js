console.log('Notifications script loaded!');

window.addEventListener('message', function(event) {
    console.log('NUI message received:', event.data);
    if (event.data.action === 'notification') {
        console.log('Creating notification:', event.data.text);
        showNotification(event.data.text, event.data.type);
    }
});

function showNotification(text, type) {
    console.log('Showing notification:', text, type);
    const notif = document.createElement('div');
    notif.className = `notification ${type}`;
    notif.textContent = text;
    
    document.getElementById('notifications').appendChild(notif);
    console.log('Notification element created');
    
    setTimeout(() => {
        notif.style.opacity = '1';
        console.log('Notification visible');
    }, 100);
    
    setTimeout(() => {
        notif.style.opacity = '0';
        setTimeout(() => {
            notif.remove();
            console.log('Notification removed');
        }, 300);
    }, 3000);
}