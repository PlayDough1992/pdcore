RegisterServerEvent('pd-phonev2:getBankBalance')
AddEventHandler('pd-phonev2:getBankBalance', function()
    local src = source
    local fivemId = nil
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id:sub(1, 6) == 'fivem:' then
            fivemId = id
            break
        end
    end
    if not fivemId then
        TriggerClientEvent('pd-phonev2:updateBalance', src, {bank=0, cash=0})
        return
    end
    local safeId = fivemId:gsub(':', '%%3A')
    local path = string.format('../pd-bank/playermoney/%s.json', safeId)
    local moneyFile = LoadResourceFile('pd-bank', path)
    if moneyFile then
        local moneyData = json.decode(moneyFile)
        TriggerClientEvent('pd-phonev2:updateBalance', src, {bank=moneyData.bank or 0, cash=moneyData.cash or 0})
    else
        TriggerClientEvent('pd-phonev2:updateBalance', src, {bank=0, cash=0})
    end
end)


local oauthProcess = nil
local oauthPath = GetResourcePath(GetCurrentResourceName()) .. "/oauth-server/oauth-server.js"
local nodePath = "node"

function startOAuthServer()
    if oauthProcess then
        StopOAuthServer()
    end
    oauthProcess = os.execute(nodePath .. ' "' .. oauthPath .. '" > nul 2>&1 &')
end

function StopOAuthServer()
    if oauthProcess then
        -- Kill all node processes in the oauth-server directory (Windows compatible)
        os.execute('for /f "tokens=5" %a in (\'netstat -ano ^| findstr :3001\') do taskkill /F /PID %a')
        oauthProcess = nil
    end
end

CreateThread(function()
    startOAuthServer()
    while true do
        Wait(30 * 60 * 1000) -- 30 minutes
        StopOAuthServer()
        Wait(2000)
        startOAuthServer()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        StopOAuthServer()
    end
end)

SetHttpHandler(function(req, res)
    print("[pd-phonev2] HTTP request received:", req.method, req.path)
    if req.path == '/youtube_oauth' and req.method == 'POST' then
        req.setBodyHandler(function(body)
            local data = json.decode(body)
            local token = data.token
            local fivemid = tonumber(data.fivemid)
            if token and fivemid then
                TriggerClientEvent('pd-phonev2:youtube:receiveToken', fivemid, token)
                res.send('OK')
            else
                res.send('Missing token or fivemid')
            end
        end)
    else
        res.send('Route not found.')
    end
end)
