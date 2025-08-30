local inventories = {}
local dropOnDeath = {}  -- Store player death drop preferences

-- Helper functions
local function ensureDirectoryExists(path)
    -- Try to create directory if it doesn't exist
    os.execute('mkdir "' .. path .. '" 2>/nul')
    
    -- Verify directory exists
    local ok = io.open(path, "r")
    if ok then
        ok:close()
        return true
    end
    
    print("^1[ERROR]^7 Failed to create directory:", path)
    return false
end

local function loadPlayerPreferences(license)
    local path = GetResourcePath(GetCurrentResourceName())
    local filePath = path..'/playerdata/'..license..'.json'
    
    local file = io.open(filePath, "r")
    if not file then return { dropInventory = true } end
    
    local content = file:read("*all")
    file:close()
    
    local success, prefs = pcall(json.decode, content)
    return success and prefs or { dropInventory = true }
end

local function savePlayerPreferences(license, prefs)
    local path = GetResourcePath(GetCurrentResourceName())
    ensureDirectoryExists(path..'/playerdata')
    
    local filePath = path..'/playerdata/'..license..'.json'
    local file = io.open(filePath, "w+")
    
    if file then
        file:write(json.encode(prefs))
        file:close()
    end
end

-- Core inventory functions
function LoadPlayerInventory(source)
    local license = GetPlayerIdentifier(source, 0)
    if not license then 
        print("^1[ERROR]^7 No license found for player:", source)
        return {}
    end
    
    -- Enhanced debug prints
    print("^2[DEBUG]^7 =====================")
    print("^2[DEBUG]^7 Loading inventory:")
    print("^2[DEBUG]^7 Player ID:", source)
    print("^2[DEBUG]^7 License:", license)
    
    local path = GetResourcePath(GetCurrentResourceName())
    -- Create playeritems directory if it doesn't exist
    ensureDirectoryExists(path..'/playeritems')
    
    local filePath = path..'/playeritems/'..license..'.json'
    print("^2[DEBUG]^7 File path:", filePath)
    
    local file = io.open(filePath, "r")
    if not file then
        print("^3[WARNING]^7 Creating new inventory file")
        file = io.open(filePath, "w+")
        if file then
            file:write("{}")
            file:close()
            print("^2[DEBUG]^7 Created empty inventory file")
        end
        return {}
    end
    
    local content = file:read("*all")
    file:close()
    
    local success, items = pcall(json.decode, content)
    if not success then
        print("^1[ERROR]^7 Failed to decode inventory JSON:", items)
        return {}
    end
    
    -- Load player preferences
    dropOnDeath[source] = loadPlayerPreferences(license).dropInventory
    
    print("^2[DEBUG]^7 Successfully loaded inventory")
    print("^2[DEBUG]^7 =====================")
    
    return items
end

function SavePlayerInventory(source)
    if not inventories[source] then return end
    
    local license = GetPlayerIdentifier(source, 0)
    if not license then return end
    
    local path = GetResourcePath(GetCurrentResourceName())
    local filePath = path..'/playeritems/'..license..'.json'
    
    local file = io.open(filePath, "w+")
    if file then
        file:write(json.encode(inventories[source]))
        file:close()
    end
end

-- Event handlers
RegisterNetEvent('pd-inventory:requestInventory')
AddEventHandler('pd-inventory:requestInventory', function()
    local source = source
    local items = LoadPlayerInventory(source)
    inventories[source] = items
    
    TriggerClientEvent('pd-inventory:loadInventory', source, {
        items = items,
        dropOnDeath = dropOnDeath[source]
    })
end)

RegisterNetEvent('pd-inventory:saveInventory')
AddEventHandler('pd-inventory:saveInventory', function(items)
    inventories[source] = items
    SavePlayerInventory(source)
end)

RegisterNetEvent('pd-inventory:toggleDropOnDeath')
AddEventHandler('pd-inventory:toggleDropOnDeath', function(enabled)
    local source = source
    local license = GetPlayerIdentifier(source, 0)
    
    dropOnDeath[source] = enabled
    savePlayerPreferences(license, { dropInventory = enabled })
end)

