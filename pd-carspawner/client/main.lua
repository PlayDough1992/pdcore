local display = false
local currentVehicle = nil
local lastCategory = "compacts"
local vehicleList = {}

-- Initialize resource
CreateThread(function()
    -- Make sure menu is closed on start
    display = false
    SetNuiFocus(false, false)
    
    -- Load vehicle list but don't open menu
    LoadVehicleList()
end)

-- Main menu toggle
RegisterCommand('carspawner', function()
    SetDisplay(not display)
end)

RegisterKeyMapping('carspawner', 'Open Car Spawner Menu', 'keyboard', 'F6')

-- Helper Functions
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SetNuiFocusKeepInput(false)
    
    -- Disable all controls while menu is open
    if bool then
        CreateThread(function()
            while display do
                Wait(0)
                DisableAllControlActions(0)
                EnableControlAction(0, 249, true) -- N key for push-to-talk
                EnableControlAction(0, 245, true) -- T key for chat
                
                if IsDisabledControlJustPressed(0, 200) then -- ESC
                    SetDisplay(false)
                    break
                end
            end
        end)
    end
    
    SendNUIMessage({
        type = "setDisplay",
        display = bool,
        categories = Config.VehicleCategories,
        vehicles = vehicleList,
        currentCategory = lastCategory
    })
    
    if bool then
        -- Update all stats when opening menu
        UpdateVehicleStats()
        UpdateCurrentModifications()
        UpdateExtrasState()
        UpdateLiveryState()
    end
end

function UpdateVehicleStats()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local stats = {
        speed = math.floor((GetVehicleEstimatedMaxSpeed(vehicle) * 3.6) / 3.0),
        acceleration = math.floor(GetVehicleAcceleration(vehicle) * 100),
        braking = math.floor(GetVehicleMaxBraking(vehicle) * 100),
        handling = math.floor(GetVehicleMaxTraction(vehicle) * 10)
    }

    SendNUIMessage({
        type = "updateStats",
        stats = stats
    })
end

function UpdateCurrentModifications()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local mods = {}
    for modType, info in pairs(Config.ModTypes) do
        local modTypeIndex = GetModTypeIndex(modType)
        local currentMod = GetVehicleMod(vehicle, modTypeIndex)
        local maxMod = GetNumVehicleMods(vehicle, modTypeIndex) - 1
        
        mods[modType] = {
            current = currentMod,
            max = maxMod,
            name = info.name
        }
    end

    SendNUIMessage({
        type = "updateMods",
        mods = mods
    })
end

function UpdateExtrasState()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local extras = {}
    for i = 0, 14 do
        if DoesExtraExist(vehicle, i) then
            extras[i] = {
                id = i,
                enabled = IsVehicleExtraTurnedOn(vehicle, i)
            }
        end
    end

    SendNUIMessage({
        type = "updateExtras",
        extras = extras
    })
end

function UpdateLiveryState()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    -- Get actual number of available liveries from the vehicle model
    local liveryCount = GetVehicleLiveryCount(vehicle)
    local currentLivery = GetVehicleLivery(vehicle)
    
    -- Check for custom liveries
    local model = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(model):lower()
    local customLiveries = {}
    
    -- Load custom liveries if they exist
    local customLiveryCount = 0
    local streamFolder = GetResourcePath(GetCurrentResourceName()) .. '/stream/'
    if DoesFileExist(streamFolder .. modelName .. '_livery.ytd') then
        local files = scandir(streamFolder)
        for _, file in ipairs(files) do
            if file:match('^' .. modelName .. '_livery%d+%.ytd$') then
                customLiveryCount = customLiveryCount + 1
                customLiveries[customLiveryCount] = file:match('livery(%d+)')
            end
        end
    end
    
    -- Only show actual available liveries
    local actualLiveryCount = customLiveryCount > 0 and customLiveryCount or liveryCount
    
    SendNUIMessage({
        type = "updateLivery",
        current = currentLivery,
        total = actualLiveryCount,
        custom = customLiveries
    })
