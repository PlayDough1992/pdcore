local function ApplyVehicleMods(vehicle, mods)
    if not vehicle or not mods then return end
    
    -- Performance Mods
    for modType, modIndex in pairs(mods) do
        local modTypeIndex = GetModTypeIndex(modType)
        if modTypeIndex then
            SetVehicleMod(vehicle, modTypeIndex, modIndex, false)
        end
    end

    -- Handle special mods
    if mods.turbo then
        ToggleVehicleMod(vehicle, 18, true)
    end
    
    if mods.xenon then
        ToggleVehicleMod(vehicle, 22, true)
        if mods.xenonColor then
            SetVehicleXenonLightsColor(vehicle, mods.xenonColor)
        end
    end

    if mods.windowTint then
        SetVehicleWindowTint(vehicle, mods.windowTint)
    end

    -- Update stats after modifications
    UpdateVehicleStats()
end

RegisterNUICallback('getAvailableMods', function(data, cb)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then 
        cb({success = false})
        return
    end

    local availableMods = {}
    for modType, info in pairs(Config.ModificationTypes) do
        local modTypeIndex = GetModTypeIndex(modType)
        if modTypeIndex then
            availableMods[modType] = {
                name = info.name,
                current = GetVehicleMod(vehicle, modTypeIndex),
                max = GetNumVehicleMods(vehicle, modTypeIndex) - 1
            }
        end
    end

    cb({
        success = true,
        mods = availableMods
    })
end)