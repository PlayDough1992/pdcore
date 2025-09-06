-- pd-cash: Server debug functions
-- Only loaded when Config.Debug.Enabled = true

if not Config.Debug.Enabled then return end

-- Debug event to spawn cash at a player's position
RegisterServerEvent('pd-cash:debugSpawnCash')
AddEventHandler('pd-cash:debugSpawnCash', function(coords, amount)
    local src = source
    local playerName = GetPlayerName(src)
    
    -- Only allow certain players (admins, etc.) to use this
    local allowed = true -- For testing, allow all players
    
    if not allowed then
        print("[pd-cash] Player " .. playerName .. " tried to spawn cash but was not allowed")
        TriggerClientEvent('pd-notifications:notify', src, {text = "You don't have permission to spawn cash", type = 'error'})
        return
    end
    
    -- Generate a new cash ID
    local cashId = PD_Cash.GenerateNewCashId()
    PD_Cash.spawnedCash[cashId] = {coords = coords, amount = amount}
    
    print("[pd-cash] Player " .. playerName .. " spawned cash #" .. cashId .. " at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
    TriggerClientEvent('pd-cash:spawnCash', -1, cashId, coords, amount)
    TriggerClientEvent('pd-notifications:notify', src, {text = 'Created cash drop worth $' .. amount, type = 'success'})
end)

-- Add command to directly add cash to player (for testing)
RegisterCommand('addcash', function(source, args, rawCommand)
    if source == 0 then
        -- Command from console
        if #args < 2 then
            print("[pd-cash] Usage: addcash [playerId] [amount]")
            return
        end
        
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if not targetId or not amount then
            print("[pd-cash] Invalid arguments. Usage: addcash [playerId] [amount]")
            return
        end
        
        if GetPlayerName(targetId) then
            TriggerEvent('pd-bank:addCash', targetId, amount)
            print("[pd-cash] Added $" .. amount .. " to player " .. GetPlayerName(targetId))
        else
            print("[pd-cash] Player ID " .. targetId .. " not found")
        end
    else
        -- Command from player
        local amount = tonumber(args[1])
        
        if not amount then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {'[CASH]', 'Usage: /addcash [amount]'}
            })
            return
        end
        
        TriggerEvent('pd-bank:addCash', source, amount)
        TriggerClientEvent('pd-notifications:notify', source, {
            text = 'Added $' .. amount .. ' to your cash',
            type = 'success'
        })
    end
end, true)

-- Print all currently spawned cash objects
RegisterCommand('servercash', function(source, args)
    local count = 0
    for k, v in pairs(PD_Cash.spawnedCash) do
        count = count + 1
    end
    
    print("[pd-cash] Current cash drops: " .. count)
    
    if count == 0 then
        print("[pd-cash] No cash drops found! Try using /spawncash command")
    else
        for id, data in pairs(PD_Cash.spawnedCash) do
            local coordStr = string.format('%.1f, %.1f, %.1f', data.coords.x, data.coords.y, data.coords.z)
            print("[pd-cash] ID: " .. id .. " | $" .. data.amount .. " | Location: " .. coordStr)
        end
    end
end, true) -- Restrict to console only