end

-- Helper function to scan directory
function scandir(directory)
    local i, t = 0, {}
    local pfile = io.popen('dir "' .. directory .. '" /b')
    if pfile then
        for filename in pfile:lines() do
            i = i + 1
            t[i] = filename
        end
        pfile:close()
    end
    return t
end

function GetModTypeIndex(modType)
    local modTypes = {
        engine = 11,
        brakes = 12,
        transmission = 13,
        suspension = 15,
        armor = 16,
        turbo = 18,
        xenon = 22,
        wheels = 23,
        windowTint = 46
    }
    return modTypes[modType]
end

function LoadVehicleList()
    -- Load standard vehicles
    vehicleList = {}
    for category, vehicles in pairs(Config.Vehicles) do
        vehicleList[category] = vehicles
    end

    -- Load addon vehicles
    local addonData = LoadResourceFile(GetCurrentResourceName(), 'addons.json')
    if addonData then
        local success, result = pcall(json.decode, addonData)
        if success and result.addon_vehicles then
            vehicleList.addons = {}
            for category, vehicles in pairs(result.addon_vehicles) do
                for model, name in pairs(vehicles) do
                    table.insert(vehicleList.addons, {
                        model = model,
                        name = name,
                        category = category
                    })
                end
            end
        end
    end
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    display = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = "setDisplay",
        display = false
    })
    cb('ok')
end)

RegisterNUICallback('getVehicleList', function(data, cb)
    local category = data.category or lastCategory
    lastCategory = category
    
    if category and vehicleList[category] then
        cb({
            success = true,
            vehicles = vehicleList[category]
        })
    else
        cb({
            success = false,
            error = "Category not found"
        })
    end
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local model = data.model
    
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        TriggerEvent('pd-notifications:notify', {
            text = "Invalid vehicle model",
            type = "error"
        })
        cb({success = false})
        return
    end

    -- Load model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    -- Get spawn position
    local playerPed = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, Config.DefaultSpawnDistance, 0.0)
    local heading = GetEntityHeading(playerPed)

    -- Delete old vehicle if exists
    if currentVehicle then
        DeleteVehicle(currentVehicle)
    end

    -- Spawn new vehicle
    currentVehicle = CreateVehicle(model, pos.x, pos.y, pos.z, heading, true, false)
    SetEntityAsMissionEntity(currentVehicle, true, true)
    SetVehicleOnGroundProperly(currentVehicle)
    SetModelAsNoLongerNeeded(model)

    -- Put player in vehicle
    TaskWarpPedIntoVehicle(playerPed, currentVehicle, -1)

    TriggerEvent('pd-notifications:notify', {
        text = "Vehicle spawned successfully",
        type = "success"
    })

    cb({success = true})
end)

-- Handle vehicle modifications
RegisterNUICallback('modifyVehicle', function(data, cb)
    if not currentVehicle then
        cb({success = false})
        return
    end

    local modType = data.modType
    local modIndex = data.modIndex

    if Config.ModificationTypes[modType] then
        SetVehicleMod(currentVehicle, GetModTypeIndex(modType), modIndex, false)
        UpdateVehicleStats()
        cb({success = true})
    else
        cb({success = false})
    end
end)

-- Save current vehicle
RegisterNUICallback('saveVehicle', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local vehicleData = {
        name = data.name,
        model = GetEntityModel(vehicle),
        mods = {},
        colors = {
            primary = {GetVehicleCustomPrimaryColour(vehicle)},
            secondary = {GetVehicleCustomSecondaryColour(vehicle)}
        },
        extras = {},
        livery = GetVehicleLivery(vehicle)
    }

    -- Get all mods
    for i = 0, 49 do
        local modIndex = GetVehicleMod(vehicle, i)
        if modIndex ~= -1 then
            vehicleData.mods[i] = modIndex
        end
    end

    -- Get extras
    for i = 0, 14 do
        if DoesExtraExist(vehicle, i) then
            vehicleData.extras[i] = IsVehicleExtraTurnedOn(vehicle, i)
        end
    end

    TriggerServerEvent('pd-carspawner:saveVehicle', vehicleData)
    cb({success = true})
end)

