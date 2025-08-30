local display = false

RegisterCommand('vmenu', function()
    SetDisplay(not display)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = bool and "show" or "hide"
    })
end

RegisterNUICallback('player', function(data, cb)
    -- Add vMenu player options here
    cb('ok')
end)

RegisterNUICallback('vehicle', function(data, cb)
    -- Add vMenu vehicle options here
    cb('ok')
end)

RegisterNUICallback('weapon', function(data, cb)
    -- Add vMenu weapon options here
    cb('ok')
end)

RegisterNUICallback('world', function(data, cb)
    -- Add vMenu world options here
    cb('ok')
end)