-- pd-cash server: Shared variables and functions
-- This file contains variables and functions shared between server scripts

-- Initialize or reset shared variables
if PD_Cash == nil then
    PD_Cash = {
        spawnedCash = {},
        cashIdCounter = 0
    }
end

-- Get the next cash ID
function PD_Cash.getNextCashId()
    PD_Cash.cashIdCounter = PD_Cash.cashIdCounter + 1
    return PD_Cash.cashIdCounter
end

-- Add a cash drop
function PD_Cash.addCashDrop(coords, amount)
    local cashId = PD_Cash.getNextCashId()
    PD_Cash.spawnedCash[cashId] = {coords = coords, amount = amount}
    return cashId
end

-- Remove a cash drop
function PD_Cash.removeCashDrop(cashId)
    if PD_Cash.spawnedCash[cashId] then
        PD_Cash.spawnedCash[cashId] = nil
        return true
    end
    return false
end

-- Get all cash drops
function PD_Cash.getAllCashDrops()
    return PD_Cash.spawnedCash
end

-- Count cash drops
function PD_Cash.countCashDrops()
    local count = 0
    for _ in pairs(PD_Cash.spawnedCash) do
        count = count + 1
    end
    return count
end

-- Clear all cash drops
function PD_Cash.clearAllCashDrops()
    local count = PD_Cash.countCashDrops()
    PD_Cash.spawnedCash = {}
    return count
end
