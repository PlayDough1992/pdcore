-- State management
local state = {
    isMenuOpen = false,
    currentVehicle = nil,
    menuData = nil
}

-- Debug mode
local DEBUG = true
local function debugPrint(...)
    if DEBUG then
        print('[PDCarSpawner]', ...)
    end
end

-- Utility Functions
local function ShowNotification(message, notificationType)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
    
    if notificationType == 'error' then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)
    end
end

local function DeleteVehicle(vehicle)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteEntity(vehicle)
    end
end

local function SetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return end
    
    -- Set perfect health values
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleOilLevel(vehicle, 1000.0)
    
    -- Fix any damage
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    
    -- Set engine state
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleUndriveable(vehicle, false)
    
    -- Set other properties
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleNumberPlateText(vehicle, Config.SpawnSettings.defaultProperties.plate)
end

-- Menu Functions
local function OpenMenu()
    if state.isMenuOpen then return end
    debugPrint('Opening menu')
    
    -- Set state
    state.isMenuOpen = true
    
    -- Set NUI focus
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    
    -- Request menu data from server
    TriggerServerEvent('pd-carspawner:server:requestMenu')
end

local function CloseMenu()
    if not state.isMenuOpen then return end
    debugPrint('Closing menu')
    
    -- Reset state
    state.isMenuOpen = false
    
    -- Remove NUI focus
    SetNuiFocus(false, false)
    
    -- Hide NUI
    SendNUIMessage({
        action = 'hide'
    })
end

-- Event Handlers
RegisterNetEvent('pd-carspawner:client:receiveMenu')
AddEventHandler('pd-carspawner:client:receiveMenu', function(menuData)
    debugPrint('Received menu data')
    
    -- Store menu data
    state.menuData = menuData
    
    -- Show menu
    SendNUIMessage({
        action = 'show',
        categories = menuData.categories,
        isAdmin = menuData.isAdmin
    })
end)

RegisterNetEvent('pd-carspawner:client:spawnVehicle')
AddEventHandler('pd-carspawner:client:spawnVehicle', function(model)
    debugPrint('Attempting to spawn vehicle:', model)
    
    -- Delete old vehicle if exists and config allows
    if Config.SpawnSettings.deleteOldVehicle and state.currentVehicle then
        DeleteVehicle(state.currentVehicle)
        state.currentVehicle = nil
    end
    
    -- Load model
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    -- Wait for model to load
    local tries = 0
    while not HasModelLoaded(hash) and tries < 50 do
        tries = tries + 1
        Wait(10)
    end
    
    if not HasModelLoaded(hash) then
        ShowNotification('Failed to load vehicle model', 'error')
        return
    end
    
    -- Get spawn position
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    
    -- Calculate spawn position in front of player
    local spawnPos = vector3(
        coords.x + forward.x * Config.SpawnSettings.maxDistance,
        coords.y + forward.y * Config.SpawnSettings.maxDistance,
        coords.z
    )
    
    -- Spawn vehicle
    state.currentVehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, heading, true, false)
    
    if not DoesEntityExist(state.currentVehicle) then
        ShowNotification('Failed to spawn vehicle', 'error')
        return
    end
    
    -- Set as mission entity and place properly
    SetEntityAsMissionEntity(state.currentVehicle, true, true)
    SetVehicleOnGroundProperly(state.currentVehicle)
    
    -- Small delay to ensure vehicle is fully spawned
    Wait(100)
    
    -- Set vehicle properties
    SetVehicleProperties(state.currentVehicle)
    
    -- Double-check vehicle state
    SetVehicleNeedsToBeHotwired(state.currentVehicle, false)
    SetVehicleHasBeenOwnedByPlayer(state.currentVehicle, true)
    
    -- Put player in vehicle if config allows
    if Config.SpawnSettings.spawnInVehicle then
        TaskWarpPedIntoVehicle(playerPed, state.currentVehicle, -1)
    end
    
    -- Clean up
    SetModelAsNoLongerNeeded(hash)
    ShowNotification('Vehicle spawned successfully')
end)

RegisterNetEvent('pd-carspawner:client:notification')
AddEventHandler('pd-carspawner:client:notification', function(message, type)
    ShowNotification(message, type)
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseMenu()
    cb({})
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    if not data.model then
        cb({ status = 'error', message = 'No vehicle model specified' })
        return
    end
    
    TriggerServerEvent('pd-carspawner:server:requestVehicle', data.model)
    cb({ status = 'success' })
end)

RegisterNUICallback('repairVehicle', function(data, cb)
    if state.currentVehicle and DoesEntityExist(state.currentVehicle) then
        SetVehicleFixed(state.currentVehicle)
        SetVehicleDeformationFixed(state.currentVehicle)
        SetVehicleUndriveable(state.currentVehicle, false)
        ShowNotification('Vehicle repaired')
    end
    cb({})
end)

RegisterNUICallback('cleanVehicle', function(data, cb)
    if state.currentVehicle and DoesEntityExist(state.currentVehicle) then
        SetVehicleDirtLevel(state.currentVehicle, 0.0)
        ShowNotification('Vehicle cleaned')
    end
    cb({})
end)

RegisterNUICallback('flipVehicle', function(data, cb)
    if state.currentVehicle and DoesEntityExist(state.currentVehicle) then
        local vehicleCoords = GetEntityCoords(state.currentVehicle)
        SetEntityCoords(state.currentVehicle, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.0, false, false, false, false)
        SetVehicleOnGroundProperly(state.currentVehicle)
        ShowNotification('Vehicle flipped')
    end
    cb({})
end)

RegisterNUICallback('deleteVehicle', function(data, cb)
    if state.currentVehicle and DoesEntityExist(state.currentVehicle) then
        DeleteVehicle(state.currentVehicle)
        state.currentVehicle = nil
        ShowNotification('Vehicle deleted')
    end
    cb({})
end)

-- Initialize
CreateThread(function()
    debugPrint('Initializing...')
    
    -- Register commands
    RegisterCommand('vehicles', function()
        debugPrint('Command triggered: vehicles')
        OpenMenu()
    end)
    
    RegisterCommand('closevehicles', function()
        debugPrint('Command triggered: closevehicles')
        CloseMenu()
    end)
    
    -- Register keybind
    RegisterKeyMapping('vehicles', 'Open Vehicle Spawner', 'keyboard', Config.Keys.toggle)
    
    debugPrint('Initialized successfully')
end)
