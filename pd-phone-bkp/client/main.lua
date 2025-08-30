local phoneVisible = false

RegisterCommand('phone', function()
    phoneVisible = not phoneVisible
    SetNuiFocus(phoneVisible, phoneVisible)
    SendNUIMessage({
        action = 'togglePhone'
    })
end)

RegisterKeyMapping('phone', 'Toggle Phone', 'keyboard', 'F1')

RegisterNUICallback('toggleFocus', function(data, cb)
    phoneVisible = data.focus
    SetNuiFocus(phoneVisible, phoneVisible)
    cb({})
end)

RegisterNUICallback('getBankBalance', function(data, cb)
    TriggerServerEvent('pd-phone:getBankBalance')
    cb({})
end)

RegisterNetEvent('pd-phone:updateBalance')
AddEventHandler('pd-phone:updateBalance', function(balance)
    SendNUIMessage({
        action = 'updateBalance',
        balance = balance
    })
end)