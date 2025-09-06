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
    TriggerServerEvent('pd-phonev2:getBankBalance')
    cb({})
end)

RegisterNetEvent('pd-phonev2:updateBalance')
AddEventHandler('pd-phonev2:updateBalance', function(balance)
    SendNUIMessage({
        action = 'updateBalance',
        balance = balance
    })
end)

RegisterNetEvent('pd-phonev2:youtube:receiveToken', function(token)
    SendNUIMessage({
        type = 'youtube-oauth-token',
        token = token
    })
end)

RegisterNUICallback('getPlayerId', function(data, cb)
    cb({ playerId = GetPlayerServerId(PlayerId()) })
end)

RegisterNUICallback('openExternalUrl', function(data, cb)
    local url = data.url
    if url then
        SetClipboard(url)
        TriggerEvent('chat:addMessage', { args = { '^2[Phone]', 'Copy and paste this link in your browser to sign in:', url } })
        cb({ success = true })
    else
        cb({ success = false, error = 'No URL provided' })
    end
end)
