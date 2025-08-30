local savedVehicles = {}
local dbFile = GetResourcePath(GetCurrentResourceName()) .. '/database/vehicles.json'

-- Ensure database directory exists
CreateThread(function()
    local dbPath = GetResourcePath(GetCurrentResourceName()) .. '/database'
    if not LoadResourceFile(GetCurrentResourceName(), '/database/vehicles.json') then
        if not os.rename(dbPath, dbPath) then
            os.execute('mkdir "' .. dbPath .. '"')
        end
        SaveResourceFile(GetCurrentResourceName(), 'database/vehicles.json', json.encode({}), -1)
    end
end)

-- Load database
local function LoadDatabase()
    local fileContent = LoadResourceFile(GetCurrentResourceName(), 'database/vehicles.json')
    if fileContent then
        savedVehicles = json.decode(fileContent) or {}
    else
        savedVehicles = {}
        SaveDatabase()
    end
end

-- Save database
local function SaveDatabase()
    SaveResourceFile(GetCurrentResourceName(), 'database/vehicles.json', json.encode(savedVehicles), -1)
end

-- Save vehicle configuration
local function SaveVehicle(identifier, vehicleData)
    if not savedVehicles[identifier] then
        savedVehicles[identifier] = {}
    end
    
    -- Generate unique ID for vehicle
    local vehicleId = os.time() .. math.random(1000, 9999)
    vehicleData.id = vehicleId
    vehicleData.savedAt = os.time()
    
    -- Add to saved vehicles
    savedVehicles[identifier][vehicleId] = vehicleData
    
    -- Save to file
    SaveDatabase()
    return true
end

-- Get player's saved vehicles
local function GetPlayerVehicles(identifier)
    return savedVehicles[identifier] or {}
end

-- Register events
RegisterNetEvent('pd-carspawner:saveVehicle')
AddEventHandler('pd-carspawner:saveVehicle', function(vehicleData)
    local source = source
    local identifier = exports['pd-core']:GetIdentifier(source)
    
    if SaveVehicle(identifier, vehicleData) then
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "Vehicle configuration saved",
            type = "success"
        })
        
        -- Send updated vehicle list
        TriggerClientEvent('pd-carspawner:receiveSavedVehicles', source, GetPlayerVehicles(identifier))
    end
end)

RegisterNetEvent('pd-carspawner:loadSavedVehicles')
AddEventHandler('pd-carspawner:loadSavedVehicles', function()
    local source = source
    local identifier = exports['pd-core']:GetIdentifier(source)
    
    TriggerClientEvent('pd-carspawner:receiveSavedVehicles', source, GetPlayerVehicles(identifier))
end)

-- Initialize database on resource start
CreateThread(function()
    LoadDatabase()
    print('[pd-carspawner] JSON Database loaded successfully')
end)