-- Modify the addWeapon event handler
RegisterNetEvent('pd-inventory:addWeapon')
AddEventHandler('pd-inventory:addWeapon', function(weaponName)
    local source = source
    local inventory = inventories[source] or LoadPlayerInventory(source)
    
    -- Check if weapon already exists
    local exists = false
    for _, item in pairs(inventory) do
        if item.weapon and item.name == weaponName then
            exists = true
            break
        end
    end
    
    if not exists then
        -- Find first empty slot
        local slot = "1"
        while inventory[slot] do
            slot = tostring(tonumber(slot) + 1)
            if tonumber(slot) > 50 then return end
        end
        
        -- Add weapon to inventory
        inventory[slot] = {
            name = weaponName,
            label = weaponName:gsub("WEAPON_", ""):gsub("_", " "):lower():gsub("^%l", string.upper),
            weapon = true,
            quantity = 1
        }
        
        -- Update server-side inventory
        inventories[source] = inventory
        SavePlayerInventory(source)
        
        -- Update client
        TriggerClientEvent('pd-inventory:loadInventory', source, {
            items = inventory,
            dropOnDeath = dropOnDeath[source] or false
        })
    end
end)

-- Modify the addItem event handler similarly
RegisterNetEvent('pd-inventory:addItem')
AddEventHandler('pd-inventory:addItem', function(itemName)
    local source = source
    local inventory = inventories[source] or LoadPlayerInventory(source)
    
    -- Check if item exists
    local existingSlot = nil
    for slot, item in pairs(inventory) do
        if not item.weapon and item.name == itemName then
            existingSlot = slot
            break
        end
    end
    
    if existingSlot then
        -- Update quantity
        inventory[existingSlot].quantity = (inventory[existingSlot].quantity or 1) + 1
    else
        -- Find first empty slot
        local slot = "1"
        while inventory[slot] do
            slot = tostring(tonumber(slot) + 1)
            if tonumber(slot) > 50 then return end
        end
        
        -- Add new item
        inventory[slot] = {
            name = itemName,
            label = Config.Items[itemName] and Config.Items[itemName].label or itemName,
            quantity = 1
        }
    end
    
    -- Update server-side inventory
    inventories[source] = inventory
    SavePlayerInventory(source)
    
    -- Update client
    TriggerClientEvent('pd-inventory:loadInventory', source, {
        items = inventory,
        dropOnDeath = dropOnDeath[source] or false
    })
end)

RegisterNetEvent('pd-inventory:weaponSpawned')
AddEventHandler('pd-inventory:weaponSpawned', function(weaponName)
    local source = source
    local license = GetPlayerIdentifier(source, 0)
    
    if not license then return end
    
    print('^2[DEBUG]^7 Weapon spawned:', weaponName)
    
    -- Load current inventory
    local inventory = inventories[source] or {}
    
    -- Find first empty slot
    local slot = "1"
    while inventory[slot] do
        slot = tostring(tonumber(slot) + 1)
        if tonumber(slot) > 50 then
            TriggerClientEvent('pd-notifications:notify', source, {
                text = "Inventory is full",
                type = "error"
            })
            return
        end
    end
    
    -- Add weapon to inventory
    inventory[slot] = {
        name = weaponName,
        label = weaponName:gsub("WEAPON_", ""):gsub("_", " "):lower():gsub("^%l", string.upper),
        weapon = true,
        quantity = 1
    }
    
    -- Update inventory
    inventories[source] = inventory
    SavePlayerInventory(source)
    
    -- Update client
    TriggerClientEvent('pd-inventory:loadInventory', source, {
        items = inventory,
        dropOnDeath = dropOnDeath[source] or false
    })
end)

-- Handle player death
AddEventHandler('playerDied', function(source)
    if dropOnDeath[source] then
        inventories[source] = {}
        SavePlayerInventory(source)
        
        TriggerClientEvent('pd-notifications:notify', source, {
            text = "You lost your inventory",
            type = "error"
        })
    end
end)

-- Handle disconnections and resource stops
AddEventHandler('playerDropped', function(reason)
    local source = source
    if inventories[source] then
        SavePlayerInventory(source)
        inventories[source] = nil
        dropOnDeath[source] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for source in pairs(inventories) do
        SavePlayerInventory(source)
    end
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    local source = source
    local license = GetPlayerIdentifier(source, 0)
    
    if not license then
        deferrals.done('No valid license found')
        return
    end
    
    print('^2[DEBUG]^7 Player connecting:', name)
    print('^2[DEBUG]^7 License:', license)
    
    -- Pre-load inventory
    local items = LoadPlayerInventory(source)
    inventories[source] = items
    
    print('^2[DEBUG]^7 Loaded inventory items:', json.encode(items))
end)

RegisterNetEvent('pd-inventory:clearInventory')
AddEventHandler('pd-inventory:clearInventory', function()
    local source = source
    inventories[source] = {}
    SavePlayerInventory(source)
    TriggerClientEvent('pd-inventory:loadInventory', source, {
        items = {},
        dropOnDeath = dropOnDeath[source] or false
    })
end)