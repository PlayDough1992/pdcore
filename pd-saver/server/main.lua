local SaveInterval = 180000 -- 3 minutes in milliseconds

-- Helper function to get player's license number
local function GetPlayerLicenseNumber(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, "license:") then
            -- Print for debugging
            print("^2[pd-saver] Found license: " .. id .. "^7")
            local license = string.sub(id, 9)
            print("^2[pd-saver] Extracted license: " .. license .. "^7")
            return license
        end
    end
    print("^1[pd-saver] No license found for player^7")
    return nil
end

-- Load player's appearance from file
RegisterNetEvent('pd-saver:requestAppearance')
AddEventHandler('pd-saver:requestAppearance', function()
    local source = source
    local license = GetPlayerLicenseNumber(source)
    if not license then return end
    
    local path = ('playerlooks/%s.json'):format(license)
    local fileContent = LoadResourceFile(GetCurrentResourceName(), path)
    
    if fileContent then
        local appearance = json.decode(fileContent)
        TriggerClientEvent('pd-saver:loadAppearance', source, appearance)
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Appearance loaded",
            type = "success"
        })
    end
end)

-- Receive and save appearance data from client
RegisterNetEvent('pd-saver:saveAppearance')
AddEventHandler('pd-saver:saveAppearance', function(appearance)
    local source = source
    local license = GetPlayerLicenseNumber(source)
    if not license then return end
    
    local path = ('playerlooks/%s.json'):format(license)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(appearance), -1)
    TriggerClientEvent('pd-notifications:notify', source, {
        text = "Appearance saved",
        type = "success"
    })
end)

-- Save on player disconnect
RegisterNetEvent('pd-saver:playerDropped')
AddEventHandler('pd-saver:playerDropped', function(appearance)
    local source = source
    local license = GetPlayerLicenseNumber(source)
    if not license then return end
    
    local path = ('playerlooks/%s.json'):format(license)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(appearance), -1)
    TriggerClientEvent('pd-notifications:notify', source, {
        text = "Appearance saved before disconnect",
        type = "success"
    })
end)

-- Request saves from all players periodically
CreateThread(function()
    while true do
        Wait(SaveInterval)
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            TriggerClientEvent('pd-saver:requestSave', playerId)
        end
    end
end)

-- Save on player disconnect
AddEventHandler('playerDropped', function()
    TriggerClientEvent('pd-saver:getAppearanceForDisconnect', source)
end)