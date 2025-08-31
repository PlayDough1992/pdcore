Config = {}

-- Authorization Settings
Config.AdminIdentifier = "fivem" -- Type of identifier to check for admin

-- Job based vehicle type authorization
Config.JobAuthorization = {
    -- Police Vehicle Authorization
    authorizedPolice = {
        "fivem:xxxxxx"--,
       -- "license:xxxxxxxx",
       -- "fivem:xxxxxxxx"
    },

    -- EMS Vehicle Authorization
    authorizedEms = {
        "fivem:xxxxxx"--,
       -- "license:xxxxxxxx",
       -- "fivem:xxxxxxxx"
    },

    -- Fire Vehicle Authorization
    authorizedFire = {
        "fivem:xxxxxx"--,
       -- "license:xxxxxxxx",
       -- "fivem:xxxxxxxx"
    }
}

-- Vehicle Categories with all vanilla GTA V vehicles
Config.Categories = {
    {
        name = "emergency",
        label = "Emergency Vehicles",
        order = 1,
        restricted = true,
        vehicles = {
            { name = "Police Cruiser", model = "police", type = "police" },
            { name = "Police Buffalo", model = "police2", type = "police" },
            { name = "Police Interceptor", model = "police3", type = "police" },
            { name = "Unmarked Cruiser", model = "police4", type = "police" },
            { name = "FIB Buffalo", model = "fbi", type = "police" },
            { name = "FIB Granger", model = "fbi2", type = "police" },
            { name = "Sheriff Cruiser", model = "sheriff", type = "police" },
            { name = "Sheriff SUV", model = "sheriff2", type = "police" },
            { name = "Police Riot", model = "riot", type = "police" },
            { name = "Police Prison Bus", model = "pbus", type = "police" },
    --      { name = "Lamborghini Police Car", model = "polrevent", type = "police" },  -- Example Addon Car
            { name = "Ambulance", model = "ambulance", type = "ems" },
            { name = "Fire Truck", model = "firetruk", type = "fire" }
        }
    },
    {
        name = "compacts",
        label = "Compact Cars",
        order = 2,
        vehicles = {
            { name = "Blista", model = "blista" },
            { name = "Brioso R/A", model = "brioso" },
            { name = "Dilettante", model = "dilettante" },
            { name = "Issi", model = "issi2" },
            { name = "Panto", model = "panto" },
            { name = "Prairie", model = "prairie" },
            { name = "Rhapsody", model = "rhapsody" }
        }
    },
    {
        name = "sedans",
        label = "Sedans",
        order = 3,
        vehicles = {
            { name = "Asea", model = "asea" },
            { name = "Asterope", model = "asterope" },
            { name = "Emperor", model = "emperor" },
            { name = "Fugitive", model = "fugitive" },
            { name = "Glendale", model = "glendale" },
            { name = "Ingot", model = "ingot" },
            { name = "Intruder", model = "intruder" },
            { name = "Premier", model = "premier" },
            { name = "Primo", model = "primo" },
            { name = "Regina", model = "regina" },
            { name = "Stanier", model = "stanier" },
            { name = "Stratum", model = "stratum" },
            { name = "Super Diamond", model = "superd" },
            { name = "Surge", model = "surge" },
            { name = "Tailgater", model = "tailgater" },
            { name = "Warrener", model = "warrener" },
            { name = "Washington", model = "washington" }
        }
    },
    {
        name = "suvs",
        label = "SUVs",
        order = 4,
        vehicles = {
            { name = "Baller", model = "baller" },
            { name = "Cavalcade", model = "cavalcade" },
            { name = "Granger", model = "granger" },
            { name = "Huntley S", model = "huntley" },
            { name = "Landstalker", model = "landstalker" },
            { name = "Mesa", model = "mesa" },
            { name = "Patriot", model = "patriot" },
            { name = "Radius", model = "radi" },
            { name = "Rocoto", model = "rocoto" },
            { name = "Seminole", model = "seminole" },
            { name = "XLS", model = "xls" }
        }
    },
    {
        name = "sports",
        label = "Sports Cars",
        order = 5,
        vehicles = {
            { name = "9F", model = "ninef" },
            { name = "9F Cabrio", model = "ninef2" },
            { name = "Banshee", model = "banshee" },
            { name = "Buffalo", model = "buffalo" },
            { name = "Carbonizzare", model = "carbonizzare" },
            { name = "Comet", model = "comet2" },
            { name = "Coquette", model = "coquette" },
            { name = "Elegy RH8", model = "elegy2" },
            { name = "Feltzer", model = "feltzer2" },
            { name = "Fusilade", model = "fusilade" },
            { name = "Jester", model = "jester" },
            { name = "Kuruma", model = "kuruma" }
        }
    }
}

-- Spawn Settings
Config.SpawnSettings = {
    spawnInVehicle = true,
    deleteOldVehicle = true,
    maxDistance = 5.0,
    defaultProperties = {
        engineHealth = 1000,
        bodyHealth = 1000,
        fuelLevel = 100,
        plate = "PDCORE"
    }
}

-- UI Settings (Matching pd-clothing theme)
Config.UI = {
    colors = {
        primary = "#3b82f6",     -- Blue
        secondary = "#1e40af",   -- Dark Blue
        background = "#111827",  -- Dark Gray
        surface = "#1f2937",     -- Lighter Dark Gray
        border = "#374151",      -- Border Gray
        text = "#ffffff",        -- White Text
        textSecondary = "#9ca3af" -- Secondary Text
    }
}

-- Key Bindings
Config.Keys = {
    toggle = 'F7',
    close = 'ESC'
}

return Config


