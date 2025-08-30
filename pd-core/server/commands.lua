-- Admin Commands

-- Helper function to get player license from server ID
local function GetPlayerLicense(serverId)
    if not serverId then return nil end
    
    local identifiers = GetPlayerIdentifiers(serverId)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

-- Give item command
RegisterCommand('giveitem', function(source, args)
    if not exports['pd-core']:IsPlayerAdmin(source) then 
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command",
            type = "error"
        })
        return 
    end

    local targetId = tonumber(args[1])
    local itemName = args[2]
    local quantity = tonumber(args[3]) or 1

    local targetLicense = GetPlayerLicense(targetId)
    if not targetLicense then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Invalid player ID",
            type = "error"
        })
        return
    end

    TriggerEvent('pd-inventory:addItem', targetId, itemName, quantity)
    
    TriggerClientEvent('pd-notifications:notify', source, {
        text = string.format("Gave %dx %s to %s", quantity, itemName, targetLicense),
        type = "success"
    })
end)

-- Give money command
RegisterCommand('givemoney', function(source, args)
    if not exports['pd-core']:IsPlayerAdmin(source) then 
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command",
            type = "error"
        })
        return 
    end

    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])

    if not targetId or not amount then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Usage: /givemoney [id] [amount]",
            type = "error"
        })
        return
    end

    local targetLicense = GetPlayerLicense(targetId)
    if not targetLicense then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Invalid player ID",
            type = "error"
        })
        return
    end

    -- Cross reference with pd-bank files
    local path = GetResourcePath('pd-bank')
    local filePath = path .. '/playermoney/' .. targetLicense .. '.json'
    
    if not LoadResourceFile('pd-bank', 'playermoney/' .. targetLicense .. '.json') then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Player bank account not found",
            type = "error"
        })
        return
    end

    TriggerEvent('pd-bank:addMoney', targetId, amount)
    
    TriggerClientEvent('pd-notifications:notify', source, {
        text = string.format("Gave $%s to %s", amount, targetLicense),
        type = "success"
    })
end)

-- Vehicle repair command
RegisterCommand('fix', function(source)
    if not exports['pd-core']:IsPlayerAdmin(source) then return end
    TriggerClientEvent('pd-core:fixVehicle', source)
end)

-- Delete area peds command
RegisterCommand('dvp', function(source)
    if not exports['pd-core']:IsPlayerAdmin(source) then return end
    TriggerClientEvent('pd-core:clearAreaPeds', source)
end)

-- Delete all vehicles command
RegisterCommand('dvall', function(source)
    if not exports['pd-core']:IsPlayerAdmin(source) then return end
    TriggerClientEvent('pd-core:clearAllVehicles', -1)
end)

-- Boost command
RegisterCommand('boost', function(source)
    if not exports['pd-core']:IsPlayerAdmin(source) then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You don't have permission to use this command",
            type = "error"
        })
        return
    end

    TriggerClientEvent('pd-core:toggleBoost', source)
end)

-- Broadcast boost activation to all players
RegisterNetEvent('pd-core:broadcastBoost')
AddEventHandler('pd-core:broadcastBoost', function(netId)
    local source = source
    if not exports['pd-core']:IsPlayerAdmin(source) then return end
    
    TriggerClientEvent('pd-notifications:notify', -1, {
        text = "WARNING: ADMIN BOOST ACTIVATED",
        type = "error",
        timeout = 5000
    })
    
    -- Broadcast to all clients to create blip
    TriggerClientEvent('pd-core:createBoostBlip', -1, netId)
end)

-- Delete vehicle command (for all players)
RegisterCommand('dv', function(source)
    local playerName = GetPlayerName(source)
    -- Send player name along with the event
    TriggerClientEvent('pd-core:deleteVehicle', source, playerName)
end)