-- Vehicle Quick Actions
RegisterNUICallback('quickAction', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local success = true
    if data.action == "repair" then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
    elseif data.action == "clean" then
        SetVehicleDirtLevel(vehicle, 0.0)
    elseif data.action == "flip" then
        local coords = GetEntityCoords(vehicle)
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z + 2.0, false, false, false, true)
        SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle), 2, true)
    elseif data.action == "delete" then
        DeleteVehicle(vehicle)
        currentVehicle = nil
    end

    cb({success = success})
end)

-- Get Performance Stats
RegisterNUICallback('getPerformanceStats', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local stats = {
        speed = math.floor((GetVehicleEstimatedMaxSpeed(vehicle) * 3.6) / 3.0), -- Convert to percentage
        acceleration = math.floor(GetVehicleAcceleration(vehicle) * 100),
        braking = math.floor(GetVehicleMaxBraking(vehicle) * 100),
        handling = math.floor(GetVehicleMaxTraction(vehicle) * 10)
    }

    cb({success = true, stats = stats})
end)

-- Get Vehicle Properties
RegisterNUICallback('getVehicleProperties', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then 
        cb({})
        return
    end

    local properties = {
        model = GetEntityModel(vehicle),
        mods = {},
        colors = {
            primary = table.pack(GetVehicleColours(vehicle)),
            secondary = table.pack(GetVehicleExtraColours(vehicle))
        },
        extras = {},
        livery = GetVehicleLivery(vehicle),
        performance = {
            health = GetVehicleEngineHealth(vehicle),
            fuel = GetVehicleFuelLevel(vehicle),
            dirt = GetVehicleDirtLevel(vehicle)
        }
    }

    cb(properties)
end)

RegisterNUICallback('setNuiFocus', function(data, cb)
    SetNuiFocus(data.hasFocus, data.hasFocus)
    cb('ok')
end)

-- Handle vehicle liveries
RegisterNUICallback('loadLiveries', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    local liveryCount = GetVehicleLiveryCount(vehicle)
    local currentLivery = GetVehicleLivery(vehicle)
    
    local liveries = {}
    for i = 0, liveryCount - 1 do
        table.insert(liveries, {
            id = i,
            name = GetLiveryName(vehicle, i)
        })
    end

    cb({
        success = true,
        current = currentLivery,
        liveries = liveries
    })
end)

RegisterNUICallback('applyLivery', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    if data.liveryId then
        -- Reset to default if selecting stock
        if data.liveryId == -1 then
            SetVehicleLivery(vehicle, 0)
            SetVehicleModKit(vehicle, 0)
            ToggleVehicleMod(vehicle, 48, false)
        else
            SetVehicleLivery(vehicle, data.liveryId)
        end
        
        -- Update livery state immediately after applying
        UpdateLiveryState()
        cb({success = true})
    else
        cb({success = false})
    end
end)

-- Handle vehicle extras
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

RegisterNUICallback('toggleExtra', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return cb({success = false}) end

    if data.extraId then
        local isOn = IsVehicleExtraTurnedOn(vehicle, data.extraId)
        SetVehicleExtra(vehicle, data.extraId, isOn)
        cb({success = true, enabled = not isOn})
    else
        cb({success = false})
    end
end)

-- Helper function to get livery name
function GetLiveryName(vehicle, liveryId)
    return "Livery " .. (liveryId + 1)
end

-- Register ESC key to close menu
CreateThread(function()
    while true do
        Wait(0)
        if display and IsControlJustPressed(0, 200) then -- 200 is ESC key
            SetDisplay(false)
        end
    end
end)