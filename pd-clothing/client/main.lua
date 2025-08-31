local isMenuOpen = false
local originalAppearance = nil

-- Store original appearance when opening menu
local function StoreOriginalAppearance()
    local ped = PlayerPedId()
    originalAppearance = {
        components = {},
        props = {}
    }
    
    -- Store components
    for _, comp in ipairs(Config.Components) do
        originalAppearance.components[comp.id] = {
            drawable = GetPedDrawableVariation(ped, comp.id),
            texture = GetPedTextureVariation(ped, comp.id)
        }
    end
    
    -- Store props with proper handling for missing props
    for _, prop in ipairs(Config.Props) do
        local propIndex = GetPedPropIndex(ped, prop.id)
        if propIndex == -1 then
            originalAppearance.props[prop.id] = {
                drawable = -1,
                texture = 0
            }
        else
            originalAppearance.props[prop.id] = {
                drawable = propIndex,
                texture = GetPedPropTextureIndex(ped, prop.id)
            }
        end
    end
    
    -- Store props
    for _, prop in ipairs(Config.Props) do
        originalAppearance.props[prop.id] = {
            drawable = GetPedPropIndex(ped, prop.id),
            texture = GetPedPropTextureIndex(ped, prop.id)
        }
    end
end

-- Get current appearance
local function GetCurrentAppearance()
    local ped = PlayerPedId()
    local current = {
        components = {},
        props = {}
    }
    
    -- Get components
    for _, comp in ipairs(Config.Components) do
        current.components[comp.id] = {
            drawable = GetPedDrawableVariation(ped, comp.id),
            texture = GetPedTextureVariation(ped, comp.id)
        }
    end
    
    -- Get props
    for _, prop in ipairs(Config.Props) do
        current.props[prop.id] = {
            drawable = GetPedPropIndex(ped, prop.id),
            texture = GetPedPropTextureIndex(ped, prop.id)
        }
    end
    
    return current
end

-- Check if model is MP
local function IsModelMP(ped)
    local model = GetEntityModel(ped)
    return model == GetHashKey('mp_m_freemode_01') or model == GetHashKey('mp_f_freemode_01')
end

-- Change player model
local function ChangePlayerModel(model)
    local modelHash = GetHashKey(model)
    
    if not IsModelInCdimage(modelHash) then return end
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    SetPlayerModel(PlayerId(), modelHash)
    SetModelAsNoLongerNeeded(modelHash)
    
    ped = PlayerPedId()
    SetPedHeadBlendData(ped, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0.0, true)
    SetEntityCoords(ped, pos.x, pos.y, pos.z)
    SetEntityHeading(ped, heading)
end

-- Initialize menu
local function OpenClothingMenu()
    if isMenuOpen then return end
    
    -- Check if player model is MP
    if not IsModelMP(PlayerPedId()) then
        ChangePlayerModel('mp_m_freemode_01')
    end
    
    -- Small delay to ensure everything is ready
    Citizen.Wait(100)
    
    -- Store original appearance for reset functionality
    StoreOriginalAppearance()
    
    -- Initialize camera
    InitializeCamera()
    
    -- Freeze ped
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, 180.0)
    
    -- Show UI
    isMenuOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "show",
        position = Config.MenuPosition,
        components = Config.Components,
        props = Config.Props,
        currentData = GetCurrentAppearance()
    })
end

-- Close menu
local function CloseClothingMenu()
    if not isMenuOpen then return end
    
    -- Reset camera
    DestroyClothingCamera()
    
    -- Unfreeze ped
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    
    -- Hide UI
    isMenuOpen = false
    SetNuiFocus(false, false)
end

-- NUI Callbacks
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
        -- Handle prop removal
        if data.drawable == -1 then
            ClearPedProp(ped, data.prop)
        else
            -- Ensure we have valid texture
            local texture = data.texture or 0
            if texture < 0 then texture = 0 end
            
            -- Try to set the prop
            if not SetPedPropIndex(ped, data.prop, data.drawable, texture, true) then
                -- If failed, try clearing and setting again
                ClearPedProp(ped, data.prop)
                SetPedPropIndex(ped, data.prop, data.drawable, texture, true)
            end
        end
    end
    
    cb('ok')
end)

RegisterNUICallback('updateCameraView', function(data, cb)
    if data.view then
        local viewConfig = Config.CameraViews[data.view]
        if viewConfig then
            SetComponentView(viewConfig)
        end
    end
    cb('ok')
end)

RegisterNUICallback('resetChanges', function(data, cb)
    local ped = PlayerPedId()
    
    if originalAppearance then
        -- Reset components
        for id, data in pairs(originalAppearance.components) do
            SetPedComponentVariation(ped, id, data.drawable, data.texture, 2)
        end
        
        -- Reset props
        for id, data in pairs(originalAppearance.props) do
            if data.drawable == -1 then
                ClearPedProp(ped, id)
            else
                SetPedPropIndex(ped, id, data.drawable, data.texture, true)
            end
        end
    end
    
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    CloseClothingMenu()
    cb('ok')
end)

RegisterNUICallback('selectModel', function(data, cb)
    if data.model then
        ChangePlayerModel(data.model)
    end
    cb('ok')
end)

-- Commands and KeyMapping
RegisterCommand('clothing', function()
    OpenClothingMenu()
end)

RegisterKeyMapping('clothing', 'Open Clothing Menu', 'keyboard', 'k')

-- Event handlers
RegisterNetEvent('pd-clothing:client:openMenu')
AddEventHandler('pd-clothing:client:openMenu', function()
    OpenClothingMenu()
end)

-- Close menu on resource stop to clean up
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if isMenuOpen then
        CloseClothingMenu()
    end
end)
