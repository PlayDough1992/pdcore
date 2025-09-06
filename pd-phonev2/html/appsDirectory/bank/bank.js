// --- Modern Bank App Logic ---
window.addEventListener('phoneAppLoaded', function(e) {
  if (!e.detail || e.detail.appId !== 'bank') return;
    const tabBtns = [
        document.getElementById('bank-tab-accounts'),
        document.getElementById('bank-tab-transfer'),
        document.getElementById('bank-tab-history'),
        document.getElementById('bank-tab-settings')
    ];
    const tabContents = [
        document.getElementById('bank-tab-content-accounts'),
        document.getElementById('bank-tab-content-transfer'),
        document.getElementById('bank-tab-content-history'),
        document.getElementById('bank-tab-content-settings')
    ];
    tabBtns.forEach((btn, i) => {
        btn.onclick = () => {
            tabBtns.forEach((b, j) => {
                b.classList.toggle('bank-tab-active', i === j);
                tabContents[j].style.display = i === j ? '' : 'none';
            });
        };
    });
    // Account modal
    const accountBtn = document.getElementById('bank-account-btn');
    const accountModal = document.getElementById('bank-account-modal');
    const accountClose = document.getElementById('bank-account-close');
    accountBtn.onclick = () => { accountModal.style.display = 'flex'; };
    accountClose.onclick = () => { accountModal.style.display = 'none'; };
    // Back button
    const backBtn = document.getElementById('bank-back-btn');
    backBtn.onclick = () => {
        document.getElementById('app-screen').style.display = 'none';
        document.getElementById('app-grid').style.display = 'flex';
    };
});
function closeApp() {
    document.getElementById('app-screen').style.display = 'none';
    document.getElementById('app-grid').style.display = 'flex';
}
window.getBankBalance = function() {
    fetch(`https://${GetParentResourceName()}/getBankBalance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
    .then(() => {})
    .catch(() => {});
};
window.addEventListener('message', function(event) {
    if (event.data.action === 'updateBalance') {
        // Support both old (number) and new (object) formats
        let bank = 0, cash = 0;
        if (typeof event.data.balance === 'object' && event.data.balance !== null) {
            bank = Number(event.data.balance.bank || 0);
            cash = Number(event.data.balance.cash || 0);
        } else {
            bank = Number(event.data.balance || 0);
        }
        document.getElementById('balance').textContent = `$${bank.toLocaleString()}`;
        document.getElementById('cash-balance').textContent = `$${cash.toLocaleString()}`;
    }
});
