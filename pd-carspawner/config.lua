Config = {}

Config.VehicleCategories = {
    ["compacts"] = "Compacts",
    ["sedans"] = "Sedans",
    ["suvs"] = "SUVs",
    ["coupes"] = "Coupes",
    ["muscle"] = "Muscle",
    ["sports"] = "Sports",
    ["super"] = "Super",
    ["motorcycles"] = "Motorcycles",
    ["offroad"] = "Off-road",
    ["industrial"] = "Industrial",
    ["utility"] = "Utility",
    ["vans"] = "Vans",
    ["emergency"] = "Emergency",
    ["addons"] = "Addon Vehicles"
}

-- Vehicle Categories with their corresponding vehicles
Config.Vehicles = {
    compacts = {
        {model = "asbo", name = "Asbo"},
        {model = "blista", name = "Blista"},
        {model = "brioso", name = "Brioso R/A"},
        {model = "club", name = "Club"},
        {model = "dilettante", name = "Dilettante"},
        {model = "issi2", name = "Issi Classic"},
        {model = "issi3", name = "Issi Sport"},
        {model = "kanjo", name = "Blista Kanjo"},
        {model = "panto", name = "Panto"},
        {model = "prairie", name = "Prairie"},
        {model = "rhapsody", name = "Rhapsody"},
        {model = "weevil", name = "Weevil"}
    },
    sedans = {
        {model = "asea", name = "Asea"},
        {model = "asterope", name = "Asterope"},
        {model = "cognoscenti", name = "Cognoscenti"},
        {model = "emperor", name = "Emperor"},
        {model = "fugitive", name = "Fugitive"},
        {model = "glendale", name = "Glendale"},
        {model = "ingot", name = "Ingot"},
        {model = "intruder", name = "Intruder"},
        {model = "premier", name = "Premier"},
        {model = "primo", name = "Primo"},
        {model = "regina", name = "Regina"},
        {model = "schafter2", name = "Schafter"},
        {model = "stanier", name = "Stanier"},
        {model = "stratum", name = "Stratum"},
        {model = "stretch", name = "Stretch"},
        {model = "superd", name = "Super Diamond"},
        {model = "surge", name = "Surge"},
        {model = "tailgater", name = "Tailgater"},
        {model = "warrener", name = "Warrener"},
        {model = "washington", name = "Washington"}
    },
    suvs = {
        {model = "baller", name = "Baller"},
        {model = "bjxl", name = "BeeJay XL"},
        {model = "cavalcade", name = "Cavalcade"},
        {model = "granger", name = "Granger"},
        {model = "gresley", name = "Gresley"},
        {model = "huntley", name = "Huntley S"},
        {model = "landstalker", name = "Landstalker"},
        {model = "patriot", name = "Patriot"},
        {model = "radi", name = "Radius"},
        {model = "rocoto", name = "Rocoto"},
        {model = "seminole", name = "Seminole"},
        {model = "serrano", name = "Serrano"},
        {model = "xls", name = "XLS"}
    },
    sports = {
        {model = "alpha", name = "Alpha"},
        {model = "banshee", name = "Banshee"},
        {model = "bestiagts", name = "Bestia GTS"},
        {model = "buffalo", name = "Buffalo"},
        {model = "carbonizzare", name = "Carbonizzare"},
        {model = "comet2", name = "Comet"},
        {model = "coquette", name = "Coquette"},
        {model = "elegy2", name = "Elegy RH8"},
        {model = "feltzer2", name = "Feltzer"},
        {model = "furoregt", name = "Furore GT"},
        {model = "fusilade", name = "Fusilade"},
        {model = "jester", name = "Jester"},
        {model = "kuruma", name = "Kuruma"},
        {model = "massacro", name = "Massacro"},
        {model = "ninef", name = "9F"},
        {model = "rapidgt", name = "Rapid GT"},
        {model = "surano", name = "Surano"}
    },
    super = {
        {model = "adder", name = "Adder"},
        {model = "bullet", name = "Bullet"},
        {model = "cheetah", name = "Cheetah"},
        {model = "entityxf", name = "Entity XF"},
        {model = "fmj", name = "FMJ"},
        {model = "infernus", name = "Infernus"},
        {model = "osiris", name = "Osiris"},
        {model = "pfister811", name = "811"},
        {model = "reaper", name = "Reaper"},
        {model = "t20", name = "T20"},
        {model = "turismor", name = "Turismo R"},
        {model = "vacca", name = "Vacca"},
        {model = "voltic", name = "Voltic"},
        {model = "zentorno", name = "Zentorno"}
    },
    emergency = {
        {model = "ambulance", name = "Ambulance"},
        {model = "firetruk", name = "Fire Truck"},
        {model = "police", name = "Police Cruiser"},
        {model = "police2", name = "Police Buffalo"},
        {model = "police3", name = "Police Interceptor"},
        {model = "policet", name = "Police Transporter"},
        {model = "riot", name = "Police Riot"},
        {model = "sheriff", name = "Sheriff Cruiser"},
        {model = "sheriff2", name = "Sheriff SUV"}
    },
    addons = {} -- This will be populated from addons.json
}

-- Vehicle modification types
Config.ModTypes = {
    ["engine"] = {name = "Engine", max = 4},
    ["brakes"] = {name = "Brakes", max = 3},
    ["transmission"] = {name = "Transmission", max = 3},
    ["suspension"] = {name = "Suspension", max = 4},
    ["armor"] = {name = "Armor", max = 4},
    ["turbo"] = {name = "Turbo", max = 1},
    ["xenon"] = {name = "Xenon Headlights", max = 1}
}

Config.Colors = {
    classic = {
        {name = "Black", r = 0, g = 0, b = 0},
        {name = "Carbon Black", r = 10, g = 10, b = 10},
        {name = "Graphite", r = 60, g = 60, b = 60},
        {name = "White", r = 255, g = 255, b = 255},
        {name = "Ice White", r = 240, g = 240, b = 240},
        -- Add more colors...
    },
    matte = {
        {name = "Matte Black", r = 12, g = 12, b = 12},
        {name = "Matte White", r = 255, g = 255, b = 255},
        {name = "Matte Red", r = 230, g = 0, b = 0},
        -- Add more colors...
    },
    metal = {
        {name = "Brushed Steel", r = 117, g = 117, b = 117},
        {name = "Brushed Black Steel", r = 38, g = 38, b = 38},
        {name = "Brushed Aluminum", r = 176, g = 176, b = 176},
        -- Add more colors...
    }
}

Config.QuickActions = {
    {name = "Repair", action = "repair"},
    {name = "Clean", action = "clean"},
    {name = "Flip", action = "flip"},
    {name = "Delete", action = "delete"},
    {name = "Save", action = "save"}
}

Config.DefaultSpawnDistance = 3.0
Config.PreviewCameraDistance = 5.0
Config.PreviewCameraHeight = 1.5
Config.MaxSavedVehicles = 10