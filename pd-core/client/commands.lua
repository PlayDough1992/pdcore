RegisterNetEvent('pd-core:fixVehicle')
AddEventHandler('pd-core:fixVehicle', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
        SetVehicleDirtLevel(vehicle, 0.0)
        
        TriggerEvent('pd-notifications:notify', {
            text = "Vehicle repaired",
            type = "success"
        })
    end
end)

RegisterNetEvent('pd-core:clearAreaPeds')
AddEventHandler('pd-core:clearAreaPeds', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local radius = 100.0
    local count = 0
    
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not IsPedAPlayer(ped) and #(GetEntityCoords(ped) - coords) < radius then
            DeleteEntity(ped)
            count = count + 1
        end
    end
    
    TriggerEvent('pd-notifications:notify', {
        text = string.format("Cleared %d peds", count),
        type = "success"
    })
end)

RegisterNetEvent('pd-core:clearAllVehicles')
AddEventHandler('pd-core:clearAllVehicles', function()
    local count = 0
    
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) and not IsPedInVehicle(PlayerPedId(), vehicle, true) then
            DeleteEntity(vehicle)
            count = count + 1
        end
    end
    
    TriggerEvent('pd-notifications:notify', {
        text = string.format("Cleared %d vehicles", count),
        type = "success"
    })
end)

RegisterNetEvent('pd-core:deleteVehicle')
AddEventHandler('pd-core:deleteVehicle', function(playerName)
    local playerPed = PlayerPedId()
    local vehicle = nil
    
    -- Check if player is in a vehicle
    if IsPedInAnyVehicle(playerPed, false) then
        vehicle = GetVehiclePedIsIn(playerPed, false)
    else
        -- Increased range from 2.0 to 5.0
        local pos = GetEntityCoords(playerPed)
        vehicle = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 71)
    end
    
    if DoesEntityExist(vehicle) then
        -- Check occupants through server event
        local occupants = {}
        local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
        
        for i = -1, maxPassengers do
            local ped = GetPedInVehicleSeat(vehicle, i)
            if ped ~= 0 then
                local playerId = NetworkGetPlayerIndexFromPed(ped)
                if playerId then
                    table.insert(occupants, GetPlayerServerId(playerId))
                end
            end
        end
        
        TriggerServerEvent('pd-core:checkVehicleOccupants', vehicle, occupants, playerName, GetPlayerServerId(PlayerId()))
    else
        TriggerEvent('pd-notifications:notify', {
            text = "No vehicle found nearby",
            type = "error",
            timeout = 3000
        })
    end
end)

-- Add handler for server response
RegisterNetEvent('pd-core:deleteVehicleResponse')
AddEventHandler('pd-core:deleteVehicleResponse', function(canDelete, vehicle)
    if canDelete then
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
            TriggerEvent('pd-notifications:notify', {
                text = "Successfully deleted vehicle",
                type = "success",
                timeout = 3000
            })
        end
    else
        TriggerEvent('pd-notifications:notify', {
            text = "Access denied: Cannot delete admin vehicles. All online admins have been notified of this attempt.",
            type = "error",
            timeout = 5000
        })
    end
end)

local boostActive = false
local originalHandling = {}
local boostedVehicle = 0  -- Store reference to boosted vehicle
local adminBlip = nil
local spotlights = {}
local lastSpeedCheck = 0
local checkInterval = 10000 -- Check every 10 seconds
local speedThreshold = 5 -- 5 Mbps threshold

