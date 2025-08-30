local settings = {}

local function LoadSettings()
    local file = LoadResourceFile(GetCurrentResourceName(), "settings.json")
    if file then
        settings = json.decode(file) or {}
    end
end

local function SaveSettings()
    SaveResourceFile(GetCurrentResourceName(), "settings.json", json.encode(settings), -1)
end

LoadSettings()

RegisterNetEvent('pd-pvpsettings:updateSetting')
AddEventHandler('pd-pvpsettings:updateSetting', function(pvpEnabled)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    settings[identifier] = pvpEnabled
    SaveSettings()
    
    TriggerClientEvent('pd-pvpsettings:playerSettingChanged', -1, source, pvpEnabled)
end)

RegisterNetEvent('pd-pvpsettings:requestSettings')
AddEventHandler('pd-pvpsettings:requestSettings', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    local pvpEnabled = settings[identifier]
    if pvpEnabled == nil then
        pvpEnabled = false
        settings[identifier] = pvpEnabled
        SaveSettings()
    end
    
    TriggerClientEvent('pd-pvpsettings:receiveSetting', source, pvpEnabled)
end)