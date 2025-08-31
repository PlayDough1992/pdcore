// Add this to your existing event listeners initialization
function initializeCameraControls() {
    const heightSlider = document.getElementById('heightSlider');
    const rotationSlider = document.getElementById('rotationSlider');
    const zoomSlider = document.getElementById('zoomSlider');

    function updateCameraDisplay() {
        heightSlider.nextElementSibling.textContent = heightSlider.value + '%';
        rotationSlider.nextElementSibling.textContent = rotationSlider.value + '°';
        zoomSlider.nextElementSibling.textContent = (zoomSlider.value / 100).toFixed(1);
    }

    function updateCamera() {
        fetch('https://pd-clothing/updateCamera', {
            method: 'POST',
            body: JSON.stringify({
                height: heightSlider.value,
                rotation: rotationSlider.value,
                zoom: zoomSlider.value
            })
        });
    }

    // Height controls
    heightSlider.addEventListener('input', () => {
        updateCameraDisplay();
        updateCamera();
    });

    // Rotation controls
    rotationSlider.addEventListener('input', () => {
        updateCameraDisplay();
        updateCamera();
    });

    // Zoom controls
    zoomSlider.addEventListener('input', () => {
        updateCameraDisplay();
        updateCamera();
    });
}
