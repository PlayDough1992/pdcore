Jobs = {}
Jobs.Config = {
    PayFrequency = 5,
    EnableDebug = false,  -- Set to true temporarily
    Jobs = {
        police = {
            label = "Police Department",
            ranks = {
                {name = "Cadet", pay = 1500, grade = 0},
                {name = "Officer", pay = 2000, grade = 1},
                {name = "Sergeant", pay = 2500, grade = 2},
                {name = "Lieutenant", pay = 3000, grade = 3},
                {name = "Captain", pay = 3500, grade = 4},
                {name = "Chief", pay = 4000, grade = 5}
            }
        },
        ems = {
            label = "Emergency Medical",
            ranks = {
                {name = "EMT-B", pay = 1500, grade = 0},
                {name = "EMT-I", pay = 2000, grade = 1},
                {name = "Paramedic", pay = 2500, grade = 2},
                {name = "Supervisor", pay = 3000, grade = 3},
                {name = "Chief", pay = 3500, grade = 4}
            }
        },
        mechanic = {
            label = "Mechanic",
            ranks = {
                {name = "Apprentice", pay = 1000, grade = 0},
                {name = "Mechanic", pay = 1500, grade = 1},
                {name = "Senior Mechanic", pay = 2000, grade = 2},
                {name = "Shop Owner", pay = 2500, grade = 3}
            }
        }
    }
}

local function LoadJobFromJson(identifier)
    local path = string.format("playerjobs/%s_job.json", identifier)
    local jobFile = LoadResourceFile(GetCurrentResourceName(), path)
    if jobFile then
        return json.decode(jobFile)
    end
    return nil
end

local function SaveJobToJson(identifier, jobData)
    local path = string.format("playerjobs/%s_job.json", identifier)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(jobData), -1)
end

if IsDuplicityVersion() then -- Server side
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Jobs.Config.PayFrequency * 60 * 1000)
            local players = GetPlayers()
            
            -- Add players validation
            if not players or #players == 0 then
                if Jobs.Config.EnableDebug then
                    print("[PD-JOBS] No players online, skipping payment cycle")
                end
                goto continue
            end

            for _, player in ipairs(players) do
                if player and tonumber(player) > 0 then
                    ExecuteCommand('payme ' .. player)
                    if Jobs.Config.EnableDebug then
                        print(string.format('[PD-JOBS] Triggered payme for player %s', player))
                    end
                else
                    if Jobs.Config.EnableDebug then
                        print(string.format('[PD-JOBS] Invalid player ID: %s', tostring(player)))
                    end
                end
                Citizen.Wait(100)
            end
            
            ::continue::
        end
    end)
else -- Client side
    -- Keep client-side code for other functionality
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            -- Client-side job related code here
        end
    end)
end

return Jobs