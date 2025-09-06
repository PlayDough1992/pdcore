-- pd-cash client: Main client functionality
local spawnedCash = {}
local pickups = {}
local pickupRadius = Config.CashSpawn.PickupRadius

-- Admin status variables
local isAdminForSpawn = false
local isAdminForAttempt = false

-- Define pickup types
local PICKUP_MONEY = GetHashKey("PICKUP_MONEY")
local PICKUP_MONEY_DEP_BAG = GetHashKey("PICKUP_MONEY_DEP_BAG")
local PICKUP_MONEY_MED_BAG = GetHashKey("PICKUP_MONEY_MED_BAG")
local PICKUP_MONEY_PAPER_BAG = GetHashKey("PICKUP_MONEY_PAPER_BAG")
local PICKUP_MONEY_PURSE = GetHashKey("PICKUP_MONEY_PURSE")
local PICKUP_MONEY_SECURITY_CASE = GetHashKey("PICKUP_MONEY_SECURITY_CASE")
local PICKUP_MONEY_VARIABLE = GetHashKey("PICKUP_MONEY_VARIABLE")
local PICKUP_MONEY_WALLET = GetHashKey("PICKUP_MONEY_WALLET")

-- Ensure we have a valid pickup type
local pickupType = PICKUP_MONEY_VARIABLE  -- Default

-- Initialize with debug info
Citizen.CreateThread(function()
    Citizen.Wait(1000)  -- Wait for everything to load
    
    if Config.Debug.Enabled then
        print("[pd-cash] Client initialized, using pickup type: " .. pickupType)
        
        -- List all available pickup types
        print("[pd-cash] Available pickup types:")
        print("PICKUP_MONEY: " .. PICKUP_MONEY)
        print("PICKUP_MONEY_DEP_BAG: " .. PICKUP_MONEY_DEP_BAG)
        print("PICKUP_MONEY_MED_BAG: " .. PICKUP_MONEY_MED_BAG)
        print("PICKUP_MONEY_PAPER_BAG: " .. PICKUP_MONEY_PAPER_BAG)
        print("PICKUP_MONEY_PURSE: " .. PICKUP_MONEY_PURSE)
        print("PICKUP_MONEY_SECURITY_CASE: " .. PICKUP_MONEY_SECURITY_CASE)
        print("PICKUP_MONEY_VARIABLE: " .. PICKUP_MONEY_VARIABLE)
        print("PICKUP_MONEY_WALLET: " .. PICKUP_MONEY_WALLET)
    end
end)

-- NUI: Open/close cash transfer menu
RegisterNetEvent('pd-cash:openGiveCash')
AddEventHandler('pd-cash:openGiveCash', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'showGiveCash' })
    TriggerServerEvent('pd-cash:requestNearbyPlayers')
end)

RegisterNetEvent('pd-cash:setPlayers')
AddEventHandler('pd-cash:setPlayers', function(players)
    SendNUIMessage({ action = 'setPlayers', players = players })
end)

RegisterNetEvent('pd-cash:closeGiveCash')
AddEventHandler('pd-cash:closeGiveCash', function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeGiveCash' })
end)

-- NUI Callbacks
RegisterNUICallback('closeCashUI', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeGiveCash' })
    cb('ok')
end)

RegisterNUICallback('giveCash', function(data, cb)
    TriggerServerEvent('pd-cash:giveCash', data.player, data.amount, data.reason)
    cb('ok')
end)

RegisterNUICallback('getReasons', function(data, cb)
    cb({ reasons = Config.Give.Reasons or {'Other'} })
end)

