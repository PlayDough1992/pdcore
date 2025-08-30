local function ApplyVehicleColors(vehicle, colors)
    if not vehicle or not colors then return end
    
    -- Primary & Secondary colors
    if colors.primary and colors.secondary then
        SetVehicleColours(vehicle, colors.primary, colors.secondary)
    end
    
    -- Pearl & Wheel colors
    if colors.pearl and colors.wheel then
        SetVehicleExtraColours(vehicle, colors.pearl, colors.wheel)
    end
    
    -- Custom RGB if specified
    if colors.customPrimary then
        SetVehicleCustomPrimaryColour(vehicle, 
            colors.customPrimary.r,
            colors.customPrimary.g,
            colors.customPrimary.b
        )
    end
    
    if colors.customSecondary then
        SetVehicleCustomSecondaryColour(vehicle,
            colors.customSecondary.r,
            colors.customSecondary.g,
            colors.customSecondary.b
        )
    end
end

RegisterNUICallback('getAvailableLiveries', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then 
        cb({success = false})
        return
    end

    local numLiveries = GetVehicleLiveryCount(vehicle)
    local currentLivery = GetVehicleLivery(vehicle)
    
    cb({
        success = true,
        current = currentLivery,
        total = numLiveries
    })
end)

RegisterNUICallback('applyLivery', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then 
        cb({success = false})
        return
    end

    SetVehicleLivery(vehicle, data.liveryIndex)
    cb({success = true})
end)

RegisterNUICallback('applyColors', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then 
        cb({success = false})
        return
    end

    ApplyVehicleColors(vehicle, data.colors)
    cb({success = true})
end)

-- Load vehicle modifications
RegisterNUICallback('loadModifications', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local mods = {}
    -- Get all available mods
    for modType, info in pairs(Config.ModTypes) do
        local modIndex = GetVehicleMod(vehicle, GetModTypeIndex(modType))
        local maxMod = GetNumVehicleMods(vehicle, GetModTypeIndex(modType)) - 1
        mods[modType] = {
            current = modIndex,
            max = maxMod,
            name = info.name
        }
    end

    cb({success = true, mods = mods})
end)

-- Load vehicle extras
RegisterNUICallback('loadExtras', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local extras = {}
    for i = 0, 14 do
        if DoesExtraExist(vehicle, i) then
            extras[i] = {
                id = i,
                enabled = IsVehicleExtraTurnedOn(vehicle, i)
            }
        end
    end

    cb({success = true, extras = extras})
end)

-- Load vehicle liveries
RegisterNUICallback('loadLiveries', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local liveryCount = GetVehicleLiveryCount(vehicle)
    local currentLivery = GetVehicleLivery(vehicle)

    cb({
        success = true,
        current = currentLivery,
        total = liveryCount
    })
end)

-- Save current vehicle configuration
function SaveCurrentVehicle(name)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local vehicleData = {
        name = name,
        model = GetEntityModel(vehicle),
        modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
        colors = {
            primary = {GetVehicleColours(vehicle)},
            secondary = {GetVehicleExtraColours(vehicle)},
            custom = {
                primary = {GetVehicleCustomPrimaryColour(vehicle)},
                secondary = {GetVehicleCustomSecondaryColour(vehicle)}
            }
        },
        mods = {},
        extras = {},
        livery = GetVehicleLivery(vehicle)
    }

    -- Get all vehicle mods
    for i = 0, 49 do
        local modValue = GetVehicleMod(vehicle, i)
        if modValue ~= -1 then
            vehicleData.mods[tostring(i)] = modValue
        end
    end

    -- Get vehicle extras
    for i = 0, 14 do
        if DoesExtraExist(vehicle, i) then
            vehicleData.extras[tostring(i)] = IsVehicleExtraOn(vehicle, i)
        end
    end

    TriggerServerEvent('pd-carspawner:saveVehicle', vehicleData)
end

-- Register save vehicle callback
RegisterNUICallback('saveVehicle', function(data, cb)
    if not data.name then
        cb({success = false, error = "No name provided"})
        return
    end
    
    SaveCurrentVehicle(data.name)
    cb({success = true})
end)

-- Handle received saved vehicles
RegisterNetEvent('pd-carspawner:receiveSavedVehicles')
AddEventHandler('pd-carspawner:receiveSavedVehicles', function(vehicles)
    SendNUIMessage({
        type = "updateSavedVehicles",
        vehicles = vehicles
    })
end)

-- Vehicle Modifications
RegisterNUICallback('applyMod', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    if data.modType and data.modIndex then
        SetVehicleMod(vehicle, GetModTypeIndex(data.modType), data.modIndex, false)
        UpdateVehicleStats()
        cb({success = true})
    end
end)

-- Vehicle Colors
RegisterNUICallback('applyColors', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    if data.primary then
        SetVehicleCustomPrimaryColour(vehicle, data.primary.r, data.primary.g, data.primary.b)
    end
    if data.secondary then
        SetVehicleCustomSecondaryColour(vehicle, data.secondary.r, data.secondary.g, data.secondary.b)
    end
    cb({success = true})
end)

-- Vehicle Extras
RegisterNUICallback('toggleExtra', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    if data.id then
        SetVehicleExtra(vehicle, data.id, not IsVehicleExtraTurnedOn(vehicle, data.id))
        cb({success = true})
    end
end)

-- Vehicle Livery
RegisterNUICallback('setLivery', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    if data.index then
        SetVehicleLivery(vehicle, data.index)
        cb({success = true})
    end
end)