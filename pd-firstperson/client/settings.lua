local Settings = table.copy(Config.DefaultSettings)

local function SaveSettings()
    SetResourceKvp('pd_fps_settings', json.encode(Settings))
    TriggerServerEvent('pd-firstperson:syncSettings', Settings)
end

local function LoadSettings()
    local saved = GetResourceKvpString('pd_fps_settings')
    if saved then
        local decoded = json.decode(saved)
        for k, v in pairs(decoded) do
            Settings[k] = v
        end
    end
end

RegisterNUICallback('updateSettings', function(data, cb)
    for k, v in pairs(data) do
        if type(Settings[k]) == type(v) then
            Settings[k] = v
        end
    end
    SaveSettings()
    cb({success = true})
end)

-- Export settings
_G.FPSSettings = Settings