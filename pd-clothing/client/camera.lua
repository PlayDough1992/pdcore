local camera = nil
local isCamActive = false
local currentRotation = 180.0
local camDistance = 2.5  -- Fixed camera distance

-- Constants
local ROTATION_SPEED = 0.3  -- Degrees per frame

-- Local camera update function
local function UpdateCameraPosition()
    if not camera or not isCamActive then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Calculate camera position based on rotation and distance
    local angle = math.rad(currentRotation)
    local camX = coords.x + (camDistance * math.cos(angle))
    local camY = coords.y + (camDistance * math.sin(angle))
    local camZ = coords.z + (Config.Camera.height or 0.0)
    
    SetCamCoord(camera, camX, camY, camZ)
    -- Point camera straight ahead at same height instead of at player
    PointCamAtCoord(camera, coords.x, coords.y, camZ)
    SetCamFov(camera, 45.0)
end

-- Local camera update handler
local function UpdateCamera()
    if not isCamActive then return end
    
    -- Calculate smooth rotation
    currentRotation = (currentRotation + ROTATION_SPEED) % 360
    
    -- Update camera position
    UpdateCameraPosition()
    
    -- Disable controls while camera is active
    for i = 30, 36 do
        DisableControlAction(0, i, true)
    end
    -- Disable attack controls
    DisableControlAction(0, 24, true)      -- Attack
    DisableControlAction(0, 25, true)      -- Aim
    DisableControlAction(0, 140, true)     -- Melee Attack Light
    DisableControlAction(0, 141, true)     -- Melee Attack Heavy
    DisableControlAction(0, 142, true)     -- Melee Attack Alternate
    DisableControlAction(0, 257, true)     -- Attack 2
    DisableControlAction(0, 263, true)     -- Melee Attack 1
    DisableControlAction(0, 264, true)     -- Melee Attack 2
end

-- Global function implementations
function InitializeCamera()
    if camera then
        DestroyClothingCamera()
    end
    
    -- Set initial values
    currentRotation = 180.0
    isCamActive = true
    
    -- Create and setup camera
    camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 1000, true, true)
    
    -- Initial setup
    SetFollowPedCamViewMode(4)
    DisableFirstPersonCamThisFrame()
    
    -- Set initial position
    UpdateCameraPosition()
    
    -- Start camera update thread
    Citizen.CreateThread(function()
        while camera ~= nil and isCamActive do
            UpdateCamera()
            Citizen.Wait(0)
        end
    end)
end

function DestroyClothingCamera()
    isCamActive = false
    if camera then
        SetCamActive(camera, false)
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(camera, true)
        camera = nil
        -- Set to third person view
        SetFollowPedCamViewMode(2)
    end
end

function SetCameraHeight(height)
    currentHeight = (height / 100) * (MAX_HEIGHT - MIN_HEIGHT) + MIN_HEIGHT
    UpdateCameraPosition()
end

function SetCameraRotation(rotation)
    currentRotation = rotation
    UpdateCameraPosition()
end

function SetCameraZoom(zoom)
    camDistance = (zoom / 100) * (MAX_DISTANCE - MIN_DISTANCE) + MIN_DISTANCE
    UpdateCameraPosition()
end

-- Print debug message when module loads
DebugPrint('Camera module loaded - Control codes: Up=' .. CONTROLS.UP .. 
    ', Down=' .. CONTROLS.DOWN .. 
    ', Left=' .. CONTROLS.LEFT .. 
    ', Right=' .. CONTROLS.RIGHT)
