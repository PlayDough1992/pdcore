local menuActive = false
local camera = nil
local isFirstPerson = false

function lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateFPSCamera()
    if camera then return end
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)
    SetCamFov(camera, FPSSettings.fov or 80.0)
end

local function DestroyFPSCamera()
    if not camera then return end
    SetCamActive(camera, false)
    DestroyCam(camera, true)
    RenderScriptCams(false, true, 500, true, true)
    camera = nil
end

local function ToggleFPS()
    isFirstPerson = not isFirstPerson
    
    if isFirstPerson then
        CreateFPSCamera()
        SetFocusEntity(PlayerPedId())
        SetFollowPedCamViewMode(4)
        DisableFirstPersonCamThisFrame()
        
        TriggerEvent('pd-core:notify', {
            type = 'info',
            message = 'First Person Mode Enabled'
        })
    else
        DestroyFPSCamera()
        SetFollowPedCamViewMode(1)
        ClearFocus()
        
        TriggerEvent('pd-core:notify', {
            type = 'info',
            message = 'First Person Mode Disabled'
        })
    end
end

-- Register command
RegisterCommand('fps', function()
    ToggleFPS()
end)

RegisterCommand('fpsSet', function()
    menuActive = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'toggleMenu',
        show = true,
        settings = FPSSettings
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    menuActive = false
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('updateSettings', function(data, cb)
    for k, v in pairs(data) do
        if type(FPSSettings[k]) == type(v) then
            FPSSettings[k] = v
        end
    end
    SaveSettings()
    cb({success = true})
end)

-- Main camera update loop
CreateThread(function()
    LoadSettings()
    while true do
        Wait(0)
        if isFirstPerson and camera then
            local ped = PlayerPedId()
            
            -- Get head position with forward offset built into the bone coords
            local headPos = GetPedBoneCoords(ped, 31086, 0.0, 0.15, 0.0)
            local gameplayCamRot = GetGameplayCamRot(2)
            
            -- Set camera position at head level
            SetCamCoord(camera, 
                headPos.x,
                headPos.y,
                headPos.z + 0.05
            )
            
            -- Update rotation and FOV
            SetCamRot(camera, gameplayCamRot.x, gameplayCamRot.y, gameplayCamRot.z, 2)
            
            -- Handle FOV transitions
            local targetFOV = IsPlayerFreeAiming(PlayerId()) and 60.0 or (FPSSettings.fov or 80.0)
            local currentFOV = GetCamFov(camera)
            SetCamFov(camera, lerp(currentFOV, targetFOV, 0.15))
            
            -- Force settings
            DisableFirstPersonCamThisFrame()
            SetFollowPedCamViewMode(4)
            SetCamProximityFadeDistance(camera, 0.01)
            SetFocusEntity(ped)
            
            -- Lock controls
            DisableControlAction(0, 0, true)   -- V key
            DisableControlAction(0, 44, true)  -- Q key
        end
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if camera then
            DestroyFPSCamera()
        end
    end
end)