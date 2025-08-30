
-- PlayDough Core Framework System
local Config = {
    BlacklistedScenarios = {
        types = {
            "WORLD_VEHICLE_POLICE_BIKE",
            "WORLD_VEHICLE_POLICE_CAR",
            "WORLD_VEHICLE_POLICE_NEXT_TO_CAR"
        },
        groups = {
            "Police",
            "Ambulance",
            "Fire"
        }
    },
    Disable = {
        ambience = true,
        driveby = true,
        idleCamera = true,
        pistolWhipping = true
    },
    AIResponse = {
        dispatchServices = {
            [1] = false,
            [2] = false,
            [3] = false
        },
        wantedLevels = false
    }
}

-- Core functionality from QBCore
CreateThread(function()
    while true do
        for _, sctyp in next, Config.BlacklistedScenarios.types do
            SetScenarioTypeEnabled(sctyp, false)
        end
        for _, scgrp in next, Config.BlacklistedScenarios.groups do
            SetScenarioGroupEnabled(scgrp, false)
        end
        Wait(10000)
    end
end)

CreateThread(function()
    SetAudioFlag('PoliceScannerDisabled', true)
    SetGarbageTrucks(false)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    DistantCopCarSirens(false)

    -- Remove vehicles from key areas
    RemoveVehiclesFromGeneratorsInArea(441.8465 - 500.0, -987.99 - 500.0, 30.68 - 500.0, 441.8465 + 500.0, -987.99 + 500.0, 30.68 + 500.0)     -- police station
    RemoveVehiclesFromGeneratorsInArea(316.79 - 300.0, -592.36 - 300.0, 43.28 - 300.0, 316.79 + 300.0, -592.36 + 300.0, 43.28 + 300.0)         -- pillbox
end)

CreateThread(function()
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end
    SetMaxWantedLevel(0)
end)
