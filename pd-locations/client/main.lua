local display = false

RegisterNetEvent('pd-locations:openSelector')
AddEventHandler('pd-locations:openSelector', function()
    SetDisplay(true)
end)

RegisterNetEvent('pd-locations:openNameInput')
AddEventHandler('pd-locations:openNameInput', function()
    local ped = PlayerPedId()
    tempLocation = {
        coords = GetEntityCoords(ped),
        heading = GetEntityHeading(ped)
    }
    
    SendNUIMessage({
        type = "showNameInput",
        status = true
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('saveNewLocation', function(data, cb)
    if not data.name then return end
    
    TriggerServerEvent('pd-locations:saveNewLocation', {
        name = data.name,
        coords = tempLocation.coords,
        heading = tempLocation.heading
    })
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "showNameInput",
        status = false
    })
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    SetDisplay(false)
    SetRadarBigmapEnabled(false, false)
    cb('ok')
end)

RegisterNUICallback('selectLocation', function(data, cb)
    local location = Config.Locations[data.locationId]
    if location then
        SetDisplay(false)
        DoScreenFadeOut(500)
        Wait(500)
        
        -- Only update position, not model
        local ped = PlayerPedId()
        SetEntityCoords(ped, location.coords.x, location.coords.y, location.coords.z)
        SetEntityHeading(ped, location.heading)
        
        Wait(500)
        DoScreenFadeIn(500)
        
        TriggerEvent('pd-notifications:notify', {
            text = "Welcome to " .. location.label,
            type = "success"
        })
    end
    cb('ok')
end)

-- Add the command that anyone can use
RegisterCommand('tport', function()
    TriggerEvent('pd-locations:openSelector')
end)

-- Add event handler for location updates
RegisterNetEvent('pd-locations:updateLocations')
AddEventHandler('pd-locations:updateLocations', function(newLocations)
    -- Update local config
    Config.Locations = newLocations
    
    -- If menu is open, refresh it
    if display then
        SendNUIMessage({
            type = "ui",
            status = true,
            locations = Config.Locations
        })
    end
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    
    SendNUIMessage({
        type = "ui",
        status = bool,
        locations = Config.Locations -- This will now always have the latest locations
    })
end

-- Open location selector on first spawn
AddEventHandler('playerSpawned', function()
    Wait(1000) -- Short delay to ensure everything is loaded
    TriggerEvent('pd-locations:openSelector')
end)