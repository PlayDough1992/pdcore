document.addEventListener('DOMContentLoaded', () => {
    const buttons = document.querySelectorAll('.menu-button');
    
    buttons.forEach(button => {
        button.addEventListener('click', () => {
            const action = button.dataset.action;
            fetch(`https://vMenu/${action}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        });
    });
});

// Handle visibility
window.addEventListener('message', (event) => {
    const item = event.data;
    if (item.type === 'show') {
        document.querySelector('.menu').style.display = 'block';
    } else if (item.type === 'hide') {
        document.querySelector('.menu').style.display = 'none';
    }
});