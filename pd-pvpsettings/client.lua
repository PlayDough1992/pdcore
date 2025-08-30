local pvpEnabled = false
local isUIOpen = false

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('pd-pvpsettings:requestSettings')
end)

RegisterNetEvent('pd-pvpsettings:receiveSetting')
AddEventHandler('pd-pvpsettings:receiveSetting', function(enabled)
    pvpEnabled = enabled
    NetworkSetFriendlyFireOption(enabled)
    SetCanAttackFriendly(PlayerPedId(), enabled, enabled)
end)

RegisterNetEvent('pd-pvpsettings:playerSettingChanged')
AddEventHandler('pd-pvpsettings:playerSettingChanged', function(playerId, enabled)
    -- Update local tracking of other players' settings if needed
end)

RegisterCommand('pvpsettings', function()
    isUIOpen = not isUIOpen
    
    if isUIOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'showUI',
            pvpEnabled = pvpEnabled
        })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = 'hideUI'
        })
    end
end)

RegisterNUICallback('updatePvPSetting', function(data, cb)
    pvpEnabled = data.pvpEnabled
    NetworkSetFriendlyFireOption(pvpEnabled)
    SetCanAttackFriendly(PlayerPedId(), pvpEnabled, pvpEnabled)
    
    TriggerServerEvent('pd-pvpsettings:updateSetting', pvpEnabled)
    cb({})
end)

RegisterNUICallback('closeUI', function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb({})
end)