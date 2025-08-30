local camera = nil
local currentFOV = Config.DefaultSettings.fov.default
local isAiming = false

local function CreateFPSCamera()
    if camera then return end
    
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)
end

local function DestroyFPSCamera()
    if not camera then return end
    
    DestroyCam(camera, true)
    RenderScriptCams(false, true, 500, true, true)
    camera = nil
end

local function UpdateCamera()
    if not camera then return end

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)
    local headPos = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
    local camPos = vector3(
        headPos.x,
        headPos.y,
        headPos.z + Config.DefaultSettings.camera.height
    )
    
    -- Get camera rotation from gameplay camera
    local rotation = GetGameplayCamRot(2)
    
    -- Handle ADS
    if isAiming then
        local weaponObject = GetCurrentPedWeaponEntityIndex(ped)
        if DoesEntityExist(weaponObject) then
            local sightBone = GetEntityBoneIndexByName(weaponObject, "SKEL_Sight")
            if sightBone ~= -1 then
                local sightPos = GetWorldPositionOfEntityBone(weaponObject, sightBone)
                local dir = normalize(sightPos - camPos)
                rotation = vector3(
                    math.deg(math.asin(dir.z)),
                    0.0,
                    math.deg(math.atan2(-dir.x, dir.y))
                )
                currentFOV = lerp(currentFOV, Config.DefaultSettings.fov.ads, Config.DefaultSettings.camera.smoothing)
            end
        end
    else
        currentFOV = lerp(currentFOV, Config.DefaultSettings.fov.default, Config.DefaultSettings.camera.smoothing)
    end
    
    SetCamCoord(camera, camPos.x, camPos.y, camPos.z)
    SetCamRot(camera, rotation.x, rotation.y, rotation.z, 2)
    SetCamFov(camera, currentFOV)
end

-- Export functions
_G.FPSCamera = {
    create = CreateFPSCamera,
    destroy = DestroyFPSCamera,
    update = UpdateCamera,
    setAiming = function(state) isAiming = state end
}