local function SaveVehicleToDatabase(identifier, vehicleData)
    MySQL.Async.execute('INSERT INTO pd_saved_vehicles (owner, name, data) VALUES (?, ?, ?)',
        {identifier, vehicleData.name, json.encode(vehicleData)},
        function(rowsChanged)
            if rowsChanged > 0 then
                print(string.format('Vehicle saved for %s: %s', identifier, vehicleData.name))
            end
        end
    )
end

RegisterNetEvent('pd-carspawner:saveVehicle')
AddEventHandler('pd-carspawner:saveVehicle', function(vehicleData)
    local source = source
    local identifier = exports['pd-core']:GetIdentifier(source)
    
    if identifier then
        SaveVehicleToDatabase(identifier, vehicleData)
    end
end)

RegisterNetEvent('pd-carspawner:loadSavedVehicles')
AddEventHandler('pd-carspawner:loadSavedVehicles', function()
    local source = source
    local identifier = exports['pd-core']:GetIdentifier(source)
    
    if identifier then
        MySQL.Async.fetchAll('SELECT * FROM pd_saved_vehicles WHERE owner = ?', 
            {identifier},
            function(results)
                TriggerClientEvent('pd-carspawner:receiveSavedVehicles', source, results)
            end
        )
    end
end)