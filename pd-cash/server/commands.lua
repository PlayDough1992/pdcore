-- pd-cash server: Administrative commands

-- Helper function to check if player is admin
local function isPlayerAdmin(source)
    -- Implementation depends on your server's admin system
    -- For example, using FiveM's built-in "command" ACL:
    if IsPlayerAceAllowed(source, "command") then
        return true
    end
    
    -- For testing, allow admins based on config
    if not Config.Debug.AdminOnly then
        return true
    end
    
    -- Default to false
    return false
end

-- Command to spawn cash at a player's position
RegisterCommand('spawncash', function(source, args)
    -- Admin check
    if not isPlayerAdmin(source) then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command", 
            type = 'error'
        })
        return
    end
    
    -- Parse amount from arguments
    local amount = tonumber(args[1]) or 250
    
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
    
    print("[pd-cash] Admin " .. GetPlayerName(source) .. " spawned cash drop worth $" .. amount)
end, false)

-- Command to list all active cash drops
RegisterCommand('listcash', function(source)
    -- Admin check
    if not isPlayerAdmin(source) then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command", 
            type = 'error'
        })
        return
    end
    
    -- Count cash drops
    local count = PD_Cash.countCashDrops()
    
    -- Send message to admin
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 255, 0},
        multiline = true,
        args = {'[CASH]', 'Active cash drops: ' .. count}
    })
    
    -- If no drops, show a message
    if count == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {'[CASH]', 'No cash drops found! Try using /spawncash'}
        })
    else
        -- List each drop
        for id, data in pairs(PD_Cash.getAllCashDrops()) do
            local coordStr = string.format('%.1f, %.1f, %.1f', data.coords.x, data.coords.y, data.coords.z)
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                args = {'[CASH]', 'ID: ' .. id .. ' | $' .. data.amount .. ' | Location: ' .. coordStr}
            })
        end
    end
end, false)

-- Command to remove all cash drops (cleanup)
RegisterCommand('clearcash', function(source)
    -- Admin check
    if not isPlayerAdmin(source) then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command", 
            type = 'error'
        })
        return
    end
    
    -- Clear all cash drops
    local count = PD_Cash.clearAllCashDrops()
    
    -- Update all clients
    TriggerClientEvent('pd-cash:receiveAllCashDrops', -1, {})
    
    -- Notify admin
    TriggerClientEvent('pd-notifications:notify', source, {
        text = string.format('Cleared %d cash drops', count), 
        type = 'success'
    })
    
    -- Notify admin
    TriggerClientEvent('pd-notifications:notify', source, {
        text = string.format('Cleared %d cash drops', count), 
        type = 'success'
    })
    
    print("[pd-cash] Admin " .. GetPlayerName(source) .. " cleared all cash drops")
end, false)
