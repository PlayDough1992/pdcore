local previewCam = nil
local currentRotation = 0.0

local function CreatePreviewCamera()
    if previewCam then return end
    
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    -- Create camera
    previewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local vehiclePos = GetEntityCoords(vehicle)
    local distance = Config.PreviewCameraDistance
    local height = Config.PreviewCameraHeight
    
    -- Set initial camera position
    SetCamCoord(previewCam, 
        vehiclePos.x - (distance * math.cos(currentRotation)),
        vehiclePos.y - (distance * math.sin(currentRotation)),
        vehiclePos.z + height
    )
    
    PointCamAtEntity(previewCam, vehicle, 0.0, 0.0, 0.0, true)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

RegisterNUICallback('startPreview', function(data, cb)
    CreatePreviewCamera()
    cb('ok')
end)

RegisterNUICallback('stopPreview', function(data, cb)
    if previewCam then
        SetCamActive(previewCam, false)
        DestroyCam(previewCam, true)
        RenderScriptCams(false, true, 1000, true, false)
        previewCam = nil
    end
    cb('ok')
end)

RegisterNUICallback('rotatePreview', function(data, cb)
    if not previewCam then 
        cb('error')
        return 
    end

    currentRotation = data.rotation
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    local vehiclePos = GetEntityCoords(vehicle)
    local distance = Config.PreviewCameraDistance
    
    SetCamCoord(previewCam,
        vehiclePos.x - (distance * math.cos(currentRotation)),
        vehiclePos.y - (distance * math.sin(currentRotation)),
        vehiclePos.z + Config.PreviewCameraHeight
    )
    
    PointCamAtEntity(previewCam, vehicle, 0.0, 0.0, 0.0, true)
    cb('ok')
end)