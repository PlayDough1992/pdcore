local isInventoryOpen = false
local playerInventory = {}
local hotbarVisible = false
local hotbarTimer = nil

-- Event Handlers
RegisterNetEvent('pd-inventory:loadInventory')
AddEventHandler('pd-inventory:loadInventory', function(data)
    playerInventory = data.items
    
    -- Update UI
    SendNUIMessage({
        type = "updateInventory",
        inventory = playerInventory,
        dropOnDeath = data.dropOnDeath
    })
end)

-- Weapon Detection (simplified to only track additions)
CreateThread(function()
    local lastWeapons = {}
    
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local currentWeapons = {}
        
        -- Check all weapons player has
        for _, hash in ipairs(GetWeaponsList()) do
            if HasPedGotWeapon(ped, hash, false) then
                local weaponName = GetWeaponNameFromHash(hash)
                if weaponName and weaponName ~= "WEAPON_UNARMED" then
                    currentWeapons[weaponName] = true
                    
                    -- If weapon wasn't in inventory before
                    if not lastWeapons[weaponName] then
                        print('^2[DEBUG]^7 New weapon detected:', weaponName)
                        TriggerServerEvent('pd-inventory:addWeapon', weaponName)
                    end
                end
            end
        end
        
        lastWeapons = currentWeapons
    end
end)

-- Helper function to get all possible weapon hashes
function GetWeaponsList()
    local weaponHashes = {}
    for itemName, itemData in pairs(Config.Items) do
        if itemData.weapon then
            table.insert(weaponHashes, GetHashKey(itemName))
        end
    end
    return weaponHashes
end

-- Helper function to convert hash to weapon name
function GetWeaponNameFromHash(hash)
    for itemName, itemData in pairs(Config.Items) do
        if itemData.weapon and GetHashKey(itemName) == hash then
            return itemName
        end
    end
    return nil
end

-- Core Functions
function ShowHotbar(duration)
    if not playerInventory then return end
    
    hotbarVisible = true
    SendNUIMessage({
        type = "setHotbarVisible",
        status = true
    })
    
    if hotbarTimer then
        ClearTimeout(hotbarTimer)
        hotbarTimer = nil
    end
    
    hotbarTimer = SetTimeout(duration or 3000, function()
        hotbarVisible = false
        SendNUIMessage({
            type = "setHotbarVisible",
            status = false
        })
        hotbarTimer = nil
    end)
end

-- Modify the UseHotbarSlot function
function UseHotbarSlot(slot)
    local item = playerInventory[tostring(slot)]
    if not item then 
        print('^3[DEBUG]^7 No item in slot:', slot)
        return 
    end
    
    print('^2[DEBUG]^7 Using item:', json.encode(item))
    
    if item.weapon then
        local ped = PlayerPedId()
        local weaponHash = GetHashKey(item.name)
        
        -- Check if this weapon is currently equipped
        local _, currentWeapon = GetCurrentPedWeapon(ped, true)
        local isEquipped = (currentWeapon == weaponHash)
        
        if isEquipped then
            RemoveWeaponFromPed(ped, weaponHash)
            
            TriggerEvent('pd-notifications:notify', {
                text = string.format("Unequipped %s", item.label),
                type = "info"
            })
        else
            RemoveAllPedWeapons(ped, true)
            GiveWeaponToPed(ped, weaponHash, 250, false, true)
            SetCurrentPedWeapon(ped, weaponHash, true)
            
            TriggerEvent('pd-notifications:notify', {
                text = string.format("Equipped %s", item.label),
                type = "success"
            })
        end
        
        -- Show hotbar without triggering inventory update
        SendNUIMessage({
            type = "setHotbarVisible",
            status = true,
            -- Don't send inventory here
        })
        
        if hotbarTimer then
            ClearTimeout(hotbarTimer)
        end
        
        hotbarTimer = SetTimeout(3000, function()
            SendNUIMessage({
                type = "setHotbarVisible",
                status = false
            })
            hotbarTimer = nil
        end)
    end
