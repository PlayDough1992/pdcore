-- Define events for pd-bank in case t        -- Save to pd-bank resource if it's running
    if GetResourceState('pd-bank') == 'started' then
        -- Make sure we have default values if they're missing
        moneyData.cash = moneyData.cash or 0
        moneyData.bank = moneyData.bank or 0
        
        -- Direct save using SaveResourceFile
        SaveResourceFile('pd-bank', path, json.encode(moneyData), -1)
        
        -- Log only when debug is enabled to prevent duplicate logs
        if Config.Debug then
            print("[pd-cash] Saved money data to pd-bank: " .. path .. " | Cash: $" .. moneyData.cash)
        end
        
        -- Also try to export the data if available
        if exports['pd-bank'] and exports['pd-bank'].SavePlayerMoney then
            exports['pd-bank']:SavePlayerMoney(identifier, moneyData)
            if Config.Debug then
                print("[pd-cash] Used export to save money data")
            end
        end
        
        return trueet
-- This ensures backward compatibility

-- Helper functions for the fallback handlers
local function getPlayerIdentifierInternal(source, prefix)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if id:sub(1, string.len(prefix)) == prefix then 
            return id 
        end
    end
    return nil
end

local function getPlayerMoneyInternal(identifier)
    -- identifier should be the FiveM identifier (e.g., steam:xxxx or fivem:xxxx)
    local safeId = identifier:gsub(':', '%%3A')
    local path = string.format("../pd-bank/playermoney/%s.json", safeId)
    
    -- Try to load file from pd-bank resource
    local moneyFile = nil
    if GetResourceState('pd-bank') == 'started' then
        moneyFile = LoadResourceFile('pd-bank', "playermoney/" .. safeId .. ".json")
    end
    
    if moneyFile then
        return json.decode(moneyFile)
    end
    return {
        cash = 0,
        bank = 0
    }
end

local function savePlayerMoneyInternal(identifier, moneyData)
    local safeId = identifier:gsub(':', '%%3A')
    local path = string.format("playermoney/%s.json", safeId)
    
    -- Save to pd-bank resource if it's running
    if GetResourceState('pd-bank') == 'started' then
        -- Make sure we have default values if they're missing
        moneyData.cash = moneyData.cash or 0
        moneyData.bank = moneyData.bank or 0
        
        -- Direct save using SaveResourceFile
        SaveResourceFile('pd-bank', path, json.encode(moneyData), -1)
        print("[pd-cash] Saved money data to pd-bank: " .. path .. " | Cash: $" .. moneyData.cash)
        
        -- Also try to export the data if available
        if exports['pd-bank'] and exports['pd-bank'].SavePlayerMoney then
            exports['pd-bank']:SavePlayerMoney(identifier, moneyData)
            print("[pd-cash] Used export to save money data")
        end
        
        return true
    else
        print("[pd-cash] WARNING: Could not save money data - pd-bank resource not running")
        return false
    end
end

if not GetResourceState('pd-bank') then
    print("[pd-cash] WARNING: pd-bank resource not found. Money updates may not be saved properly.")
end

-- Register our own version of pd-bank events if they don't exist
if GetResourceState('pd-bank') == 'started' then
    -- Check if the events already exist
    local eventsRegistered = false
    
    -- Create a global variable that will be used to track if the event handler exists
    PD_EVENT_HANDLER_CHECK = false
    
    -- Try to trigger a test event to check if handlers exist
    local eventName = 'pd-bank:checkEvents'
    
    -- Register a handler for our test event first
    AddEventHandler(eventName, function()
        PD_EVENT_HANDLER_CHECK = true
    end)
    
    -- Trigger the test event
    TriggerEvent(eventName)
    
    -- Wait a short time for event handlers to respond
    Citizen.Wait(100)
    
    eventsRegistered = PD_EVENT_HANDLER_CHECK
    PD_EVENT_HANDLER_CHECK = nil -- Clean up global
    
    if not eventsRegistered then
        print("[pd-cash] Creating fallback pd-bank events for cash management")
        
        -- Define add/remove cash events if they don't exist
        AddEventHandler('pd-bank:addCash', function(playerId, amount)
            local fivemId = getPlayerIdentifierInternal(playerId, 'fivem:')
            if not fivemId then 
                print("[pd-cash] ERROR: Could not find fivem identifier for player " .. GetPlayerName(playerId))
                return 
            end
            
            local moneyData = getPlayerMoneyInternal(fivemId)
            moneyData.cash = moneyData.cash + amount
            savePlayerMoneyInternal(fivemId, moneyData)
            
            if Config.Debug then
                print("[pd-cash] Added $" .. amount .. " to player " .. GetPlayerName(playerId) .. " (fallback method)")
            end
        end)
        
        AddEventHandler('pd-bank:removeCash', function(playerId, amount)
            local fivemId = getPlayerIdentifierInternal(playerId, 'fivem:')
            if not fivemId then 
                print("[pd-cash] ERROR: Could not find fivem identifier for player " .. GetPlayerName(playerId))
                return 
            end
            
            local moneyData = getPlayerMoneyInternal(fivemId)
            moneyData.cash = moneyData.cash - amount
            if moneyData.cash < 0 then moneyData.cash = 0 end
            savePlayerMoneyInternal(fivemId, moneyData)
            
            if Config.Debug then
                print("[pd-cash] Removed $" .. amount .. " from player " .. GetPlayerName(playerId) .. " (fallback method)")
            end
        end)
        
        print("[pd-cash] Fallback events registered")
    else
        print("[pd-cash] Using existing pd-bank events for cash management")
    end
end