RegisterNetEvent('pd-core:toggleBoost')
AddEventHandler('pd-core:toggleBoost', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        TriggerEvent('pd-notifications:notify', {
            text = "You must be in a vehicle to use boost",
            type = "error"
        })
        return
    end

    boostActive = not boostActive
    
    if boostActive then
        boostedVehicle = vehicle  -- Store reference to vehicle being boosted
        -- Store original handling for restoration
        originalHandling = {
            acceleration = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce"),
            maxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"),
            driveInertia = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia"),
            traction = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin"),
            tractionMax = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax"),
            lstractionloss = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult"),
            tractionloss = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult"),
            antiRollF = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarForce"),
            antiRollR = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarBiasFront"),
            rollCenter = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightFront"),
            rollCenterR = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightRear"),
            mass = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fMass"),
            downforce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDownforceModifier"),
            brakeforce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce")
        }
        
        -- Basic handling
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", 1.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", 1.5)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift", 1.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift", 1.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff", 0.5)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fMass", 200000.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDownforceModifier", 20.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", 5.0)

        -- Traction and stability
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", 3.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", 5.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", 0.000001)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", 0.000001)

        -- Stability settings
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarForce", 1.0)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightFront", 0.45)
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightRear", 0.45)

        -- Power and speed
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", 300.0)
        ModifyVehicleTopSpeed(vehicle, 3.0)
        SetVehicleCheatPowerIncrease(vehicle, 1.0)

        -- Create blip for all players
        TriggerServerEvent('pd-core:broadcastBoost', NetworkGetNetworkIdFromEntity(vehicle))
        
        -- Add emergency lighting
        SetVehicleFullbeam(vehicle, true)
        SetVehicleLights(vehicle, 2)
        SetVehicleHasMutedSirens(vehicle, false)
        SetVehicleSiren(vehicle, true)
        
        -- Emergency vehicle setup
        SetVehicleSiren(vehicle, true)
        SetVehicleHasMutedSirens(vehicle, false)
        SetVehicleIsConsideredByPlayer(vehicle, true)
        ForceVehicleHasLights(vehicle, true)
        SetVehicleLights(vehicle, 2)

        -- Replace the lighting system with this simpler glow effect
        CreateThread(function()
            while boostActive and DoesEntityExist(vehicle) do
                -- Enable neon lights for base glow
                for i = 0, 3 do
                    SetVehicleNeonLightEnabled(vehicle, i, true)
                end
                SetVehicleNeonLightsColour(vehicle, 145, 0, 255) -- Purple
                
                -- Get vehicle position
                local vehPos = GetEntityCoords(vehicle)
                
                -- Purple flame/particle effect
                RequestNamedPtfxAsset("core")
                while not HasNamedPtfxAssetLoaded("core") do
                    Wait(0)
                end
                
                UseParticleFxAssetNextCall("core")
                StartParticleFxLoopedAtCoord(
                    "ent_amb_elec_crackle",  -- Electric/plasma effect
                    vehPos.x, vehPos.y, vehPos.z + 0.3,
                    0.0, 0.0, 0.0,
                    1.0,    -- Scale
                    false, false, false
                )
                
                UseParticleFxAssetNextCall("core")
                StartParticleFxLoopedAtCoord(
                    "veh_light_red_trail",   -- Light trail effect
                    vehPos.x, vehPos.y, vehPos.z,
                    0.0, 0.0, 0.0,
                    2.0,    -- Scale
                    false, false, false
                )
                
                -- Add ambient glow
                DrawLightWithRange(
                    vehPos.x, vehPos.y, vehPos.z + 0.5,
                    145, 0, 255,           -- Purple color
                    7.0,                   -- Range
                    1.0                    -- Intensity
                )
                
                Wait(0)
            end
        end)

        -- Add extra lighting features
        SetVehicleLightMultiplier(vehicle, 2.0) -- Brighter lights

        -- Force field effect (replace the existing force field section)
        CreateThread(function()
            local radius = 20.0
            local force = 3000.0         -- Increased force significantly
            local heightOffset = 5.0

            while boostActive and DoesEntityExist(vehicle) do
                local vehPos = GetEntityCoords(vehicle)
                local vehSpeed = GetEntitySpeed(vehicle)
                local multiplier = math.max(1.0, vehSpeed / 10)
                
                -- Handle vehicles
                for _, nearVeh in ipairs(GetGamePool('CVehicle')) do
                    if DoesEntityExist(nearVeh) and nearVeh ~= vehicle then
                        local driver = GetPedInVehicleSeat(nearVeh, -1)
                        if driver == 0 or (not IsPedAPlayer(driver)) then
                            local entityPos = GetEntityCoords(nearVeh)
                            local distance = #(vehPos - entityPos)
                            
                            if distance < radius then
                                local direction = entityPos - vehPos
                                local magnitude = (1.0 - (distance / radius)) * force * multiplier
                                
                                -- More aggressive vehicle launch
                                SetEntityVelocity(nearVeh, 
                                    direction.x * (magnitude/50),  -- Increased force
                                    direction.y * (magnitude/50), 
                                    50.0                          -- More upward force
                                )
                                
                                -- Add invisible explosion force
                                AddExplosionForce(nearVeh, force, vehPos.x, vehPos.y, vehPos.z, radius, false, false)
                            end
                        end
                    end
                end
                
                -- Handle peds
                for _, ped in ipairs(GetGamePool('CPed')) do
                    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                        local entityPos = GetEntityCoords(ped)
                        local distance = #(vehPos - entityPos)
                        
                        if distance < radius then
                            SetPedRagdollOnCollision(ped, true)
                            SetPedToRagdoll(ped, 1000, 1000, 0, true, true, false)
                            
                            local direction = entityPos - vehPos
                            local magnitude = (1.0 - (distance / radius)) * force * 2.0 * multiplier
                            
                            -- More aggressive ped launch
                            SetEntityVelocity(ped,
                                direction.x * (magnitude/25),  -- Increased force
                                direction.y * (magnitude/25),
                                100.0                         -- Much more upward force
                            )
                        end
                    end
                end
                
                -- Visualization of force field
                DrawMarker(
                    28,                     -- Sphere type
                    vehPos.x, vehPos.y, vehPos.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    radius * 2.0, radius * 2.0, radius * 2.0,
                    145, 0, 255, 100,      -- More visible purple
                    false, false, 2,
                    nil, nil, false
                )
                
                Wait(0)
            end
        end)

        TriggerEvent('pd-notifications:notify', {
            text = "Admin boost activated",
            type = "success"
        })
    else
        RestoreVehicleHandling(vehicle)  -- Move restoration to function
        if adminBlip then
            RemoveBlip(adminBlip)
            adminBlip = nil
        end
        SetVehicleSiren(vehicle, false)
        SetVehicleLights(vehicle, 0)
        SetVehicleFullbeam(vehicle, false)
        for i = 0, 12 do
            SetVehicleExtra(vehicle, i, true)
        end
        SetVehicleNeonLightEnabled(vehicle, 0, false)
        SetVehicleNeonLightEnabled(vehicle, 1, false)
        SetVehicleNeonLightEnabled(vehicle, 2, false)
        SetVehicleNeonLightEnabled(vehicle, 3, false)
        TriggerEvent('pd-notifications:notify', {
            text = "Admin boost deactivated",
            type = "info"
        })
    end
