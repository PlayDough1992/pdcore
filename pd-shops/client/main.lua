local shopPeds = {}
local isNearShop = false
local currentShop = nil

-- Initialize shop peds
CreateThread(function()
    for shopType, shop in pairs(Config.Shops) do
        for _, location in ipairs(shop.locations) do
            local model = GetHashKey(location.pedModel)
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end

            local ped = CreatePed(4, model, location.coords.x, location.coords.y, location.coords.z - 1.0, location.heading, false, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            FreezeEntityPosition(ped, true)

            table.insert(shopPeds, {
                ped = ped,
                type = shopType,
                location = location
            })
        end
    end
end)

-- Check distance to shop peds
CreateThread(function()
    while true do
        Wait(500)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        isNearShop = false
        
        for _, shop in ipairs(shopPeds) do
            local distance = #(playerCoords - GetEntityCoords(shop.ped))
            if distance < 3.0 then
                isNearShop = true
                currentShop = shop.type
                break
            end
        end
    end
end)

-- Show interaction prompt
CreateThread(function()
    while true do
        Wait(0)
        if isNearShop then
            DrawText3D(GetEntityCoords(PlayerPedId()), "Press ~y~E~w~ to shop")
            if IsControlJustPressed(0, 38) then -- E key
                OpenShopMenu(currentShop)
            end
        end
    end
end)

function OpenShopMenu(shopType)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openShop",
        shop = Config.Shops[shopType]
    })
end

-- Helper function for 3D text
function DrawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.0)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

-- Add these new event handlers
RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('purchaseItem', function(data, cb)
    print("^2[DEBUG Shop]^7 Purchase callback triggered")
    print("^2[DEBUG Shop]^7 Data:", json.encode(data))
    
    -- Trigger the server event
    TriggerServerEvent('pd-shops:purchase', data)
    
    cb({status = "ok"})
end)

RegisterNetEvent('pd-shops:weaponPurchased')
AddEventHandler('pd-shops:weaponPurchased', function(weaponName)
    print('^2[DEBUG Shop]^7 Triggering weapon add for:', weaponName)
    TriggerServerEvent('pd-inventory:addWeapon', weaponName)
end)