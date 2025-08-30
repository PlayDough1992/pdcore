Config = {}

Config.Shops = {
    ammunation = {
        locations = {
            {
                coords = vector3(252.696, -50.514, 69.941),
                heading = 71.0,
                pedModel = "s_m_y_ammucity_01"
            },
            {
                coords = vector3(842.9892, -1035.2505, 28.1949),
                heading = 355.9628,
                pedModel = "s_m_y_ammucity_01"
            },
            {
                coords = vector3(-1304.1014, -394.4427, 36.6958),
                heading = 71.1910,
                pedModel = "s_m_y_ammucity_01"
            }
            -- Add all Ammunation locations
        },
        items = {
            weapons = {
                -- Handguns
                {
                    name = "WEAPON_PISTOL",
                    price = 1000,
                    label = "Pistol",
                    category = "Handguns"
                },
                {
                    name = "WEAPON_COMBATPISTOL",
                    price = 1500,
                    label = "Combat Pistol",
                    category = "Handguns"
                },
                -- SMGs
                {
                    name = "WEAPON_SMG",
                    price = 2500,
                    label = "SMG",
                    category = "SMGs"
                },
                {
                    name = "WEAPON_MICROSMG",
                    price = 2200,
                    label = "Micro SMG",
                    category = "SMGs"
                },
                -- Rifles
                {
                    name = "WEAPON_CARBINERIFLE",
                    price = 3500,
                    label = "Carbine Rifle",
                    category = "Rifles"
                },
                -- Shotguns
                {
                    name = "WEAPON_PUMPSHOTGUN",
                    price = 2800,
                    label = "Pump Shotgun",
                    category = "Shotguns"
                }
            },
            ammo = {
                {
                    name = "ammo-pistol",
                    price = 50,
                    label = "Pistol Ammo",
                    amount = 30
                }
                -- Add more ammo types
            },
            armor = {
                {
                    name = "armor",
                    price = 800,
                    label = "Body Armor",
                    armorValue = 100
                }
            }
        }
    },
    
    robsliquor = {
        locations = {
            {
                coords = vector3(-1486.7820, -377.5370, 40.1634),
                heading = 140.3854,
                pedModel = "mp_m_shopkeep_01"
            }
        },
        items = {
            alcohol = {
                {
                    name = "beer",
                    price = 15,
                    label = "Beer",
                    category = "Alcohol"
                },
                {
                    name = "whiskey",
                    price = 45,
                    label = "Whiskey",
                    category = "Alcohol"
                },
                {
                    name = "vodka",
                    price = 35,
                    label = "Vodka",
                    category = "Alcohol"
                }
            },
            tobacco = {
                {
                    name = "cigarettes",
                    price = 10,
                    label = "Cigarettes",
                    category = "Tobacco"
                },
                {
                    name = "lighter",
                    price = 5,
                    label = "Lighter",
                    category = "Tobacco"
                }
            }
        }
    }
}