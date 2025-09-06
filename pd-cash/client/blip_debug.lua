-- Add debug command for testing blips
RegisterCommand('testblip', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Create a test blip at player's location
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 431) -- Dollar sign
    SetBlipColour(blip, 2) -- Green
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, false)
    SetBlipPriority(blip, 10)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Test Blip")
    EndTextCommandSetBlipName(blip)
    
    -- Notify player
    TriggerEvent('pd-notifications:notify', {
        text = 'Created test blip at your position',
        type = 'success'
    })
    
    -- Automatically remove after 30 seconds
    Citizen.CreateThread(function()
        Citizen.Wait(30000)
        RemoveBlip(blip)
    end)
end, false)

-- Add command to test different blip types
RegisterCommand('testblips', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local blips = {}
    
    -- Test different blip sprites
    local blipTypes = {
        {sprite = 108, name = "Money Pickup"}, -- Money pickup
        {sprite = 431, name = "Dollar Sign"}, -- Dollar sign
        {sprite = 500, name = "Money Bag"}, -- Money bag
        {sprite = 408, name = "Money Bag 2"}, -- Another money bag
        {sprite = 586, name = "Cash Register"}, -- Cash register
        {sprite = 680, name = "Money"}, -- Stack of money
    }
    
    -- Create each blip type in a circle around player
    local radius = 10.0
    local angle = 0
    
    for i, blipData in ipairs(blipTypes) do
        -- Calculate position in a circle around player
        angle = (i-1) * (360 / #blipTypes)
        local x = coords.x + radius * math.cos(math.rad(angle))
        local y = coords.y + radius * math.sin(math.rad(angle))
        
        -- Create blip
        local blip = AddBlipForCoord(x, y, coords.z)
        SetBlipSprite(blip, blipData.sprite)
        SetBlipColour(blip, i % 8) -- Different colors
        SetBlipScale(blip, 0.9)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.name)
        EndTextCommandSetBlipName(blip)
        
        -- Store for cleanup
        table.insert(blips, blip)
        
        -- Notify
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {'[BLIP TEST]', 'Created ' .. blipData.name .. ' (Sprite: ' .. blipData.sprite .. ')'}
        })
    end
    
    -- Automatically remove after 60 seconds
    Citizen.CreateThread(function()
        Citizen.Wait(60000)
        for _, blip in ipairs(blips) do
            RemoveBlip(blip)
        end
        TriggerEvent('pd-notifications:notify', {
            text = 'Removed test blips',
            type = 'info'
        })
    end)
end, false)
