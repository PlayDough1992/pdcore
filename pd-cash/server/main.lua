-- pd-cash server: Core functionality

-- Utility functions
local function getRandomLocation()
    local locations = Config.CashSpawn.Locations
    return locations[math.random(1, #locations)]
end

local function getRandomAmount()
    return math.random(Config.CashSpawn.AmountMin, Config.CashSpawn.AmountMax)
end

local function getPlayerIdentifier(source, prefix)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id:sub(1, string.len(prefix)) == prefix then 
            return id 
        end
    end
    return nil
end

local function getPlayerMoney(identifier)
    if not identifier then return { cash = 0, bank = 0 } end
    
    local safeId = identifier:gsub(':', '%%3A')
    local path = string.format('playermoney/%s.json', safeId)
    
    local moneyFile = LoadResourceFile('pd-bank', path)
    if not moneyFile then
        return { cash = 0, bank = 0 }
    end
    
    local success, moneyData = pcall(json.decode, moneyFile)
    if not success or not moneyData then
        print("[pd-cash] ERROR: Failed to parse money file for " .. identifier)
        return { cash = 0, bank = 0 }
    end
    
    -- Ensure both cash and bank fields exist
    moneyData.cash = moneyData.cash or 0
    moneyData.bank = moneyData.bank or 0
    
    return moneyData
end

local function savePlayerMoney(identifier, moneyData)
    if not identifier then return false end
    
    local safeId = identifier:gsub(':', '%%3A')
    local path = string.format('playermoney/%s.json', safeId)
    
    local success, encoded = pcall(json.encode, moneyData)
    if not success or not encoded then
        print("[pd-cash] ERROR: Failed to encode money data for " .. identifier)
        return false
    end
    
    local result = SaveResourceFile('pd-bank', path, encoded, -1)
    return result
end

-- Cash spawn system
if Config.CashSpawn.Enabled then
    Citizen.CreateThread(function()
        -- Initial cash drops on resource start
        for i = 1, 5 do
            local coords = getRandomLocation()
            local amount = getRandomAmount()
            local cashId = PD_Cash.addCashDrop(coords, amount)
            TriggerClientEvent('pd-cash:spawnCash', -1, cashId, coords, amount)
            print("[pd-cash] Spawned initial cash drop #" .. cashId .. " worth $" .. amount)
            Citizen.Wait(100)
        end
        
        -- Periodic cash spawn system
        while true do
            Citizen.Wait(Config.CashSpawn.Interval)
            
            -- Count current drops
            local spawnCount = PD_Cash.countCashDrops()
            
            -- Spawn new drop if under max limit
            if spawnCount < Config.CashSpawn.MaxDrops then
                local coords = getRandomLocation()
                local amount = getRandomAmount()
                local cashId = PD_Cash.addCashDrop(coords, amount)
                TriggerClientEvent('pd-cash:spawnCash', -1, cashId, coords, amount)
                print("[pd-cash] Spawned cash drop #" .. cashId .. " worth $" .. amount)
            end
        end
    end)
end
-- Cash pickup handler
RegisterServerEvent('pd-cash:pickupCash')
AddEventHandler('pd-cash:pickupCash', function(cashId)
    local src = source
    local cashData = PD_Cash.spawnedCash[cashId]
    
    -- Validate the cash drop exists
    if not cashData then 
        print("[pd-cash] WARNING: Player " .. GetPlayerName(src) .. " tried to pick up non-existent cash #" .. cashId)
        return 
    end
    
    -- Get player identifier
    local fivemId = getPlayerIdentifier(src, 'fivem:')
    if not fivemId then
        print("[pd-cash] ERROR: Could not find fivem identifier for player " .. GetPlayerName(src))
        return
    end
    
    -- Remove cash from world
    PD_Cash.removeCashDrop(cashId)
    TriggerClientEvent('pd-cash:removeCash', -1, cashId)
    
    -- Add to player's cash using the most reliable method
    print("[pd-cash] DEBUG: About to add $" .. cashData.amount .. " cash to player " .. GetPlayerName(src))
    
    -- Force creation of the money file if it doesn't exist
    local safeId = fivemId:gsub(':', '%%3A')
    local path = "playermoney/" .. safeId .. ".json"
    
    -- Check if pd-bank exists and is running
    if GetResourceState('pd-bank') ~= 'started' then
        print("[pd-cash] ERROR: pd-bank resource is not running! Cash will not be saved.")
        -- Notify player there's an issue
        TriggerClientEvent('pd-notifications:notify', src, {
            text = "Server error: Your cash pickup was not saved properly. Please contact an admin.",
            type = 'error'
        })
        return
    end
    
    -- Use the DIRECT method for reliability (not the event)
    local moneyFile = LoadResourceFile('pd-bank', path)
    local moneyData = nil
    
    if moneyFile then
        -- Parse existing money data
        moneyData = json.decode(moneyFile)
    else
        -- Create new money data if file doesn't exist
        print("[pd-cash] Creating new money file for player " .. GetPlayerName(src) .. " at: " .. path)
        moneyData = {cash = 0, bank = 0}
    end
    
    -- Update cash amount
    moneyData.cash = (moneyData.cash or 0) + cashData.amount
    
    -- Save updated money data
    SaveResourceFile('pd-bank', path, json.encode(moneyData), -1)
    
    -- Log once, with clear formatting for easier debugging
    print(string.format("[pd-cash] Player %s picked up $%d (New balance: $%d)", 
                        GetPlayerName(src), cashData.amount, moneyData.cash))
    
    -- Also notify the pd-bank system for other resources that might be listening
    -- But don't use this as the primary method since it might double-add
    TriggerEvent('pd-bank:cashUpdated', src, fivemId, moneyData.cash)
    
    -- Send a single notification to the player
    TriggerClientEvent('pd-notifications:notify', src, {
        text = string.format('Picked up $%d cash!', cashData.amount), 
        type = 'success'
    })
end)

-- Cash transfer system
RegisterServerEvent('pd-cash:requestNearbyPlayers')
AddEventHandler('pd-cash:requestNearbyPlayers', function()
    local src = source
    local players = {}
    local srcPed = GetPlayerPed(src)
    local srcCoords = GetEntityCoords(srcPed)
    
    -- Get all online players
    for _, id in ipairs(GetPlayers()) do
        local playerId = tonumber(id)
        
        -- Skip if it's the source player
        if playerId ~= tonumber(src) then
            local ped = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            
            -- Check if within configured radius
            if #(srcCoords - coords) < Config.Give.Radius then
                table.insert(players, { 
                    id = playerId, 
                    name = GetPlayerName(playerId) 
                })
            end
        end
    end
    
    -- Send player list to client
    TriggerClientEvent('pd-cash:setPlayers', src, players)
end)

-- Cash transfer handler
RegisterServerEvent('pd-cash:giveCash')
AddEventHandler('pd-cash:giveCash', function(targetId, amount, reason)
    local src = source
    targetId = tonumber(targetId)
    amount = tonumber(amount)
    
    -- Input validation
    if not targetId or not amount or amount <= 0 then
        TriggerClientEvent('pd-notifications:notify', src, {
            text = 'Invalid transfer request', 
            type = 'error'
        })
        TriggerClientEvent('pd-cash:closeGiveCash', src)
        return
    end
    
    -- Check max amount
    if amount > Config.Give.MaxAmount then
        TriggerClientEvent('pd-notifications:notify', src, {
            text = 'Amount exceeds maximum allowed transfer of $' .. Config.Give.MaxAmount, 
            type = 'error'
        })
        TriggerClientEvent('pd-cash:closeGiveCash', src)
        return
    end
    
    -- Get player identifiers
    local srcFivemId = getPlayerIdentifier(src, 'fivem:')
    local tgtFivemId = getPlayerIdentifier(targetId, 'fivem:')
    
    if not srcFivemId or not tgtFivemId then
        TriggerClientEvent('pd-notifications:notify', src, {
            text = 'Could not identify one or both players', 
            type = 'error'
        })
        TriggerClientEvent('pd-cash:closeGiveCash', src)
        return
    end
    
    -- Get money data
    local srcData = getPlayerMoney(srcFivemId)
    local tgtData = getPlayerMoney(tgtFivemId)
    
    -- Check if source has enough cash
    if srcData.cash < amount then
        TriggerClientEvent('pd-notifications:notify', src, {
            text = 'Not enough cash!', 
            type = 'error'
        })
        TriggerClientEvent('pd-cash:closeGiveCash', src)
        return
    end
    
    -- Proximity check again as a security measure
    local srcPed = GetPlayerPed(src)
    local tgtPed = GetPlayerPed(targetId)
    local srcCoords = GetEntityCoords(srcPed)
    local tgtCoords = GetEntityCoords(tgtPed)
    
    if #(srcCoords - tgtCoords) > Config.Give.Radius then
        TriggerClientEvent('pd-notifications:notify', src, {
            text = 'Player is too far away', 
            type = 'error'
        })
        TriggerClientEvent('pd-cash:closeGiveCash', src)
        return
    end
    
    -- Transfer the money
    srcData.cash = srcData.cash - amount
    
    -- Use direct pd-bank events for more reliable updating
    TriggerEvent('pd-bank:removeCash', src, amount)
    TriggerEvent('pd-bank:addCash', targetId, amount)
    
    -- Notify both players
    TriggerClientEvent('pd-notifications:notify', src, {
        text = string.format('You gave $%d to %s for %s.', amount, GetPlayerName(targetId), reason), 
        type = 'success'
    })
    
    TriggerClientEvent('pd-notifications:notify', targetId, {
        text = string.format('You received $%d from %s for %s.', amount, GetPlayerName(src), reason), 
        type = 'success'
    })
    
    print("[pd-cash] Player " .. GetPlayerName(src) .. " gave $" .. amount .. " to " .. GetPlayerName(targetId))
    
    -- Close the UI
    TriggerClientEvent('pd-cash:closeGiveCash', src)
end)

-- Handle clients requesting all existing cash drops
RegisterServerEvent('pd-cash:requestAllCashDrops')
AddEventHandler('pd-cash:requestAllCashDrops', function()
    local src = source
    local allCashDrops = PD_Cash.getAllCashDrops()
    TriggerClientEvent('pd-cash:receiveAllCashDrops', src, allCashDrops)
    print("[pd-cash] Sent " .. PD_Cash.countCashDrops() .. " cash drops to player " .. GetPlayerName(src))
end)

-- Resource lifecycle events
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("[pd-cash] Resource started - Cash drops enabled: " .. tostring(Config.CashSpawn.Enabled))
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Clean up any resources if needed
        print("[pd-cash] Resource stopped")
    end
end)

-- Player nearby detection
RegisterServerEvent('pd-cash:requestNearbyPlayers')
AddEventHandler('pd-cash:requestNearbyPlayers', function()
    local src = source
    local players = {}
    
    -- Get all online players
    for _, playerId in ipairs(GetPlayers()) do
        if tonumber(playerId) ~= src then -- Don't include self
            table.insert(players, {
                id = playerId,
                name = GetPlayerName(playerId) 
            })
        end
    end
    
    -- Send player list to client
    TriggerClientEvent('pd-cash:setPlayers', src, players)
end)

-- Cash transfer UI cancel button
RegisterServerEvent('pd-cash:denyCash')
AddEventHandler('pd-cash:denyCash', function()
    local src = source
    TriggerClientEvent('pd-notifications:notify', src, {
        text = string.format('Transaction was cancelled'), 
        type = 'error'
    })
    TriggerClientEvent('pd-cash:closeGiveCash', src)
end)

-- Admin status check for notification permissions
RegisterServerEvent('pd-cash:checkAdminStatus')
AddEventHandler('pd-cash:checkAdminStatus', function(notificationType)
    local src = source
    local isAdmin = false
    
    -- Use the pd-core export to check if player is admin
    if exports['pd-core'] and exports['pd-core'].IsPlayerAdmin then
        isAdmin = exports['pd-core']:IsPlayerAdmin(src)
    end
    
    -- Notify the client about their admin status for the specific notification type
    if isAdmin then
        if notificationType == 'spawn' then
            TriggerClientEvent('pd-cash:adminNotification', src, 'spawn', true)
        elseif notificationType == 'attempt' then
            TriggerClientEvent('pd-cash:adminNotification', src, 'attempt', true)
        end
    end
end)

-- Handle clients requesting all existing cash drops
RegisterServerEvent('pd-cash:requestAllCashDrops')
AddEventHandler('pd-cash:requestAllCashDrops', function()
    local src = source
    -- Send all existing cash drops to the client
    for cashId, cashData in pairs(PD_Cash.spawnedCash) do
        TriggerClientEvent('pd-cash:spawnCash', src, cashId, cashData.coords, cashData.amount)
    end
    print("[pd-cash] Sent all cash drops to player " .. GetPlayerName(src))
end)