end)

-- Function to restore vehicle handling
function RestoreVehicleHandling(vehicle)
    if vehicle == 0 or not originalHandling then return end
    
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", originalHandling.acceleration)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel", originalHandling.maxSpeed)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", originalHandling.driveInertia)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMin", originalHandling.traction)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionCurveMax", originalHandling.tractionMax)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarForce", originalHandling.antiRollF)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fAntiRollBarBiasFront", originalHandling.antiRollR)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightFront", originalHandling.rollCenter)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fRollCentreHeightRear", originalHandling.rollCenterR)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fMass", originalHandling.mass)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", originalHandling.lstractionloss)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fTractionLossMult", originalHandling.tractionloss)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDownforceModifier", originalHandling.downforce)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", originalHandling.brakeforce)
    ModifyVehicleTopSpeed(vehicle, 1.0)
    SetVehicleCheatPowerIncrease(vehicle, 1.0)
    
    if adminBlip then
        RemoveBlip(adminBlip)
        adminBlip = nil
    end
    
    -- Disable emergency lighting
    SetVehicleSiren(vehicle, false)
    SetVehicleLights(vehicle, 0)
    SetVehicleFullbeam(vehicle, false)
    for i = 0, 12 do
        SetVehicleExtra(vehicle, i, true)
    end
    SetVehicleNeonLightEnabled(vehicle, 0, false)
    SetVehicleNeonLightEnabled(vehicle, 1, false)
    SetVehicleNeonLightEnabled(vehicle, 2, false)
    SetVehicleNeonLightEnabled(vehicle, 3, false)

    -- Reset emergency vehicle status
    SetVehicleSiren(vehicle, false)
    SetVehicleIsConsideredByPlayer(vehicle, false)
    SetVehicleLightMultiplier(vehicle, 1.0)
    SetVehicleIndicatorLights(vehicle, 1, false)
    SetVehicleIndicatorLights(vehicle, 0, false)
    SetVehicleBrakeLights(vehicle, false)
    SetVehicleLights(vehicle, 0)
    SetVehicleFullbeam(vehicle, false)

    for i = 0, 12 do
        ToggleVehicleMod(vehicle, i, false)
        SetVehicleExtra(vehicle, i, true)
    end

    -- Remove any remaining particle effects
    RemoveParticleFxInRange(GetEntityCoords(vehicle), 10.0)
