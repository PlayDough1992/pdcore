-- pd-cash: Cash drop and transfer system
Config = {}

-- Debug mode (set to true for verbose console logging)
Config.Debug = false

-- Notification settings
Config.Notifications = {
    OnSpawn = {
        Enabled = false,         -- Show notifications when cash drops spawn
        OnlyToNearbyPlayers = true, -- Only notify players within NotifyRadius
        NotifyRadius = 100.0,    -- Distance in meters for nearby notifications
        AdminOnly = false        -- Only notify admins about cash drops
    },
    OnAttempt = {
        Enabled = false,         -- Show notifications when attempting to create cash drops
        AdminOnly = false        -- Only notify admins about creation attempts
    }
}

-- Cash drop settings
Config.CashSpawn = {
    Enabled = true,
    Interval = 20000, -- ms between spawns (20 seconds)
    AmountMin = 100,
    AmountMax = 500,
    PickupRadius = 2.0,
    MaxDrops = 20,
    -- Position and display settings
    AlwaysGroundLevel = true, -- Always place cash at ground level regardless of Z coordinate
    AddBlip = true, -- Add a blip on the minimap for cash drops
    BlipColor = 2, -- Green
    ShowMarker = true, -- Show a marker above the cash
    VisualEffects = true, -- Enable particle effects for better visibility
    -- Cash pickup model options
    Model = "PICKUP_MONEY_VARIABLE", -- Default native GTA pickup name
    ModelHash = -424660425, -- Hash for PICKUP_MONEY_VARIABLE
    -- Alternative models and their hashes for different amounts
    Models = {
        Small = {
            Name = "PICKUP_MONEY_VARIABLE",
            Hash = -424660425
        },
        Medium = {
            Name = "PICKUP_MONEY_DEP_BAG",
            Hash = -1666598909
        },
        Large = {
            Name = "PICKUP_MONEY_MED_BAG",
            Hash = -1666779307
        }
    },
    -- Object props as alternatives
    Props = {
        Small = "prop_cash_pile_02",
        Medium = "prop_cash_pile_01",
        Large = "prop_money_bag_01"
    },
    Locations = {
        vector3(215.76, -810.12, 30.73),
        vector3(-56.92, -1752.12, 29.42),
        vector3(170.12, 6637.82, 31.71),
        vector3(-1095.36, -850.68, 13.69),
        vector3(1122.1, -3194.9, -40.4),
        vector3(24.47, -1347.37, 29.5), -- Grove St store
        vector3(-47.42, -1758.67, 29.42), -- Davis store
        vector3(373.87, 325.89, 103.56), -- Vinewood store
        vector3(2557.46, 382.05, 108.62), -- Palomino store
        vector3(-3038.71, 585.9, 7.91), -- Chumash store
        vector3(-3241.47, 1001.14, 12.83), -- Chumash 2
        vector3(1163.37, -323.8, 69.21), -- Mirror Park store
        vector3(-1487.55, -379.11, 40.16), -- Del Perro store
        vector3(-2968.24, 390.91, 15.04), -- Great Ocean store
        vector3(1135.81, -982.28, 46.42), -- El Rancho store
        vector3(1166.0, 2708.93, 38.16), -- Harmony store
        vector3(1392.56, 3604.68, 34.98), -- Sandy store
        vector3(1961.48, 3740.29, 32.34), -- Sandy 2
        vector3(2678.92, 3280.85, 55.24), -- Grapeseed store
        vector3(1729.21, 6414.13, 35.04), -- Paleto store
        vector3(-1820.68, 792.41, 138.12), -- Richman mansion
        vector3(-1206.26, -1560.62, 4.61), -- Vesp beach store
        vector3(-712.9, -818.93, 23.73), -- Little Seoul
        vector3(-43.43, -2015.99, 18.02), -- Grove St gas
        vector3(818.72, -3197.6, 5.99), -- Docks
        vector3(1853.21, 3689.51, 34.27), -- Sandy airfield
        vector3(-255.54, -1530.77, 31.59), -- Strawberry
        vector3(126.98, -1299.99, 29.27), -- Legion Square
        vector3(-1307.86, -394.19, 36.7), -- Del Perro
        vector3(236.48, 217.47, 106.29), -- Vinewood
        vector3(-68.7, 6459.44, 31.49), -- Paleto
        vector3(1697.99, 4924.4, 42.06), -- Grapeseed
        vector3(2677.41, 3281.0, 55.24), -- Grapeseed 2
        vector3(1728.66, 6416.62, 35.04), -- Paleto 2
        vector3(-3243.99, 1001.46, 12.83), -- Chumash 3
        vector3(-3039.1, 585.54, 7.91), -- Chumash 4
        vector3(549.05, 2671.39, 42.16), -- Harmony 2
        vector3(1165.22, 2710.89, 38.16), -- Harmony 3
        vector3(2556.85, 380.88, 108.62), -- Palomino 2
        vector3(373.02, 326.3, 103.56), -- Vinewood 2
        vector3(-48.52, -1757.89, 29.42), -- Davis 2
        vector3(25.7, -1347.3, 29.5), -- Grove St 2
        vector3(202.2500, 1246.0000, 225.4675) -- Sorry Commode parking lot
    }
}

-- Player-to-player cash transfer settings
Config.Give = {
    Radius = 10.0, -- Maximum distance between players to allow transfers
    MaxAmount = 10000, -- Maximum amount that can be transferred at once
    Reasons = {
        'Gift', 
        'Loan', 
        'Debt Payment', 
        'Item Sale', 
        'Vehicle Sale', 
        'Service Payment',
        'Gambling Winnings', 
        'Other'
    }
}

-- Debug settings
Config.Debug = {
    Enabled = true, -- Set to true to enable debug commands and notifications
    AdminOnly = false -- Set to true to restrict debug commands to admins only
}
