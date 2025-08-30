local function CalculateVehicleStats(vehicle)
    if not vehicle then return nil end

    -- Base stats
    local stats = {
        speed = GetVehicleEstimatedMaxSpeed(vehicle) * 3.6, -- Convert to km/h
        acceleration = GetVehicleAcceleration(vehicle) * 100,
        braking = GetVehicleMaxBraking(vehicle) * 100,
        handling = GetVehicleMaxTraction(vehicle) * 50
    }

    -- Apply mod multipliers
    local mods = {
        [11] = { stat = "speed", multiplier = 0.05 }, -- Engine
        [12] = { stat = "braking", multiplier = 0.05 }, -- Brakes
        [13] = { stat = "acceleration", multiplier = 0.05 }, -- Transmission
        [15] = { stat = "handling", multiplier = 0.05 }, -- Suspension
    }

    for modType, info in pairs(mods) do
        local modIndex = GetVehicleMod(vehicle, modType)
        stats[info.stat] = stats[info.stat] * (1 + (modIndex * info.multiplier))
    end

    -- Normalize stats to 0-100 range
    local maxStats = { speed = 400, acceleration = 1.0, braking = 1.0, handling = 1.0 }
    for stat, value in pairs(stats) do
        stats[stat] = math.min((value / maxStats[stat]) * 100, 100)
    end

    return stats
end

RegisterNUICallback('getVehicleStats', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then 
        cb({})
        return
    end

    cb(CalculateVehicleStats(vehicle))
end)