-- Add new event handler for admin notifications
RegisterNetEvent('pd-core:notifyAdmins')
AddEventHandler('pd-core:notifyAdmins', function(message)
    -- Get all players
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        -- Check if player is admin
        if exports['pd-core']:IsPlayerAdmin(tonumber(playerId)) then
            TriggerClientEvent('pd-notifications:notify', playerId, {
                text = message,
                type = "warning",
                timeout = 10000
            })
        end
    end
end)

RegisterServerEvent('pd-core:checkVehicleOccupants')
AddEventHandler('pd-core:checkVehicleOccupants', function(vehicle, occupants, playerName, sourcePlayerId)
    local source = source
    local hasAdmin = false
    local isSourceAdmin = exports['pd-core']:IsPlayerAdmin(sourcePlayerId)
    
    -- Only check for admin occupants if source is NOT an admin
    if not isSourceAdmin then
        -- Check if any occupant is an admin
        for _, playerId in ipairs(occupants) do
            if exports['pd-core']:IsPlayerAdmin(playerId) then
                hasAdmin = true
                break
            end
        end
        
        if hasAdmin then
            -- Notify all admins about the attempt
            local players = GetPlayers()
            for _, adminId in ipairs(players) do
                if exports['pd-core']:IsPlayerAdmin(tonumber(adminId)) then
                    TriggerClientEvent('pd-notifications:notify', adminId, {
                        text = string.format("Player: %s just attempted to use /dv on an occupied admin vehicle.", playerName),
                        type = "warning",
                        timeout = 10000
                    })
                end
            end
            
            -- Notify the player who tried to delete
            TriggerClientEvent('pd-notifications:notify', source, {
                text = "Access Denied: Cannot delete an admin vehicle.",
                type = "error",
                timeout = 5000
            })
        end
    end
    
    -- Send response back to client - allow if source is admin or if no admins in vehicle
    TriggerClientEvent('pd-core:deleteVehicleResponse', source, isSourceAdmin or not hasAdmin, vehicle)
end)

-- Car spawn command for all players
RegisterCommand('car', function(source, args)
    local playerName = GetPlayerName(source)
    local isAdmin = exports['pd-core']:IsPlayerAdmin(source)
    local model = args[1]
    
    if not model then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Usage: /car [model]",
            type = "error",
            timeout = 3000
        })
        return
    end
    
    -- Trigger client event to spawn car
    TriggerClientEvent('pd-core:spawnCar', source, model, isAdmin)
end)

-- Event to notify admins of car spawns
RegisterServerEvent('pd-core:notifyCarSpawn')
AddEventHandler('pd-core:notifyCarSpawn', function(model, coords)
    local source = source
    local playerName = GetPlayerName(source)
    
    -- Get all admins and notify them
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if exports['pd-core']:IsPlayerAdmin(tonumber(playerId)) then
            -- Send notification
            TriggerClientEvent('pd-notifications:notify', playerId, {
                text = string.format("Player: %s just spawned a %s at %s", 
                    playerName, 
                    model:upper(), 
                    string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z)
                ),
                type = "warning",
                timeout = 5000
            })
            
            -- Create temporary blip for admins
            TriggerClientEvent('pd-core:createTempCarBlip', playerId, coords)
        end
    end
end)

-- Add upload speed logging event
RegisterServerEvent('pd-core:logUploadSpeed')
AddEventHandler('pd-core:logUploadSpeed', function(uploadSpeed)
    local source = source
    local playerName = GetPlayerName(source)
    
    -- Debug print to verify server is receiving events
    print(string.format("DEBUG: Received upload speed event from %s", playerName))
    
    -- Log to txAdmin console with explicit print
    print(string.format("^1[pd-core]Upload Speed Tracker: WARNING %s's upload speeds dropped below 5mbps! %s is at risk for timing out! (Current: %.2f Mbps)^7", 
        playerName, playerName, uploadSpeed))
        
    -- Also notify all admins
    TriggerEvent('pd-core:notifyAdmins', 
        string.format("WARNING: %s has low upload speed (%.2f Mbps)", 
            playerName, uploadSpeed)
    )
end)