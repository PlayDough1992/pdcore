-- Register a dedicated dropcash command (not just an alias)
RegisterCommand('dropcash', function(source, args)
    -- Admin check - same as spawncash
    if source ~= 0 and not IsPlayerAceAllowed(source, "command") and Config.Debug.AdminOnly then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command", 
            type = 'error'
        })
        return
    end
    
    -- Parse amount from arguments
    local amount = tonumber(args[1]) or 250
    
    if source == 0 then
        -- Console can't spawn cash without target player
        print("[pd-cash] Console usage: dropcash [amount] [playerID]")
        local targetId = tonumber(args[2])
        if not targetId then
            print("[pd-cash] Error: Must specify player ID when using from console")
            return
        end
        
        local playerPed = GetPlayerPed(targetId)
        if not playerPed then
            print("[pd-cash] Error: Invalid player ID")
            return
        end
        
        local coords = GetEntityCoords(playerPed)
        -- Add slight offset
        coords = vector3(coords.x + 0.5, coords.y + 0.5, coords.z)
        
        -- Create the cash drop
        local cashId = PD_Cash.addCashDrop(coords, amount)
        
        -- Broadcast to all clients
        TriggerClientEvent('pd-cash:spawnCash', -1, cashId, coords, amount)
        print("[pd-cash] Created cash drop worth $" .. amount .. " at player " .. GetPlayerName(targetId))
        return
    end
    
    -- Get player position
    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)
    
    -- Add slight offset so it doesn't spawn directly on the player
    coords = vector3(coords.x + 0.5, coords.y + 0.5, coords.z)
    
    -- Create the cash drop using shared module
    local cashId = PD_Cash.addCashDrop(coords, amount)
    
    -- Broadcast to all clients
    TriggerClientEvent('pd-cash:spawnCash', -1, cashId, coords, amount)
    
    -- Notify admin
    TriggerClientEvent('pd-notifications:notify', source, {
        text = string.format('Created cash drop of $%d', amount), 
        type = 'success'
    })
    
    print("[pd-cash] Player " .. GetPlayerName(source) .. " spawned cash drop worth $" .. amount)
end, false) -- Allow anyone to use this command (permission check is inside)

print("[pd-cash] Registered /dropcash command")