-- Cash drop handling
RegisterNetEvent('pd-cash:receiveAllCashDrops')
AddEventHandler('pd-cash:receiveAllCashDrops', function(allCashDrops)
    for id, data in pairs(allCashDrops) do
        if not spawnedCash[id] then
            createCashPickup(id, data.coords, data.amount)
        end
    end
end)
-- Create a cash pickup at the given coordinates
function createCashPickup(id, coords, amount)
    spawnedCash[id] = {coords = coords, amount = amount}
    
    -- Only show attempt notification if enabled in config
    if Config.Notifications and Config.Notifications.OnAttempt and Config.Notifications.OnAttempt.Enabled then
        local shouldNotify = true
        
        -- Check if we should only notify admins
        if Config.Notifications.OnAttempt.AdminOnly then
            shouldNotify = isAdminForAttempt
        end
        
        -- Send notification if all conditions are met
        if shouldNotify then
            TriggerEvent('pd-notifications:notify', {
                text = string.format('Attempting to create cash drop worth $%d', amount), 
                type = 'info'
            })
        end
    end
    
    -- Always use the money bag prop since it works reliably
    local propName = "prop_money_bag_01"
    
    -- Handle ground level placement if enabled
    local finalX, finalY, finalZ = coords.x, coords.y, coords.z
    
    if Config.CashSpawn.AlwaysGroundLevel then
        -- Find ground Z at this position
        local ground = 0
        local groundFound = false
        
        for i = 0, 10 do
            -- Try different starting heights to find ground
            local startZ = 1000.0 - (i * 100.0)
            local foundZ, zPos = GetGroundZFor_3dCoord(finalX, finalY, startZ, true)
            
            if foundZ then
                ground = zPos
                groundFound = true
                break
            end
        end
        
        -- If we didn't find ground after 10 attempts, try one last attempt from below
        if not groundFound then
            local foundZ, zPos = GetGroundZFor_3dCoord(finalX, finalY, -10.0, true)
            if foundZ then
                ground = zPos
                groundFound = true
            end
        end
        
        -- Use the found ground height or fallback to original Z
        if groundFound then
            finalZ = ground
            print("[pd-cash] Found ground level at Z: " .. finalZ)
        else
            print("[pd-cash] Could not find ground level, using original Z: " .. finalZ)
        end
    end
    
    -- Create the object at the final position
    local moneyProp = CreateObject(GetHashKey(propName), finalX, finalY, finalZ, true, true, true)
    SetEntityAsMissionEntity(moneyProp, true, true)
    PlaceObjectOnGroundProperly(moneyProp)
    
    -- Apply a slight offset to make it more visible
    local propCoords = GetEntityCoords(moneyProp)
    SetEntityCoords(moneyProp, propCoords.x, propCoords.y, propCoords.z + 0.15, false, false, false, false)
    FreezeEntityPosition(moneyProp, true)
    
    -- Add a light glow effect to the money bag
    local lightHandle = CreateLightEntity(propCoords.x, propCoords.y, propCoords.z + 0.5, 
                                         2.0, 255, 215, 0, 5.0)
    if lightHandle then
        -- Store the light for cleanup
        spawnedCash[id].light = lightHandle
    end
    
    if moneyProp ~= 0 and moneyProp ~= nil then
        pickups[id] = moneyProp
        
        -- Add a blip to make it easier to find (if enabled)
        if Config.CashSpawn.AddBlip then
            -- Use coordinates instead of entity attachment for more reliability
            local propCoords = GetEntityCoords(moneyProp)
            local blip = AddBlipForCoord(propCoords.x, propCoords.y, propCoords.z)
            
            -- Set blip properties
            SetBlipSprite(blip, 431) -- Dollar sign sprite (more visible)
            SetBlipColour(blip, Config.CashSpawn.BlipColor or 2) -- Use config color or default to green
            SetBlipScale(blip, 0.9)
            SetBlipAsShortRange(blip, false) -- Make it visible from further away
            SetBlipPriority(blip, 10) -- Higher priority to ensure it shows up
            
            -- Add blip name
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Cash Drop: $" .. amount)
            EndTextCommandSetBlipName(blip)
            
            -- Store the blip for cleanup later
            spawnedCash[id].blip = blip
            
            -- Debug message
            print("[pd-cash] Created blip for cash drop #" .. id .. " at " .. propCoords.x .. ", " .. propCoords.y .. ", " .. propCoords.z)
        end
        
        -- Show notification based on config settings
        if Config.Notifications and Config.Notifications.OnSpawn and Config.Notifications.OnSpawn.Enabled then
            local shouldNotify = true
            
            -- Check if we should only notify nearby players
            if Config.Notifications.OnSpawn.OnlyToNearbyPlayers then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - coords)
                shouldNotify = distance <= Config.Notifications.OnSpawn.NotifyRadius
            end
            
            -- Check if we should only notify admins
            if shouldNotify and Config.Notifications.OnSpawn.AdminOnly then
                shouldNotify = isAdminForSpawn
            end
            
            -- Send notification if all conditions are met
            if shouldNotify then
                TriggerEvent('pd-notifications:notify', {
                    text = string.format('Cash drop ($%d) spawned nearby!', amount),
                    type = 'success'
                })
            end
        end
        
        print("[pd-cash] Created cash pickup worth $" .. amount .. " at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        return true
    else
        -- Show error notification
        TriggerEvent('pd-notifications:notify', {
            text = string.format('Failed to create cash drop!'),
            type = 'error'
        })
        
        print("[pd-cash] ERROR: Failed to create pickup at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        return false
    end
end

-- Cash pickup events
RegisterNetEvent('pd-cash:spawnCash')
AddEventHandler('pd-cash:spawnCash', function(cashId, coords, amount)
    if not spawnedCash[cashId] then
        createCashPickup(cashId, coords, amount)
    end
end)

RegisterNetEvent('pd-cash:removeCash')
AddEventHandler('pd-cash:removeCash', function(cashId)
    spawnedCash[cashId] = nil
    -- For pickups created with CreatePickupRotate, we don't need to manually delete them
    -- as the game handles cleanup when they are collected
    pickups[cashId] = nil
end)

-- Admin status response from server
RegisterNetEvent('pd-cash:adminNotification')
AddEventHandler('pd-cash:adminNotification', function(notificationType, status)
    if notificationType == 'spawn' then
        isAdminForSpawn = status
        -- If admin and notifications are enabled, show all existing cash drops
        if isAdminForSpawn and Config.Notifications.OnSpawn.Enabled and Config.Notifications.OnSpawn.AdminOnly then
            for cashId, data in pairs(spawnedCash) do
                TriggerEvent('pd-notifications:notify', {
                    text = string.format('Cash drop #%d ($%d) at %0.1f, %0.1f', 
                                        cashId, data.amount, data.coords.x, data.coords.y),
                    type = 'success'
                })
            end
        end
    elseif notificationType == 'attempt' then
        isAdminForAttempt = status
    end
end)

-- Main thread for cash pickup handling and visualization
Citizen.CreateThread(function()
    -- Wait for everything to load
    Citizen.Wait(3000)
    
    -- Request all existing cash drops when joining
    TriggerServerEvent('pd-cash:requestAllCashDrops')
    
    -- Check admin status if needed for notifications
    if Config.Notifications.OnSpawn.AdminOnly or Config.Notifications.OnAttempt.AdminOnly then
        -- We'll check for both types of notifications
        TriggerServerEvent('pd-cash:checkAdminStatus', 'spawn')
        TriggerServerEvent('pd-cash:checkAdminStatus', 'attempt')
    end
    
    -- Main loop for checking pickup radius and drawing markers
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local found = false
        
        -- Process cash pickups
        for cashId, data in pairs(spawnedCash) do
            local dist = #(playerCoords - vector3(data.coords.x, data.coords.y, data.coords.z))
            
            -- Only draw markers for nearby cash (optimization)
            if dist < 20.0 then
                -- Draw 3D marker above the cash (if enabled)
                if Config.CashSpawn.ShowMarker then
                    DrawMarker(21, data.coords.x, data.coords.y, data.coords.z + 1.0, 
                              0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 
                              255, 215, 0, 180, true, true, 2, false, nil, nil, false)
                end
                
                -- Add particle effect to make it more visible (if enabled)
                if Config.CashSpawn.VisualEffects and (GetGameTimer() % 1000) < 500 then
                    UseParticleFxAssetNextCall("core")
                    StartParticleFxNonLoopedAtCoord("ent_amb_money_cloud", 
                                                    data.coords.x, data.coords.y, data.coords.z + 0.5, 
                                                    0.0, 0.0, 0.0, 0.5, false, false, false)
                end
                
                -- Draw 3D text with amount and pickup prompt when close
                if dist < 8.0 then
                    DrawText3D(data.coords.x, data.coords.y, data.coords.z + 1.0, 
                              string.format('$%d~n~~g~[E]~w~ to pick up', data.amount))
                    
                    -- Check if E key is pressed
                    if dist < Config.CashSpawn.PickupRadius and IsControlJustReleased(0, 38) then -- E key
                        -- Remove the cash pickup
                        if pickups[cashId] ~= nil then
                            if DoesEntityExist(pickups[cashId]) then
                                -- Play pickup effects before deleting
                                PlayPickupEffects(cashId, data.amount)
                                -- Then delete after a short delay
                                Citizen.Wait(800)
                                DeleteEntity(pickups[cashId])
                            end
                            pickups[cashId] = nil
                        end
                        
                        -- Remove blip if it exists
                        if spawnedCash[cashId] and spawnedCash[cashId].blip then
                            RemoveBlip(spawnedCash[cashId].blip)
                        end
                        
                        -- Tell the server to add the money to the player's account
                        TriggerServerEvent('pd-cash:pickupCash', cashId)
                        
                        -- Play pickup animation
                        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)
                        Citizen.Wait(2000)
                        ClearPedTasks(playerPed)
                        
                        -- Only show one notification (removed duplicate)
                        
                        -- Remove from local cache
                        spawnedCash[cashId] = nil
                        found = true
                        break
                    end
                end
            end
        end
        
        -- If we found and processed a pickup, wait a bit before continuing
        if found then
            Citizen.Wait(500)
        end
    end
end)

-- Function to create a light entity (safe wrapper)
function CreateLightEntity(x, y, z, radius, r, g, b, intensity)
    -- Check if the function exists
    if not DrawLightWithRange then
        return nil
    end
    
    -- Create the light (using a thread since we can't create persistent lights directly)
    local lightId = 'light_' .. math.random(1000000)
    
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            -- Check if we should stop drawing the light
            if not spawnedCash[lightId] then
                return
            end
            
            -- Draw the light
            DrawLightWithRange(x, y, z, r/255, g/255, b/255, radius, intensity)
        end
    end)
    
    return lightId
end

-- Function to play pickup animation and effects
function PlayPickupEffects(cashId, amount)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(pickups[cashId])
    
    -- Play pickup animation
    if not IsEntityPlayingAnim(playerPed, "mp_common", "givetake1_a", 3) then
        RequestAnimDict("mp_common")
        while not HasAnimDictLoaded("mp_common") do
            Citizen.Wait(10)
        end
        
        TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)
        Citizen.Wait(1000)
        ClearPedTasks(playerPed)
    end
    
    -- Play pickup sound
    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
    
    -- Show particle effects if enabled
    if Config.CashSpawn.VisualEffects then
        UseParticleFxAssetNextCall("core")
        StartParticleFxNonLoopedAtCoord("ent_sht_money", 
                                        coords.x, coords.y, coords.z + 0.5, 
                                        0.0, 0.0, 0.0, 1.0, false, false, false)
                                        
        -- Show some flying dollar bills
        for i = 1, 3 do
            UseParticleFxAssetNextCall("core")
            StartParticleFxNonLoopedAtCoord("ent_brk_banknotes", 
                                           coords.x + math.random(-1, 1) * 0.5, 
                                           coords.y + math.random(-1, 1) * 0.5, 
                                           coords.z + 0.5 + math.random(0, 1) * 0.3, 
                                           0.0, 0.0, 0.0, 1.0, false, false, false)
            Citizen.Wait(100)
        end
    end
end

-- Register command to open cash transfer UI
RegisterCommand('givecash', function()
    TriggerEvent('pd-cash:openGiveCash')
end, false)

-- Register position command for adding new locations
if Config.Debug.Enabled then
    RegisterCommand('mypos', function()
        local coords = GetEntityCoords(PlayerPedId())
        local posString = string.format('vector3(%0.2f, %0.2f, %0.2f)', coords.x, coords.y, coords.z)
        
        TriggerEvent('pd-notifications:notify', {
            text = 'Position: ' .. posString,
            type = 'info'
        })
        
        -- Copy to clipboard if possible
        if AddTextEntry and UpdateCompletionTextEntry then
            AddTextEntry('CASH_CLIPBOARD', posString)
            UpdateCompletionTextEntry('CASH_CLIPBOARD')
        end
    end, false)
end
