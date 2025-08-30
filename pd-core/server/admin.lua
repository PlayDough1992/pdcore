local adminList = {
    "discord:921141362810839061", -- PlayDough
    "discord:891004735199518822"  -- madman
}

local function IsPlayerAdmin(source)
    local discordId = nil
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, "discord:") then
            discordId = identifier
            break
        end
    end
   
    for _, adminId in ipairs(adminList) do
        if discordId == adminId then
            return true
        end
    end
    return false
end

exports('IsPlayerAdmin', IsPlayerAdmin)