end

-- Create and update blip for boosted vehicle
RegisterNetEvent('pd-core:createBoostBlip')
AddEventHandler('pd-core:createBoostBlip', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(vehicle) then
        if adminBlip then
            RemoveBlip(adminBlip)
        end
        
        adminBlip = AddBlipForEntity(vehicle)
        SetBlipSprite(adminBlip, 596) -- Car blip
        SetBlipColour(adminBlip, 49) -- Purple
        SetBlipScale(adminBlip, 1.2)
        SetBlipAsShortRange(adminBlip, false) -- Show at any distance
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Admin Pursuit Vehicle")
        EndTextCommandSetBlipName(adminBlip)
        
        -- Update blip position
        CreateThread(function()
            while DoesBlipExist(adminBlip) do
                SetBlipCoords(adminBlip, GetEntityCoords(vehicle))
                Wait(100)
            end
        end)
    end
end)

-- Modified vehicle exit check
CreateThread(function()
    while true do
        Wait(1000)
        if boostActive then
            local ped = PlayerPedId()
            if not IsPedInAnyVehicle(ped, false) and boostedVehicle ~= 0 then
                RestoreVehicleHandling(boostedVehicle)  -- Restore the boosted vehicle
                boostActive = false
                boostedVehicle = 0  -- Reset vehicle reference
                TriggerEvent('pd-notifications:notify', {
                    text = "Admin boost reset - left vehicle",
                    type = "info"
                })
            end
        end
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Keep other cleanup code if needed
    end
end)

RegisterNetEvent('pd-core:spawnCar')
AddEventHandler('pd-core:spawnCar', function(model, isAdmin)
    -- Get hash and check if valid
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        TriggerEvent('pd-notifications:notify', {
            text = "Invalid vehicle model",
            type = "error",
            timeout = 3000
        })
        return
    end
    
    -- Load model
    RequestModel(hash)
    local timeoutCounter = 0
    while not HasModelLoaded(hash) do
        timeoutCounter = timeoutCounter + 1
        if timeoutCounter > 100 then
            TriggerEvent('pd-notifications:notify', {
                text = "Failed to load vehicle model",
                type = "error",
                timeout = 3000
            })
            return
        end
        Wait(10)
    end
    
    -- Get spawn position
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    -- Spawn vehicle
    local vehicle = CreateVehicle(hash, pos.x, pos.y, pos.z, heading, true, false)
    
    if DoesEntityExist(vehicle) then
        -- Set player into driver seat
        SetPedIntoVehicle(playerPed, vehicle, -1)
        
        -- Set as mission entity so it doesn't get deleted
        SetEntityAsMissionEntity(vehicle, true, true)
        
        -- Notify player of successful spawn
        TriggerEvent('pd-notifications:notify', {
            text = string.format("Spawned %s", model:upper()),
            type = "success",
            timeout = 3000
        })
        
        -- If not admin, notify admins and create temp blip
        if not isAdmin then
            TriggerServerEvent('pd-core:notifyCarSpawn', model, pos)
        end
    end
    
    -- Clean up
    SetModelAsNoLongerNeeded(hash)
end)

-- Create temporary blip for admins
RegisterNetEvent('pd-core:createTempCarBlip')
AddEventHandler('pd-core:createTempCarBlip', function(coords)
    -- Create blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 225)  -- Car sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 47)   -- Orange color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Spawned Vehicle")
    EndTextCommandSetBlipName(blip)
    
    -- Remove blip after 30 seconds
    CreateThread(function()
        Wait(30000)
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

-- Add upload speed monitoring thread
CreateThread(function()
    while true do
        Wait(checkInterval)
        
        -- Get current upload speed using GetNetworkUploadSpeed (returns bits/s)
        local uploadSpeed = GetNetworkUploadSpeed() / 1000000 -- Convert to Mbps
        
        -- Check if speed is below threshold
        if uploadSpeed < speedThreshold then
            -- Notify player
            TriggerEvent('pd-notifications:notify', {
                text = string.format("WARNING: Upload speed %.2f Mbps is below recommended 5 Mbps!", uploadSpeed),
                type = "error",
                timeout = 5000
            })
            
            -- Log to server console
            TriggerServerEvent('pd-core:logUploadSpeed', uploadSpeed)
        end
    end
end)