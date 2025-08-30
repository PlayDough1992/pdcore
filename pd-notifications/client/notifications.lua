local function SendNotification(source, message, type)
    TriggerClientEvent('pd-notifications:notify', source, {
        text = message,
        type = type
    })
end

RegisterNetEvent('pd-notifications:notify', function(data)
    SendNUIMessage({
        action = 'notification',
        text = data.text,
        type = data.type
    })
end)

exports('SendNotification', SendNotification)
