window.addEventListener('message', function(event) {
    if (event.data.type === 'status') {
        // Clamp values between 0 and 100
        const health = Math.max(0, Math.min(100, event.data.health));
        const stamina = Math.max(0, Math.min(100, event.data.stamina));
        const vehicle = Math.max(0, Math.min(100, event.data.vehicle));
        const altitude = Math.max(0, Math.min(100, event.data.altitude));
        const oxygen = Math.max(0, Math.min(100, event.data.oxygen));

        // Update horizontal bars
        document.querySelector('.health .bar-fill').style.width = health + '%';
        document.querySelector('.stamina .bar-fill').style.width = stamina + '%';
        document.querySelector('#vehicle-health .bar-fill').style.width = vehicle + '%';

        // Update vertical bars
        document.querySelector('.altitude .bar-fill').style.height = altitude + '%';
        document.querySelector('.oxygen .bar-fill').style.height = oxygen + '%';

        // Debug output
        console.log('Status Update:', {health, stamina, vehicle, altitude, oxygen});
    }
});