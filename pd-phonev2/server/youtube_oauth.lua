--[[
This server script handles the YouTube OAuth callback and relays the access token to the NUI phone app.
You must set up a web server (Node.js, PHP, etc.) at https://yourserver.com/oauth-callback to receive the OAuth code from Google, exchange it for an access token, and POST it to this resource using the /youtube_oauth endpoint.
]]

local ytTokens = {}

RegisterNetEvent('pd-phonev2:youtube:relayToken', function(token)
    local src = source
    ytTokens[src] = token
    TriggerClientEvent('pd-phonev2:youtube:receiveToken', src, token)
end)

-- HTTP endpoint for your web server to call after exchanging the code for a token
-- Example POST: http://localhost:30120/youtube_oauth?token=ya29...&fivemid=playerid
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SetHttpHandler(function(req, res)
            local path = req.path
            if path == '/youtube_oauth' and req.method == 'POST' then
                req.setBodyHandler(function(body)
                    local data = json.decode(body)
                    local token = data.token
                    local fivemid = tonumber(data.fivemid)
                    if token and fivemid then
                        ytTokens[fivemid] = token
                        TriggerClientEvent('pd-phonev2:youtube:receiveToken', fivemid, token)
                        res.send('OK')
                    else
                        res.send('Missing token or fivemid')
                    end
                end)
            else
                res.send('Not found')
            end
        end)
    end
end)
