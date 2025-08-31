-- Basic server-side event handlers
RegisterNetEvent('pd-clothing:server:openMenu')
AddEventHandler('pd-clothing:server:openMenu', function()
    local src = source
    TriggerClientEvent('pd-clothing:client:openMenu', src)
end)

-- Add any necessary server-side export functions here
exports('OpenClothingMenu', function(source)
    TriggerClientEvent('pd-clothing:client:openMenu', source)
end)
