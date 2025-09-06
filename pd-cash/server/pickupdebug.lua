-- Debug command to manually trigger a cash pickup 
RegisterCommand('pickupcash', function(source, args)
    if source == 0 then
        print("[pd-cash] This command can only be used by players")
        return
    end
    
    local cashId = tonumber(args[1])
    if not cashId then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {'[CASH]', 'Usage: /pickupcash [cashId]'}
        })
        return
    end
    
    -- Check if the cash drop exists
    local cashData = PD_Cash.spawnedCash[cashId]
    if not cashData then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {'[CASH]', 'Cash drop #' .. cashId .. ' does not exist'}
        })
        return
    end
    
    -- Get player identifier
    local fivemId = getPlayerIdentifier(source, 'fivem:')
    if not fivemId then
        print("[pd-cash] ERROR: Could not find fivem identifier for player " .. GetPlayerName(source))
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {'[CASH]', 'Error: Could not find your fivem identifier'}
        })
        return
    end
    
    -- Remove cash from world
    PD_Cash.removeCashDrop(cashId)
    TriggerClientEvent('pd-cash:removeCash', -1, cashId)
    
    -- Add to player's cash using multiple methods for reliability
    
    -- Method 1: Use pd-bank:addCash event
    print("[pd-cash] Method 1: Triggering pd-bank:addCash event")
    TriggerEvent('pd-bank:addCash', source, cashData.amount)
    
    -- Method 2: Use direct file manipulation
    if GetResourceState('pd-bank') == 'started' then
        local safeId = fivemId:gsub(':', '%%3A')
        local path = "playermoney/" .. safeId .. ".json"
        local moneyFile = LoadResourceFile('pd-bank', path)
        
        print("[pd-cash] Method 2: Direct file manipulation")
        if moneyFile then
            local moneyData = json.decode(moneyFile)
            moneyData.cash = (moneyData.cash or 0) + cashData.amount
            SaveResourceFile('pd-bank', path, json.encode(moneyData), -1)
            print("[pd-cash] Directly updated money file: " .. path)
        else
            -- Create new file
            print("[pd-cash] Creating new money file: " .. path)
            SaveResourceFile('pd-bank', path, json.encode({cash = cashData.amount, bank = 0}), -1)
        end
    end
    
    -- Method 3: Try to use exports if available
    if GetResourceState('pd-bank') == 'started' and exports['pd-bank'] then
        print("[pd-cash] Method 3: Using exports")
        if exports['pd-bank'].AddCash then
            exports['pd-bank']:AddCash(fivemId, cashData.amount)
            print("[pd-cash] Used pd-bank exports to add cash")
        end
    end
    
    -- Notify player
    TriggerClientEvent('pd-notifications:notify', source, {
        text = string.format('Picked up $%d cash!', cashData.amount), 
        type = 'success'
    })
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {0, 255, 0},
        multiline = true,
        args = {'[CASH]', 'Manually picked up cash drop #' .. cashId .. ' worth $' .. cashData.amount}
    })
    
    print("[pd-cash] Player " .. GetPlayerName(source) .. " manually picked up $" .. cashData.amount)
end, false) -- Allow any player to use this command
