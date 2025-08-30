RegisterServerEvent('pd-core:ready')
AddEventHandler('pd-core:ready', function()
    print('^2PlayDough Core Framework^7')
    print('^2Server Initialized^7')
    print('^2Created by PlayDough^7')
end)

local PlayerAccounts = {}

local function LoadJobFromJson(identifier)
    local path = string.format("playerjobs/%s.json", identifier)
    local jobFile = LoadResourceFile(GetCurrentResourceName(), path)
    if jobFile then
        return json.decode(jobFile)
    end
    return nil
end

RegisterCommand('payme', function(source, args)
    -- If command is triggered by server (source = 0), use first argument as player ID
    local playerSource = source
    if source == 0 and args[1] then
        playerSource = tonumber(args[1])
    end

    if not playerSource or playerSource == 0 then
        print("[PD-JOBS] Error: Invalid source in payme command")
        return
    end

    local identifier = GetPlayerIdentifier(playerSource, 0)
    -- Add identifier validation
    if not identifier then
        print(string.format("[PD-JOBS] Error: Could not get identifier for player %s", playerSource))
        return
    end

    local jobData = LoadJobFromJson(identifier)
    if not jobData then
        print(string.format("[PD-JOBS] Error: Could not load job data for player %s", playerSource))
        return
    end
    
    if jobData and jobData.job then
        local job = Jobs.Config.Jobs[jobData.job]
        if job then
            for _, rankData in ipairs(job.ranks) do
                if rankData.grade == jobData.grade then
                    TriggerEvent('pd-bank:addMoney', playerSource, rankData.pay)
                    TriggerClientEvent('pd-notifications:notify', playerSource, {
                        text = string.format('Paycheck Received: $%s from %s', rankData.pay, job.label),
                        type = 'success'
                    })
                    break
                end
            end
        end
    end
end)

RegisterServerEvent('pd-core:addMoney')
AddEventHandler('pd-core:addMoney', function(playerId, amount)
    if not PlayerAccounts[playerId] then
        PlayerAccounts[playerId] = {
            cash = 0,
            bank = 0
        }
    end
    
    PlayerAccounts[playerId].bank = PlayerAccounts[playerId].bank + amount
    SetPedMoney(GetPlayerPed(playerId), PlayerAccounts[playerId].bank)
end)

RegisterServerEvent('pd-core:getMoney')
AddEventHandler('pd-core:getMoney', function(source, account)
    if PlayerAccounts[source] then
        return PlayerAccounts[source][account]
    end
    return 0
end)
