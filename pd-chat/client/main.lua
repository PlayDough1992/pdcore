local testPlayerName = nil

RegisterCommand('testnotplayer', function(source, args, rawCommand)
    if #args >= 2 then
        local tempName = args[1]
        local message = table.concat(args, ' ', 2)
        
        SendNUIMessage({
            type = 'chat',
            playerName = tempName,
            message = message,
            isOwnMessage = false
        })
    end
end, false)

RegisterNetEvent('chat:addMessage')
AddEventHandler('chat:addMessage', function(data)
    if not data or not data.args then return end
    
    if string.find(table.concat(data.args, ' '), '/') then return end
    
    if #data.args >= 2 then
        local currentPlayerName = GetPlayerName(PlayerId())
        local isOwnMessage = data.args[1] == currentPlayerName
        
        SendNUIMessage({
            type = 'chat',
            playerName = data.args[1],
            message = data.args[2],
            isOwnMessage = isOwnMessage
        })
    end
end)