-- Cache for admin list
local adminCache = {}
local lastAdminCacheUpdate = 0
local ADMIN_CACHE_LIFETIME = 300 -- 5 minutes

-- Function to read and parse server.cfg for admin list
local function GetAdminList()
    local currentTime = os.time()
    -- Return cached results if they're still fresh
    if currentTime - lastAdminCacheUpdate < ADMIN_CACHE_LIFETIME then
        return adminCache
    end
    
    local admins = {}
    -- Get path to server.cfg (goes up from resource folder to server root)
    local configPath = GetResourcePath('pd-carspawner'):gsub('//', '/')
    configPath = configPath:sub(1, configPath:find('/resources/')) .. '/server.cfg'
    
    local file = io.open(configPath, 'r')
    if file then
        for line in file:lines() do
            -- Match lines like: add_principal identifier.XXX:YYYY group.admin
            local identifier = line:match('add_principal%s+([%w:]+)%s+group%.admin')
            if identifier then
                admins[identifier] = true
            end
        end
        file:close()
    else
        print('[PDCarSpawner] Warning: Could not open server.cfg')
    end
    
    adminCache = admins
    lastAdminCacheUpdate = currentTime
    return admins
end

-- Function to check if player is admin
local function IsPlayerAdmin(source)
    local admins = GetAdminList()
    print('[PDCarSpawner] Loaded admin list:', json.encode(admins))
    
    local identifiers = GetPlayerIdentifiers(source)
    print('[PDCarSpawner] Player identifiers:', json.encode(identifiers))
    
    for _, identifier in ipairs(identifiers) do
        print('[PDCarSpawner] Checking identifier:', identifier)
        if admins[identifier] then
            print('[PDCarSpawner] Found admin identifier match:', identifier)
            return true
        end
    end
    
    print('[PDCarSpawner] No admin identifiers found for player')
    return false
end

-- Function to check vehicle type authorization
local function IsAuthorizedForVehicle(source, vehicleType)
    if not vehicleType then return true end -- If no type specified, assume it's a civilian vehicle
    
    local identifiers = GetPlayerIdentifiers(source)
    print('[PDCarSpawner] Checking authorization for type:', vehicleType)
    print('[PDCarSpawner] Player identifiers:', json.encode(identifiers))
    
    local authKey = "authorized" .. vehicleType:gsub("^%l", string.upper) -- Convert 'police' to 'authorizedPolice'
    print('[PDCarSpawner] Looking for auth key:', authKey)
    
    if Config.JobAuthorization[authKey] then
        print('[PDCarSpawner] Allowed IDs for ' .. authKey .. ':', json.encode(Config.JobAuthorization[authKey]))
        for _, allowedId in ipairs(Config.JobAuthorization[authKey]) do
            for _, playerIdentifier in ipairs(identifiers) do
                if playerIdentifier == allowedId then
                    print('[PDCarSpawner] Found matching identifier:', playerIdentifier)
                    return true
                end
            end
        end
    end
    
    print('[PDCarSpawner] No authorization found for type:', vehicleType)
    return false
end

-- Event handler for menu request
RegisterNetEvent('pd-carspawner:server:requestMenu')
AddEventHandler('pd-carspawner:server:requestMenu', function()
    local source = source
    local isAdmin = IsPlayerAdmin(source)
    
    -- Process categories and include authorization info
    local filteredCategories = {}
    
    for _, category in ipairs(Config.Categories) do
        local categoryData = {
            name = category.name,
            label = category.label,
            order = category.order,
            vehicles = {}
        }
        
        -- Include all vehicles but mark authorization status
        for _, vehicle in ipairs(category.vehicles) do
            local isAuthorized = not vehicle.type or -- Civilian vehicle
                                isAdmin or -- Admin can access everything
                                IsAuthorizedForVehicle(source, vehicle.type) -- Has specific authorization
            
            -- Include vehicle with authorization status
            table.insert(categoryData.vehicles, {
                name = vehicle.name,
                model = vehicle.model,
                type = vehicle.type,
                authorized = isAuthorized
            })
        end
        
        -- Include category if it has any vehicles
        if #categoryData.vehicles > 0 then
            table.insert(filteredCategories, categoryData)
        end
    end
    
    -- Send filtered menu data to client
    TriggerClientEvent('pd-carspawner:client:receiveMenu', source, {
        categories = filteredCategories,
        isAdmin = isAdmin
    })
end)

-- Event handler for vehicle spawn request
RegisterNetEvent('pd-carspawner:server:requestVehicle')
AddEventHandler('pd-carspawner:server:requestVehicle', function(model)
    local source = source
    print('[PDCarSpawner] Vehicle spawn request received from ' .. source .. ' for model: ' .. model)
    
    local isAdmin = IsPlayerAdmin(source)
    print('[PDCarSpawner] Player admin status:', isAdmin)
    
    -- Find vehicle in config to get its type
    local vehicleType = nil
    for _, category in ipairs(Config.Categories) do
        for _, vehicle in ipairs(category.vehicles) do
            if vehicle.model == model then
                vehicleType = vehicle.type
                print('[PDCarSpawner] Found vehicle type:', vehicleType)
                break
            end
        end
        if vehicleType then break end
    end
    
    if not vehicleType then
        print('[PDCarSpawner] No vehicle type found - treating as civilian vehicle')
    end
    
    -- Check authorization
    local authorized = false
    if not vehicleType then
        print('[PDCarSpawner] Authorized - civilian vehicle')
        authorized = true
    elseif isAdmin then
        print('[PDCarSpawner] Authorized - player is admin')
        authorized = true
    else
        authorized = IsAuthorizedForVehicle(source, vehicleType)
        print('[PDCarSpawner] Authorization check result:', authorized)
    end
    
    if authorized then
        print('[PDCarSpawner] Spawning vehicle for player')
        TriggerClientEvent('pd-carspawner:client:spawnVehicle', source, model)
    else
        print('[PDCarSpawner] Denying vehicle spawn - not authorized')
        TriggerClientEvent('pd-carspawner:client:notification', source, 'You are not authorized to spawn this vehicle', 'error')
    end
end)
