-- Get current appearance data
local function GetCurrentAppearance()
    local ped = PlayerPedId()
    local appearance = {
        model = GetEntityModel(ped),
        clothes = {},
        props = {}
    }

    -- Get clothing components
    for i = 0, 11 do
        appearance.clothes[tostring(i)] = {  -- Change to string key
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i)
        }
    end

    -- Get prop components
    for i = 0, 7 do
        appearance.props[tostring(i)] = {    -- Change to string key
            prop = GetPedPropIndex(ped, i),
            texture = GetPedPropTextureIndex(ped, i)
        }
    end

    return appearance
end

-- Save request from server
RegisterNetEvent('pd-saver:requestSave')
AddEventHandler('pd-saver:requestSave', function()
    local appearance = GetCurrentAppearance()
    TriggerServerEvent('pd-saver:saveAppearance', appearance)
end)

-- Add delay to spawn request
RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
    Wait(2000) -- Wait 2 seconds after spawn
    print("[pd-saver] Requesting appearance after spawn")
    TriggerServerEvent('pd-saver:requestAppearance')
end)

-- Apply saved appearance
RegisterNetEvent('pd-saver:loadAppearance')
AddEventHandler('pd-saver:loadAppearance', function(appearance)
    if not appearance then 
        print("[pd-saver] No appearance data received")
        return 
    end
    
    local ped = PlayerPedId()
    print("[pd-saver] Loading appearance data...")
    print("[pd-saver] Current model: " .. GetEntityModel(ped))
    print("[pd-saver] Target model: " .. appearance.model)
    
    -- Set model if different
    if appearance.model ~= GetEntityModel(ped) then
        RequestModel(appearance.model)
        while not HasModelLoaded(appearance.model) do
            Wait(0)
        end
        SetPlayerModel(PlayerId(), appearance.model)
        SetModelAsNoLongerNeeded(appearance.model)
        Wait(1000)
        ped = PlayerPedId()
    end
    
    -- Ensure ped is valid
    while not DoesEntityExist(ped) do
        Wait(100)
        ped = PlayerPedId()
    end
    
    -- Clear all clothing first
    for i = 0, 11 do
        SetPedComponentVariation(ped, i, 0, 0, 0)
    end
    
    -- Clear all props
    for i = 0, 7 do
        ClearPedProp(ped, i)
    end
    
    Wait(500) -- Wait for clearing to take effect
    
    -- Apply clothing in specific order with retries
    local componentOrder = {3, 4, 8, 11, 6, 1, 9, 7, 5, 10, 2, 0}
    for _, i in ipairs(componentOrder) do
        local key = tostring(i)
        if appearance.clothes[key] then
            local data = appearance.clothes[key]
            local drawable = tonumber(data.drawable)
            local texture = tonumber(data.texture)
            
            -- Retry up to 3 times if component doesn't stick
            for retry = 1, 3 do
                SetPedComponentVariation(ped, i, drawable, texture, 0)
                Wait(100)
                
                -- Verify the component was set correctly
                local currentDrawable = GetPedDrawableVariation(ped, i)
                local currentTexture = GetPedTextureVariation(ped, i)
                
                if currentDrawable == drawable and currentTexture == texture then
                    print(string.format("[pd-saver] Component %d set successfully", i))
                    break
                elseif retry == 3 then
                    print(string.format("[pd-saver] Failed to set component %d after 3 attempts", i))
                end
            end
        end
    end
    
    Wait(200)
    
    -- Apply props with verification
    local propOrder = {0, 1, 2, 6, 7}
    for _, i in ipairs(propOrder) do
        if appearance.props[tostring(i)] then
            local data = appearance.props[tostring(i)]
            if data.prop == -1 then
                ClearPedProp(ped, i)
            else
                SetPedPropIndex(ped, i, tonumber(data.prop), tonumber(data.texture), true)
                Wait(50)
                
                -- Verify prop was set
                local currentProp = GetPedPropIndex(ped, i)
                if currentProp ~= tonumber(data.prop) then
                    print(string.format("[pd-saver] Failed to set prop %d", i))
                end
            end
        end
    end
    
    -- Final locks to prevent changes
    SetEntityVisible(ped, true)
    NetworkSetEntityInvisibleToNetwork(ped, false)
    SetPedCanRagdoll(ped, true)
    
    print("[pd-saver] Appearance loading complete with verification")
end)

RegisterNetEvent('pd-saver:getAppearanceForDisconnect')
AddEventHandler('pd-saver:getAppearanceForDisconnect', function()
    local appearance = GetCurrentAppearance()
    TriggerServerEvent('pd-saver:playerDropped', appearance)
end)