end

-- Commands and Keybindings
RegisterCommand('toggleinventory', function()
    SetInventoryState(not isInventoryOpen)
end)

RegisterKeyMapping('toggleinventory', 'Toggle Inventory', 'keyboard', 'TAB')

-- Modify the CreateThread for hotbar keys
CreateThread(function()
    for i = 1, 9 do
        RegisterCommand('hotbar_' .. i, function()
            UseHotbarSlot(i)
            -- Remove ShowHotbar call here since it's handled in UseHotbarSlot
        end)
        RegisterKeyMapping('hotbar_' .. i, 'Use Hotbar Slot ' .. i, 'keyboard', tostring(i))
    end
end)

-- Debug Commands
RegisterCommand('testinv', function()
    local weaponName = 'WEAPON_PISTOL'
    print('^2[DEBUG]^7 Testing inventory with weapon:', weaponName)
    TriggerServerEvent('pd-inventory:addWeapon', weaponName)
end)

RegisterCommand('checkinv', function()
    print('^2[DEBUG]^7 Requesting inventory refresh')
    TriggerServerEvent('pd-inventory:requestInventory')
end)

RegisterCommand('slotdebug', function()
    print('^2[DEBUG]^7 Inventory slot assignments:')
    for slot, item in pairs(playerInventory) do
        if item then
            print(string.format('^2[DEBUG]^7 Slot %s: %s (%s)', 
                slot, 
                item.name, 
                item.label or 'No Label'
            ))
        end
    end
end)

RegisterCommand('clearinv', function()
    print('^2[DEBUG]^7 Clearing inventory')
    TriggerServerEvent('pd-inventory:clearInventory')
end)

RegisterCommand('reloadinv', function()
    print('^2[DEBUG]^7 Reloading inventory')
    TriggerServerEvent('pd-inventory:requestInventory')
end)

-- NUI Callbacks
RegisterNUICallback('closeInventory', function(data, cb)
    SetInventoryState(false)
    cb('ok')
end)

RegisterNUICallback('toggleDropOnDeath', function(data, cb)
    TriggerServerEvent('pd-inventory:toggleDropOnDeath', data.enabled)
    cb('ok')
end)

-- Add this NUI callback for handling item drops
RegisterNUICallback('itemDropped', function(data, cb)
    local slot = tostring(data.slot)
    local item = playerInventory[slot]
    
    if item then
        print('^2[DEBUG]^7 Item dropped from inventory:', json.encode(item))
        
        if item.weapon then
            -- Remove weapon from ped if it was equipped
            local weaponHash = GetHashKey(item.name)
            RemoveWeaponFromPed(PlayerPedId(), weaponHash)
        end
        
        -- Remove from inventory
        playerInventory[slot] = nil
        TriggerServerEvent('pd-inventory:saveInventory', playerInventory)
        
        TriggerEvent('pd-notifications:notify', {
            text = string.format("Dropped %s", item.label),
            type = "error"
        })
    end
    
    cb('ok')
end)

-- UI State Management
function SetInventoryState(state)
    if state == isInventoryOpen then return end
    
    isInventoryOpen = state
    SetNuiFocus(state, state)
    
    SendNUIMessage({
        type = "setVisible",
        status = state,
        inventory = state and playerInventory or nil
    })
    
    if not state then
        TriggerServerEvent('pd-inventory:saveInventory', playerInventory)
    end
end

-- Initialize
CreateThread(function()
    while true do
        Wait(0)
        BlockWeaponWheelThisFrame()
        DisableControlAction(0, 37, true) -- Disable weapon wheel
    end
end)

-- Request initial inventory on spawn
AddEventHandler('playerSpawned', function()
    print('^2[DEBUG]^7 Player spawned, requesting inventory')
    TriggerServerEvent('pd-inventory:requestInventory')
    Wait(1000) -- Give time for inventory to load
    ShowHotbar(3000) -- Show initial hotbar
end)
