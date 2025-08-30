local camera = nil
local isCamActive = false
local lastCoords = nil
local currentView = 'default'

-- Initialize menu state
local function InitializeMenu()
    local ped = PlayerPedId()
    lastCoords = GetEntityCoords(ped)
    
    -- Create camera
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1000, true, true)
    isCamActive = true
    
    -- Set initial camera position
    SetCameraView('default')
    
    -- Freeze player
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, 180.0)
end

-- Camera position handler
local function SetCameraView(viewType)
    if not camera or not isCamActive then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local cameraConfig = Config.CameraZones[viewType] or Config.CameraZones.default
    
    -- Get bone position if specified
    local targetPos = coords
    if cameraConfig.bone ~= 0 then
        targetPos = GetPedBoneCoords(ped, cameraConfig.bone, 0.0, 0.0, 0.0)
    end
    
    -- Set camera position and point at ped
    local camPos = targetPos + cameraConfig.offset
    SetCamCoord(camera, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(camera, targetPos.x + cameraConfig.pointOffset.x, 
                            targetPos.y + cameraConfig.pointOffset.y, 
                            targetPos.z + cameraConfig.pointOffset.z)
    SetCamFov(camera, cameraConfig.fov)
    currentView = viewType
end

-- Event handlers
RegisterNetEvent('pd-appearancemenu:client:openMenu')
AddEventHandler('pd-appearancemenu:client:openMenu', function()
    InitializeMenu()
    SetNuiFocus(true, true)
    
    -- Send initial data to NUI
    SendNUIMessage({
        action = "show",
        components = Config.Components,
        props = Config.Props
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    -- Reset focus
    SetNuiFocus(false, false)
    -- Reset camera
    if camera then
        SetCamActive(camera, false)
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(camera, true)
        camera = nil
    end
    -- Unfreeze player
    FreezeEntityPosition(PlayerPedId(), false)
    cb('ok')
end)

RegisterNUICallback('updateView', function(data, cb)
    if data.view then
        SetCameraView(data.view)
    end
    cb('ok')
end)

RegisterNUICallback('updateComponent', function(data, cb)
    local ped = PlayerPedId()
    
    if data.component and data.drawable then
        SetPedComponentVariation(ped, data.component, data.drawable, data.texture or 0, 2)
    end
    
    cb('ok')
end)

RegisterNUICallback('updateProp', function(data, cb)
    local ped = PlayerPedId()
    
    if data.prop then
        if data.drawable == -1 then
            ClearPedProp(ped, data.prop)
        else
            SetPedPropIndex(ped, data.prop, data.drawable, data.texture or 0, true)
        end
    end
    
    cb('ok')
end)

local function OpenAppearanceMenu()
    SendNUIMessage({
        action = "show",
        components = {
            Face = {
                id = 0,
                name = "Face",
                min = 0,
                max = 45
            },
            -- Add other components here
        },
        props = {
            Hats = {
                id = 0,
                name = "Hat",
                min = -1,
                max = 151
            },
            -- Add other props here
        }
    })
    SetNuiFocus(true, true)
end

-- Register event that phone app will trigger
RegisterNetEvent('pd-appearancemenu:openMenu')
AddEventHandler('pd-appearancemenu:openMenu', function()
    OpenAppearanceMenu()
end)

RegisterNetEvent('pd-phone:client:openPAM')
AddEventHandler('pd-phone:client:openPAM', function()
    OpenAppearanceMenu()
end)

-- Debug command to test menu
RegisterCommand('testmenu', function()
    OpenAppearanceMenu()
end)