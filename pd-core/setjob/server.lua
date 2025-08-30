local function IsPlayerAdmin(source)
    local discordId = nil
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, "discord:") then
            discordId = identifier
            break
        end
    end
   
    local adminList = {
        "discord:921141362810839061", -- PlayDough
        "discord:891004735199518822"  -- madman
    }
   
    for _, adminId in ipairs(adminList) do
        if discordId == adminId then
            return true
        end
    end
    return false
end

RegisterCommand('setjob', function(source, args)
    if exports['pd-core']:IsPlayerAdmin(source) then
        TriggerClientEvent('pd-core:openSetJobMenu', source)
    else
        TriggerClientEvent('pd-notifications:notify', source, {
            text = 'You do not have access to (setjob) as you do not possess admin privileges',
            type = 'error'
        })
    end
end)

RegisterServerEvent('pd-core:getPlayers')
AddEventHandler('pd-core:getPlayers', function()
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(players, {
            id = id,
            name = GetPlayerName(id)
        })
    end
    TriggerClientEvent('pd-core:receivePlayers', source, players)
end)

RegisterServerEvent('pd-core:setJob')
AddEventHandler('pd-core:setJob', function(playerId, job, grade)
    local identifier = GetPlayerIdentifier(playerId, 0) -- Gets FiveM ID
    local jobData = {
        job = job,
        grade = grade
    }
    
    local path = string.format("playerjobs/%s.json", identifier)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(jobData), -1)
    
    TriggerClientEvent('pd-notifications:notify', playerId, {
        text = string.format('Your job has been set to %s - Grade %s', job, grade),
        type = 'success'
    })
end)
