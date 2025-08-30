RegisterNetEvent('pd-core:openSetJobMenu')
AddEventHandler('pd-core:openSetJobMenu', function()
    TriggerServerEvent('pd-core:getPlayers')
end)

RegisterNetEvent('pd-core:receivePlayers')
AddEventHandler('pd-core:receivePlayers', function(players)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openSetJob',
        jobs = Jobs.Config.Jobs,
        players = players
    })
end)RegisterNUICallback('closeSetJob', function(data, cb)    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('setJob', function(data, cb)
    TriggerServerEvent('pd-core:setJob', data.playerId, data.job, data.grade)
    cb('ok')
end)
