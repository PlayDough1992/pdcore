RegisterServerEvent('pd-phone:getBankBalance')
AddEventHandler('pd-phone:getBankBalance', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    local path = string.format("../pd-bank/playermoney/%s.json", identifier)
    local moneyFile = LoadResourceFile("pd-bank", path)
    
    if moneyFile then
        local moneyData = json.decode(moneyFile)
        TriggerClientEvent('pd-phone:updateBalance', source, moneyData.bank)
    end
end)
