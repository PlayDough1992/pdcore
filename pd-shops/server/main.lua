RegisterNetEvent('pd-shops:purchase')
AddEventHandler('pd-shops:purchase', function(itemData)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    -- Use bank event instead of export temporarily
    local moneyFile = LoadResourceFile('pd-bank', 'playermoney/' .. identifier .. '.json')
    local moneyData = json.decode(moneyFile or '{"bank":0,"cash":0}')
    local balance = moneyData.bank
    
    print("^2[DEBUG Shop]^7 Processing purchase:", json.encode(itemData))
    
    if balance >= itemData.price then
        -- Deduct money directly
        moneyData.bank = moneyData.bank - itemData.price
        SaveResourceFile('pd-bank', 'playermoney/' .. identifier .. '.json', json.encode(moneyData), -1)
        
        if itemData.type == "armor" then
            SetPedArmour(GetPlayerPed(source), itemData.armorValue)
        elseif itemData.type == "weapons" then
            -- Changed: Let client trigger the weapon addition
            TriggerClientEvent('pd-shops:weaponPurchased', source, itemData.name)
        else
            -- Handle other items
            TriggerClientEvent('pd-inventory:addItem', source, itemData.name)
        end
        
        TriggerClientEvent('pd-notifications:notify', source, {
            text = string.format("Purchased %s for $%s", itemData.label, itemData.price),
            type = "success"
        })
    else
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Insufficient funds",
            type = "error"
        })
    end
end)