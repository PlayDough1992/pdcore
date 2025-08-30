local savedVehicles = {}

-- Database initialization (using pd-core's database)
CreateThread(function()
    exports['pd-core']:ExecuteQuery([[
        CREATE TABLE IF NOT EXISTS saved_vehicles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            owner VARCHAR(50) NOT NULL,
            name VARCHAR(50) NOT NULL,
            model VARCHAR(50) NOT NULL,
            mods JSON,
            colors JSON,
            extras JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
end)

-- Save vehicle configuration
RegisterNetEvent('pd-carspawner:saveVehicle')
AddEventHandler('pd-carspawner:saveVehicle', function(vehicleConfig)
    local source = source
    local identifier = exports['pd-core']:GetIdentifier(source)
    
    local query = [[
        INSERT INTO saved_vehicles (owner, name, model, mods, colors, extras)
        VALUES (?, ?, ?, ?, ?, ?)
    ]]
    
    exports['pd-core']:ExecuteQuery(query, {
        identifier,
        vehicleConfig.name,
        vehicleConfig.model,
        json.encode(vehicleConfig.mods),
        json.encode(vehicleConfig.colors),
        json.encode(vehicleConfig.extras)
    })
    
    -- Update client's saved vehicles list
    LoadSavedVehicles(source)
end)

-- Load saved vehicles for player
function LoadSavedVehicles(source)
    local identifier = exports['pd-core']:GetIdentifier(source)
    
    local query = [[
        SELECT * FROM saved_vehicles 
        WHERE owner = ? 
        ORDER BY created_at DESC
    ]]
    
    exports['pd-core']:ExecuteQuery(query, {identifier}, function(result)
        if result then
            TriggerClientEvent('pd-carspawner:receiveSavedVehicles', source, result)
        end
    end)
end