local function GetCurrentResourceName()
    return GetCurrentResourceName()
end

local isLoading = true
local startTime = GetGameTimer()

local function InitializeLoadingScreen()
    local resourceList = {}
    local startedResources = 0
    local totalResources = 0

    -- Get initial resource list and count
    for i = 0, GetNumResources() - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if resourceName then
            resourceList[resourceName] = false
            totalResources = totalResources + 1
        end
    end

    -- Send initial setup to NUI
    SendNUIMessage({
        eventName = 'initializeLoadingScreen',
        serverName = GetConvar('sv_hostname', 'Loading Server...'),
        logoUrl = GetConvar('sv_logo', 'images/logo.png'),
        totalResources = totalResources
    })

    -- Track resource loading
    AddEventHandler('onClientResourceStart', function(resourceName)
        if resourceList[resourceName] == false then
            startedResources = startedResources + 1
            resourceList[resourceName] = true
            
            local progress = (startedResources / totalResources) * 100
            SendNUIMessage({
                eventName = 'onFileStart',
                fileName = resourceName,
                progress = progress,
                current = startedResources,
                total = totalResources,
                status = 'started'
            })

            -- Check if loading is complete
            if startedResources >= totalResources or (GetGameTimer() - startTime) > 30000 then
                Wait(1000) -- Give time for last update to show
                ShutdownLoadingScreen()
                SetNuiFocus(false, false)
                isLoading = false
            end
        end
    end)

    -- Failsafe for loading
    CreateThread(function()
        while isLoading do
            Wait(500)
            if (GetGameTimer() - startTime) > 30000 then
                ShutdownLoadingScreen()
                SetNuiFocus(false, false)
                isLoading = false
                break
            end
        end
    end)
end

-- Start tracking when this resource starts
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeLoadingScreen()
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

-- Debug command for testing
RegisterCommand('reloadscreen', function()
    isLoading = true
    loadedResources = 0
    startTime = GetGameTimer()
    SetNuiFocus(true, false)
end, false)