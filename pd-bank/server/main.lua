local Bank = {}
Bank.Accounts = {}

local function LoadMoneyFromJson(identifier)
    local path = string.format("playermoney/%s.json", identifier)
    local moneyFile = LoadResourceFile(GetCurrentResourceName(), path)
    if moneyFile then
        return json.decode(moneyFile)
    end
    return {
        cash = 0,
        bank = 0
    }
end

local function SaveMoneyToJson(identifier, moneyData)
    local path = string.format("playermoney/%s.json", identifier)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(moneyData), -1)
end

-- Add these exports for money management
exports('GetMoney', function(identifier)
    local moneyData = LoadMoneyFromJson(identifier)
    return moneyData.bank
end)

exports('RemoveMoney', function(identifier, amount)
    local moneyData = LoadMoneyFromJson(identifier)
    if moneyData.bank >= amount then
        moneyData.bank = moneyData.bank - amount
        SaveMoneyToJson(identifier, moneyData)
        return true
    end
    return false
end)

RegisterServerEvent('pd-bank:addMoney')
AddEventHandler('pd-bank:addMoney', function(playerId, amount)
    local identifier = GetPlayerIdentifier(playerId, 0)
    local moneyData = LoadMoneyFromJson(identifier)
    moneyData.bank = moneyData.bank + amount
    SaveMoneyToJson(identifier, moneyData)
end)

return Bank