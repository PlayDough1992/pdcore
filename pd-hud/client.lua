CreateThread(function()
    while true do
        Wait(100) -- Update more frequently
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        -- Health (normalize between 0-100)
        local health = GetEntityHealth(ped)
        local maxHealth = GetEntityMaxHealth(ped)
        local healthPercent = ((health - 100) / (maxHealth - 100)) * 100
        
        -- Stamina (already 0-100)
        local stamina = 100
        if IsPedRunning(ped) or IsPedSprinting(ped) then
            stamina = GetPlayerStamina(PlayerId())
        end
        
        -- Altitude
        local coords = GetEntityCoords(ped)
        local altitude = (coords.z + 100.0) / 16.00 -- Normalize to roughly 0-100
        
        -- Oxygen (improved underwater check and calculation)
        local oxygen = 100
        if IsPedSwimmingUnderWater(ped) then
            -- Get max underwater time (usually 15.0 seconds)
            local maxUnderwaterTime = 15.0
            -- Get remaining underwater time
            local remainingTime = GetPlayerUnderwaterTimeRemaining(PlayerId())
            -- Calculate oxygen percentage
            oxygen = (remainingTime / maxUnderwaterTime) * 100
            -- Ensure value stays between 0-100
            oxygen = math.max(0, math.min(100, oxygen))
        end
        
        -- Vehicle Health (comprehensive damage calculation)
        local vehicleHealth = 0
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            -- Get various health values
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local bodyHealth = GetVehicleBodyHealth(vehicle)
            local tankHealth = GetVehiclePetrolTankHealth(vehicle)
            
            -- Calculate wheel health
            local wheelHealth = 0
            for i = 0, 7 do -- Check all possible wheels
                if not IsVehicleTyreBurst(vehicle, i, false) then
                    wheelHealth = wheelHealth + 100
                end
            end
            wheelHealth = wheelHealth / 8 -- Average wheel health
            
            -- Normalize engine health from -4000->1000 to 0->100
            local normalizedEngineHealth = ((engineHealth + 4000) / 5000) * 100
            
            -- Normalize body health from 0->1000 to 0->100
            local normalizedBodyHealth = bodyHealth / 10
            
            -- Normalize tank health from -999->1000 to 0->100
            local normalizedTankHealth = ((tankHealth + 999) / 1999) * 100
            
            -- Calculate weighted average (engine health counts more towards total)
            vehicleHealth = (
                (normalizedEngineHealth * 0.4) +  -- Engine damage (40% weight)
                (normalizedBodyHealth * 0.3) +    -- Body damage (30% weight)
                (wheelHealth * 0.2) +             -- Wheel damage (20% weight)
                (normalizedTankHealth * 0.1)      -- Fuel tank damage (10% weight)
            )
            
            -- Clamp final value between 0 and 100
            vehicleHealth = math.max(0, math.min(100, vehicleHealth))
        end
        
        -- Send all status updates
        SendNUIMessage({
            type = 'status',
            health = healthPercent,
            stamina = stamina,
            altitude = altitude,
            oxygen = oxygen,
            vehicle = vehicleHealth
        })
    end
end)