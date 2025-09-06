// pd-cash: UI script
let amount = '';
const maxAmount = 10000; // Can be synced with Config.Give.MaxAmount

// Numpad button layout
const numpadLayout = [
  '1', '2', '3',
  '4', '5', '6',
  '7', '8', '9',
  '.', '0', '←'
];

// Initialize the numpad with buttons
function renderNumpad() {
  const numpad = document.getElementById('numpad');
  numpad.innerHTML = '';
  
  numpadLayout.forEach(val => {
    const btn = document.createElement('button');
    btn.className = 'numpad-btn';
    btn.textContent = val;
    btn.onclick = () => {
      if (val === '←') {
        // Backspace functionality
        amount = amount.slice(0, -1);
      } else if (val === '.' && amount.includes('.')) {
        // Prevent multiple decimal points
        return;
      } else {
        // Add digit or decimal
        amount += val;
      }
      
      // Update display
      updateAmountDisplay();
      
      // Validate button state
      validateGiveButton();
    };
    numpad.appendChild(btn);
  });
}

// Update the amount display with formatted value
function updateAmountDisplay() {
  const displayEl = document.getElementById('amount-value');
  const numValue = parseFloat(amount) || 0;
  displayEl.textContent = numValue.toLocaleString('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2
  });
  
  // Update numpad data attribute for reference
  document.getElementById('numpad').setAttribute('data-value', amount);
}

// Load reason options from server config
function loadReasons() {
  fetch(`https://${GetParentResourceName()}/getReasons`, { 
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  })
  .then(response => response.json())
  .then(data => {
    const reasonSelect = document.getElementById('reason-select');
    reasonSelect.innerHTML = '<option value="" disabled selected>Select reason</option>';
    
    data.reasons.forEach(reason => {
      const option = document.createElement('option');
      option.value = reason;
      option.textContent = reason;
      reasonSelect.appendChild(option);
    });
  })
  .catch(error => {
    console.error('Failed to load reasons:', error);
  });
}

// Validate if the give button should be enabled
function validateGiveButton() {
  const giveButton = document.getElementById('give-cash-btn');
  const playerSelect = document.getElementById('player-select');
  const reasonSelect = document.getElementById('reason-select');
  const numValue = parseFloat(amount) || 0;
  
  // Check all conditions
  const isValid = 
    playerSelect.value && 
    reasonSelect.value && 
    numValue > 0 && 
    numValue <= maxAmount;
  
  giveButton.disabled = !isValid;
}

// Initialize the UI when document is loaded
document.addEventListener('DOMContentLoaded', () => {
  // Initialize UI components
  renderNumpad();
  loadReasons();
  
  // Set up event listeners
  document.getElementById('player-select').addEventListener('change', validateGiveButton);
  document.getElementById('reason-select').addEventListener('change', validateGiveButton);
  
  // Give cash button
  document.getElementById('give-cash-btn').onclick = () => {
    const player = document.getElementById('player-select').value;
    const reason = document.getElementById('reason-select').value;
    const numValue = parseFloat(amount);
    
    // Final validation
    if (!player || !reason || isNaN(numValue) || numValue <= 0 || numValue > maxAmount) {
      return;
    }
    
    // Show confirmation modal
    const summary = `Give $${numValue.toLocaleString()} to ${document.getElementById('player-select').options[document.getElementById('player-select').selectedIndex].text} for ${reason}?`;
    document.getElementById('cash-modal-summary').textContent = summary;
    document.getElementById('cash-modal').style.display = 'flex';
  };
  
  // Confirmation modal actions
  document.getElementById('cash-modal-accept').onclick = () => {
    const player = document.getElementById('player-select').value;
    const reason = document.getElementById('reason-select').value;
    const numValue = parseFloat(amount);
    
    // Send data to resource
    fetch(`https://${GetParentResourceName()}/giveCash`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ player, reason, amount: numValue })
    });
    
    // Hide modal
    document.getElementById('cash-modal').style.display = 'none';
  };
  
  document.getElementById('cash-modal-deny').onclick = () => {
    // Hide modal without action
    document.getElementById('cash-modal').style.display = 'none';
  };
  
  // Close button
  document.getElementById('close-cash-ui-btn').onclick = () => {
    fetch(`https://${GetParentResourceName()}/closeCashUI`, { method: 'POST' });
  };
});

// Handle messages from the resource
window.addEventListener('message', function(event) {
  const data = event.data;
  
  if (data.action === 'setPlayers') {
    // Populate player dropdown
    const playerSelect = document.getElementById('player-select');
    playerSelect.innerHTML = '<option value="" disabled selected>Select player</option>';
    
    data.players.forEach(player => {
      const option = document.createElement('option');
      option.value = player.id;
      option.textContent = player.name;
      playerSelect.appendChild(option);
    });
    
    // Revalidate button state
    validateGiveButton();
  }
  
  if (data.action === 'showGiveCash') {
    // Reset and show UI
    amount = '';
    updateAmountDisplay();
    document.getElementById('cash-ui-container').style.display = 'flex';
    document.getElementById('player-select').selectedIndex = 0;
    document.getElementById('reason-select').selectedIndex = 0;
    validateGiveButton();
  }
  
  if (data.action === 'closeGiveCash') {
    // Hide all UI elements
    document.getElementById('cash-ui-container').style.display = 'none';
    document.getElementById('cash-modal').style.display = 'none';
  }
});
