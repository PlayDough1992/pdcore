local addonVehicles = {}

-- Load addon vehicles from json
local function LoadAddonVehicles()
    local addonData = LoadResourceFile(GetCurrentResourceName(), 'addons.json')
    if addonData then
        local success, result = pcall(json.decode, addonData)
        if success then
            addonVehicles = result.addon_vehicles
        end
    end
end

-- Check if vehicle model exists
local function DoesVehicleModelExist(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end
    return IsModelInCdimage(model)
end

-- Register NUI callback for addon vehicles
RegisterNUICallback('getAddonVehicles', function(data, cb)
    local validAddons = {}
    
    -- Validate each addon vehicle exists
    for category, vehicles in pairs(addonVehicles) do
        validAddons[category] = {}
        for model, name in pairs(vehicles) do
            if DoesVehicleModelExist(model) then
                validAddons[category][model] = name
            end
        end
    end
    
    cb({
        success = true,
        addons = validAddons
    })
end)

-- Initialize addon vehicles on resource start
CreateThread(function()
    LoadAddonVehicles()
end)

-- Export for other resources to add vehicles
exports('AddAddonVehicle', function(category, model, name)
    if not addonVehicles[category] then
        addonVehicles[category] = {}
    end
    
    if DoesVehicleModelExist(model) then
        addonVehicles[category][model] = name
        return true
    end
    return false
end)