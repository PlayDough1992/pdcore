RegisterCommand('setspawn', function(source, args)
    if exports['pd-core']:IsPlayerAdmin(source) then
        TriggerClientEvent('pd-locations:openNameInput', source)
    else
        TriggerClientEvent('pd-notifications:notify', source, {
            text = 'You do not have access to (setspawn) as you do not possess admin privileges',
            type = 'error'
        })
    end
end)

RegisterNetEvent('pd-locations:saveNewLocation')
AddEventHandler('pd-locations:saveNewLocation', function(data)
    local source = source
    if not exports['pd-core']:IsPlayerAdmin(source) then return end
    
    -- Read current config file
    local configPath = GetResourcePath(GetCurrentResourceName()) .. '/config.lua'
    local file = io.open(configPath, "r")
    local content = file:read("*all")
    file:close()
    
    -- Create new location entry
    local newLocation = string.format([[
    ['%s'] = {
        label = "%s",
        description = "Custom spawn location",
        coords = vector3(%f, %f, %f),
        heading = %f
    },]], 
    string.lower(data.name:gsub("%s+", "")), -- key
    data.name, -- label
    data.coords.x, data.coords.y, data.coords.z,
    data.heading)
    
    -- Find the position to insert the new location
    local insertPos = content:find("Config.Locations%s*=%s*{")
    if insertPos then
        insertPos = content:find("{", insertPos) + 1
        content = content:sub(1, insertPos) .. "\n    " .. newLocation .. content:sub(insertPos + 1)
    end
    
    -- Write back to file
    file = io.open(configPath, "w")
    file:write(content)
    file:close()

    -- Load the updated locations
    local newConfig = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
    load(newConfig)()
    
    -- Broadcast new locations to all clients
    TriggerClientEvent('pd-locations:updateLocations', -1, Config.Locations)
    
    TriggerClientEvent('pd-notifications:notify', source, {
        text = "New spawn location saved: " .. data.name,
        type = "success"
    })
end)

-- Add this function to load locations from config
function LoadLocations()
    -- Force reload the config file
    package.loaded['config'] = nil
    Config = {}
    require('config')
    return Config.Locations
end