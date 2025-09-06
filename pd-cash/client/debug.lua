-- pd-cash: Debug commands and utilities
-- Only loaded when Config.Debug.Enabled = true

if not Config.Debug.Enabled then return end

-- Create test cash pickups for debugging with guaranteed blip
RegisterCommand('testblipedcash', function(source, args)
    local amount = tonumber(args[1]) or 500
    local playerPed = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0) -- 1m in front of player
    
    -- Send notification
    TriggerEvent('pd-notifications:notify', {
        text = string.format('Creating test cash drop with blip worth $%d', amount),
        type = 'info'
    })
    
    -- Force the config value for blips to be true for this test
    local originalBlipSetting = Config.CashSpawn.AddBlip
    Config.CashSpawn.AddBlip = true
    
    -- Create a local test pickup (not synchronized with server)
    local testId = 'test_' .. GetGameTimer()
    createCashPickup(testId, coords, amount)
    
    -- Restore original setting
    Config.CashSpawn.AddBlip = originalBlipSetting
    
    -- Print location to console
    print(string.format("[pd-cash] Test cash created at %.2f, %.2f, %.2f", coords.x, coords.y, coords.z))
end, false)

-- Test all different pickup types
RegisterCommand('testallcash', function()
    local playerPed = PlayerPedId()
    local baseCoords = GetEntityCoords(playerPed)
    local spacing = 1.0
    
    -- Test different money props
    local props = {
        "prop_money_bag_01",
        "prop_cash_pile_01",
        "prop_cash_pile_02",
        "prop_cash_case_01",
        "prop_cash_case_02",
        "prop_cash_crate_01",
        "prop_cash_envelope_01",
        "prop_cash_note_01"
    }
    
    -- Create each prop type in a line
    for i, propName in ipairs(props) do
        local coords = GetOffsetFromEntityInWorldCoords(playerPed, (i - 1) * spacing, 1.0, 0.0)
        local testId = 'test_' .. propName
        
        -- Create the prop
        local propObj = CreateObject(GetHashKey(propName), coords.x, coords.y, coords.z - 0.9, true, true, true)
        
        if propObj ~= 0 and propObj ~= nil then
            SetEntityAsMissionEntity(propObj, true, true)
            PlaceObjectOnGroundProperly(propObj)
            FreezeEntityPosition(propObj, true)
            
            -- Store in local cache
            spawnedCash[testId] = {coords = coords, amount = 100 * i, name = propName}
            pickups[testId] = propObj
            
            -- Show debug notification
            TriggerEvent('pd-notifications:notify', {
                text = string.format('Created %s', propName),
                type = 'info'
            })
        else
            TriggerEvent('pd-notifications:notify', {
                text = string.format('Failed to create %s', propName),
                type = 'error'
            })
        end
    end
end, false)

-- Add command to check active cash drops and their blips
RegisterCommand('showcash', function()
    local count = 0
    for k, v in pairs(spawnedCash) do
        count = count + 1
    end
    
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 0},
        multiline = true,
        args = {'[CASH]', 'Active cash drops: ' .. count}
    })
    
    if count == 0 then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[CASH]', 'No cash drops found! Try using /spawncash or /testblipedcash'}
        })
    else
        for id, data in pairs(spawnedCash) do
            local coordStr = string.format('%.1f, %.1f, %.1f', data.coords.x, data.coords.y, data.coords.z)
            local hasBlip = data.blip ~= nil
            local blipInfo = hasBlip and "Blip ID: " .. tostring(data.blip) or "No blip"
            
            TriggerEvent('chat:addMessage', {
                color = {0, 255, 255},
                args = {'[CASH]', 'ID: ' .. id .. ' | $' .. data.amount .. ' | ' .. blipInfo .. ' | Location: ' .. coordStr}
            })
        end
    end
end, false)

-- Client command to spawn cash at your position
RegisterCommand('cashhere', function(source, args)
    local amount = tonumber(args[1]) or 250
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    TriggerServerEvent('pd-cash:debugSpawnCash', coords, amount)
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        args = {'[CASH]', 'Requested cash spawn worth $' .. amount}
    })
end, false)

-- Toggle debug info display
local debugDisplay = false
RegisterCommand('cashdebug', function()
    debugDisplay = not debugDisplay
    TriggerEvent('pd-notifications:notify', {
        text = debugDisplay and 'Cash debug display enabled' or 'Cash debug display disabled',
        type = 'info'
    })
end, false)

-- Display debug info for cash pickups
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if debugDisplay and next(spawnedCash) ~= nil then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for id, data in pairs(spawnedCash) do
                local dist = #(playerCoords - vector3(data.coords.x, data.coords.y, data.coords.z))
                
                if dist < 50.0 then
                    -- Draw line from player to cash
                    DrawLine(
                        playerCoords.x, playerCoords.y, playerCoords.z,
                        data.coords.x, data.coords.y, data.coords.z,
                        255, 0, 0, 255
                    )
                    
                    -- Draw debug text
                    local debugText = string.format(
                        "ID: %s~n~Amount: $%d~n~Dist: %.2f~n~Pickup: %s",
                        id, data.amount, dist,
                        (pickups[id] ~= nil and DoesEntityExist(pickups[id])) and "Valid" or "Invalid"
                    )
                    
                    -- Draw above the normal cash text
                    DrawText3D(data.coords.x, data.coords.y, data.coords.z + 1.0, debugText)
                end
            end
        end
    end
end)
