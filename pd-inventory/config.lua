Config = {}

Config.SaveInterval = 180000 -- 3 minutes in milliseconds
Config.MaxSlots = 50
Config.HotbarSlots = 9
Config.MaxWeight = 50.0  -- Add this if not present

Config.Items = {
    -- MELEE WEAPONS
    ['WEAPON_DAGGER'] = {
        label = 'Antique Cavalry Dagger',
        weight = 1.0,
        description = 'Antique cavalry dagger',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_BAT'] = {
        label = 'Baseball Bat',
        weight = 2.0,
        description = 'Wooden baseball bat',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_BATTLEAXE'] = {
        label = 'Battle Axe',
        weight = 3.0,
        description = 'Heavy battle axe',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_BOTTLE'] = {
        label = 'Broken Bottle',
        weight = 0.5,
        description = 'Broken glass bottle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_CROWBAR'] = {
        label = 'Crowbar',
        weight = 2.5,
        description = 'Metal crowbar',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_UNARMED'] = {
        label = 'Fists',
        weight = 0.0,
        description = 'Your bare hands',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_FLASHLIGHT'] = {
        label = 'Flashlight',
        weight = 0.5,
        description = 'Tactical flashlight',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_GOLFCLUB'] = {
        label = 'Golf Club',
        weight = 1.5,
        description = 'Golf club',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HAMMER'] = {
        label = 'Hammer',
        weight = 1.5,
        description = 'Construction hammer',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HATCHET'] = {
        label = 'Hatchet',
        weight = 1.5,
        description = 'Small axe',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_KNUCKLE'] = {
        label = 'Brass Knuckles',
        weight = 0.5,
        description = 'Metal knuckle dusters',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_KNIFE'] = {
        label = 'Knife',
        weight = 0.5,
        description = 'Combat knife',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MACHETE'] = {
        label = 'Machete',
        weight = 2.0,
        description = 'Large blade',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SWITCHBLADE'] = {
        label = 'Switchblade',
        weight = 0.5,
        description = 'Concealable knife',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_NIGHTSTICK'] = {
        label = 'Nightstick',
        weight = 1.0,
        description = 'Police baton',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_WRENCH'] = {
        label = 'Wrench',
        weight = 2.0,
        description = 'Metal wrench',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_POOLCUE'] = {
        label = 'Pool Cue',
        weight = 1.5,
        description = 'Billiard stick',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_STONE_HATCHET'] = {
        label = 'Stone Hatchet',
        weight = 2.5,
        description = 'Primitive weapon',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- HANDGUNS
    ['WEAPON_PISTOL'] = {
        label = 'Pistol',
        weight = 3.0,
        description = 'Standard pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_PISTOL_MK2'] = {
        label = 'Pistol Mk II',
        weight = 3.2,
        description = 'Enhanced pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMBATPISTOL'] = {
        label = 'Combat Pistol',
        weight = 3.0,
        description = 'Military grade pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_APPISTOL'] = {
        label = 'AP Pistol',
        weight = 3.5,
        description = 'Automatic pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_STUNGUN'] = {
        label = 'Stun Gun',
        weight = 2.0,
        description = 'Non-lethal weapon',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_PISTOL50'] = {
        label = 'Pistol .50',
        weight = 4.0,
        description = 'Heavy pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SNSPISTOL'] = {
        label = 'SNS Pistol',
        weight = 2.0,
        description = 'Compact pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SNSPISTOL_MK2'] = {
        label = 'SNS Pistol Mk II',
        weight = 2.2,
        description = 'Enhanced compact pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HEAVYPISTOL'] = {
        label = 'Heavy Pistol',
        weight = 4.0,
        description = 'Heavy-duty pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_VINTAGEPISTOL'] = {
        label = 'Vintage Pistol',
        weight = 2.5,
        description = 'Classic pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_FLAREGUN'] = {
        label = 'Flare Gun',
        weight = 1.5,
        description = 'Signal flare launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MARKSMANPISTOL'] = {
        label = 'Marksman Pistol',
        weight = 3.0,
        description = 'Single-shot pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_REVOLVER'] = {
        label = 'Heavy Revolver',
        weight = 4.0,
        description = 'Powerful revolver',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_REVOLVER_MK2'] = {
        label = 'Heavy Revolver Mk II',
        weight = 4.2,
        description = 'Enhanced revolver',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_DOUBLEACTION'] = {
        label = 'Double-Action Revolver',
        weight = 3.5,
        description = 'Classic revolver',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_RAYPISTOL'] = {
        label = 'Up-n-Atomizer',
        weight = 3.0,
        description = 'Experimental weapon',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_CERAMICPISTOL'] = {
        label = 'Ceramic Pistol',
        weight = 2.5,
        description = 'Undetectable pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_NAVYREVOLVER'] = {
        label = 'Navy Revolver',
        weight = 4.0,
        description = 'Classic naval revolver',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_GADGETPISTOL'] = {
        label = 'Perico Pistol',
        weight = 2.5,
        description = 'Exotic pistol',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- SUBMACHINE GUNS
    ['WEAPON_MICROSMG'] = {
        label = 'Micro SMG',
        weight = 4.0,
        description = 'Compact SMG',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SMG'] = {
        label = 'SMG',
        weight = 5.0,
        description = 'Standard SMG',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SMG_MK2'] = {
        label = 'SMG Mk II',
        weight = 5.2,
        description = 'Enhanced SMG',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_ASSAULTSMG'] = {
        label = 'Assault SMG',
        weight = 5.5,
        description = 'Tactical SMG',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMBATPDW'] = {
        label = 'Combat PDW',
        weight = 5.0,
        description = 'Personal defense weapon',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MACHINEPISTOL'] = {
        label = 'Machine Pistol',
        weight = 3.5,
        description = 'Automatic pistol',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MINISMG'] = {
        label = 'Mini SMG',
        weight = 4.0,
        description = 'Compact automatic weapon',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_RAYCARBINE'] = {
        label = 'Unholy Hellbringer',
        weight = 6.0,
        description = 'Experimental weapon',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- SHOTGUNS
    ['WEAPON_PUMPSHOTGUN'] = {
        label = 'Pump Shotgun',
        weight = 7.0,
        description = 'Standard shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_PUMPSHOTGUN_MK2'] = {
        label = 'Pump Shotgun Mk II',
        weight = 7.2,
        description = 'Enhanced shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SAWNOFFSHOTGUN'] = {
        label = 'Sawed-off Shotgun',
        weight = 5.0,
        description = 'Short-barrel shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_ASSAULTSHOTGUN'] = {
        label = 'Assault Shotgun',
        weight = 8.0,
        description = 'Automatic shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_BULLPUPSHOTGUN'] = {
        label = 'Bullpup Shotgun',
        weight = 7.0,
        description = 'Tactical shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MUSKET'] = {
        label = 'Musket',
        weight = 8.0,
        description = 'Antique rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HEAVYSHOTGUN'] = {
        label = 'Heavy Shotgun',
        weight = 8.5,
        description = 'High-powered shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_DBSHOTGUN'] = {
        label = 'Double Barrel Shotgun',
        weight = 6.0,
        description = 'Classic shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_AUTOSHOTGUN'] = {
        label = 'Sweeper Shotgun',
        weight = 7.5,
        description = 'Automatic shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMBATSHOTGUN'] = {
        label = 'Combat Shotgun',
        weight = 7.8,
        description = 'Tactical combat shotgun',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- ASSAULT RIFLES
    ['WEAPON_ASSAULTRIFLE'] = {
        label = 'Assault Rifle',
        weight = 7.0,
        description = 'Standard assault rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_ASSAULTRIFLE_MK2'] = {
        label = 'Assault Rifle Mk II',
        weight = 7.2,
        description = 'Enhanced assault rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_CARBINERIFLE'] = {
        label = 'Carbine Rifle',
        weight = 7.0,
        description = 'Military carbine',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_CARBINERIFLE_MK2'] = {
        label = 'Carbine Rifle Mk II',
        weight = 7.2,
        description = 'Enhanced carbine',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_ADVANCEDRIFLE'] = {
        label = 'Advanced Rifle',
        weight = 7.5,
        description = 'Tactical rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SPECIALCARBINE'] = {
        label = 'Special Carbine',
        weight = 7.0,
        description = 'Special forces carbine',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_SPECIALCARBINE_MK2'] = {
        label = 'Special Carbine Mk II',
        weight = 7.2,
        description = 'Enhanced special carbine',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_BULLPUPRIFLE'] = {
        label = 'Bullpup Rifle',
        weight = 6.5,
        description = 'Compact rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_BULLPUPRIFLE_MK2'] = {
        label = 'Bullpup Rifle Mk II',
        weight = 6.7,
        description = 'Enhanced bullpup rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMPACTRIFLE'] = {
        label = 'Compact Rifle',
        weight = 5.5,
        description = 'Compact assault rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MILITARYRIFLE'] = {
        label = 'Military Rifle',
        weight = 7.5,
        description = 'Military grade rifle',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- LIGHT MACHINE GUNS
    ['WEAPON_MG'] = {
        label = 'MG',
        weight = 9.0,
        description = 'Light machine gun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMBATMG'] = {
        label = 'Combat MG',
        weight = 10.0,
        description = 'Heavy machine gun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMBATMG_MK2'] = {
        label = 'Combat MG Mk II',
        weight = 10.2,
        description = 'Enhanced machine gun',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_GUSENBERG'] = {
        label = 'Gusenberg Sweeper',
        weight = 8.0,
        description = 'Classic thompson',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- SNIPER RIFLES
    ['WEAPON_SNIPERRIFLE'] = {
        label = 'Sniper Rifle',
        weight = 10.0,
        description = 'Standard sniper',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HEAVYSNIPER'] = {
        label = 'Heavy Sniper',
        weight = 12.0,
        description = 'Heavy sniper rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HEAVYSNIPER_MK2'] = {
        label = 'Heavy Sniper Mk II',
        weight = 12.2,
        description = 'Enhanced heavy sniper',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MARKSMANRIFLE'] = {
        label = 'Marksman Rifle',
        weight = 8.0,
        description = 'Precision rifle',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MARKSMANRIFLE_MK2'] = {
        label = 'Marksman Rifle Mk II',
        weight = 8.2,
        description = 'Enhanced marksman rifle',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- HEAVY WEAPONS
    ['WEAPON_RPG'] = {
        label = 'RPG',
        weight = 15.0,
        description = 'Rocket launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_GRENADELAUNCHER'] = {
        label = 'Grenade Launcher',
        weight = 10.0,
        description = 'Explosive launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_GRENADELAUNCHER_SMOKE'] = {
        label = 'Smoke Grenade Launcher',
        weight = 8.0,
        description = 'Smoke launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_MINIGUN'] = {
        label = 'Minigun',
        weight = 25.0,
        description = 'Heavy rotary weapon',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_FIREWORK'] = {
        label = 'Firework Launcher',
        weight = 8.0,
        description = 'Celebration launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_RAILGUN'] = {
        label = 'Railgun',
        weight = 15.0,
        description = 'Electromagnetic weapon',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_HOMINGLAUNCHER'] = {
        label = 'Homing Launcher',
        weight = 15.0,
        description = 'Guided missile launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_COMPACTLAUNCHER'] = {
        label = 'Compact Grenade Launcher',
        weight = 8.0,
        description = 'Compact explosive launcher',
        usable = true,
        stackable = false,
        weapon = true
    },
    ['WEAPON_RAYMINIGUN'] = {
        label = 'Widowmaker',
        weight = 20.0,
        description = 'Experimental heavy weapon',
        usable = true,
        stackable = false,
        weapon = true
    },

    -- THROWABLES
    ['WEAPON_GRENADE'] = {
        label = 'Grenade',
        weight = 0.6,
        description = 'Explosive device',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_BZGAS'] = {
        label = 'BZ Gas',
        weight = 0.6,
        description = 'Tear gas',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_MOLOTOV'] = {
        label = 'Molotov Cocktail',
        weight = 0.8,
        description = 'Incendiary device',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_STICKYBOMB'] = {
        label = 'Sticky Bomb',
        weight = 0.8,
        description = 'Remote explosive',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_PROXMINE'] = {
        label = 'Proximity Mine',
        weight = 0.8,
        description = 'Proximity explosive',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_SNOWBALL'] = {
        label = 'Snowball',
        weight = 0.1,
        description = 'Festive projectile',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_PIPEBOMB'] = {
        label = 'Pipe Bomb',
        weight = 0.8,
        description = 'Improvised explosive',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_BALL'] = {
        label = 'Ball',
        weight = 0.1,
        description = 'Sports ball',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_SMOKEGRENADE'] = {
        label = 'Smoke Grenade',
        weight = 0.6,
        description = 'Smoke device',
        usable = true,
        stackable = true,
        weapon = true
    },
    ['WEAPON_FLARE'] = {
        label = 'Flare',
        weight = 0.3,
        description = 'Signal device',
        usable = true,
        stackable = true,
        weapon = true
    },

    -- AMMUNITION
    ['ammo-pistol'] = {
        label = 'Pistol Ammo',
        weight = 0.02,
        description = 'Ammunition for pistols',
        usable = false,
        stackable = true
    },
    ['ammo-pistol-large'] = {
        label = 'Large Pistol Ammo',
        weight = 0.025,
        description = 'Large caliber pistol ammo',
        usable = false,
        stackable = true
    },
    ['ammo-rifle'] = {
        label = 'Rifle Ammo',
        weight = 0.035,
        description = 'Ammunition for rifles',
        usable = false,
        stackable = true
    },
    ['ammo-rifle-large'] = {
        label = 'Large Rifle Ammo',
        weight = 0.04,
        description = 'Large caliber rifle ammo',
        usable = false,
        stackable = true
    },
    ['ammo-smg'] = {
        label = 'SMG Ammo',
        weight = 0.025,
        description = 'Ammunition for SMGs',
        usable = false,
        stackable = true
    },
    ['ammo-shotgun'] = {
        label = 'Shotgun Shells',
        weight = 0.05,
        description = 'Shotgun ammunition',
        usable = false,
        stackable = true
    },
    ['ammo-sniper'] = {
        label = 'Sniper Ammo',
        weight = 0.05,
        description = 'Sniper rifle ammunition',
        usable = false,
        stackable = true
    },
    ['ammo-heavy'] = {
        label = 'Heavy Ammo',
        weight = 0.1,
        description = 'Heavy weapon ammunition',
        usable = false,
        stackable = true
    },

    -- CONSUMABLES
    ['water'] = {
        label = 'Water',
        weight = 0.5,
        description = 'Bottle of water',
        usable = true,
        stackable = true
    },
    ['cola'] = {
        label = 'eCola',
        weight = 0.5,
        description = 'Carbonated drink',
        usable = true,
        stackable = true
    },
    ['sprunk'] = {
        label = 'Sprunk',
        weight = 0.5,
        description = 'Carbonated drink',
        usable = true,
        stackable = true
    },
    ['coffee'] = {
        label = 'Coffee',
        weight = 0.3,
        description = 'Hot coffee',
        usable = true,
        stackable = true
    },
    ['burger'] = {
        label = 'Burger',
        weight = 0.5,
        description = 'Burger Shot burger',
        usable = true,
        stackable = true
    },
    ['sandwich'] = {
        label = 'Sandwich',
        weight = 0.3,
        description = 'Fresh sandwich',
        usable = true,
        stackable = true
    },
    ['hotdog'] = {
        label = 'Hot Dog',
        weight = 0.4,
        description = 'Street vendor hot dog',
        usable = true,
        stackable = true
    },
    ['donut'] = {
        label = 'Donut',
        weight = 0.2,
        description = 'Sweet treat',
        usable = true,
        stackable = true
    },
    ['chocolate'] = {
        label = 'Chocolate Bar',
        weight = 0.2,
        description = 'Sweet snack',
        usable = true,
        stackable = true
    },
    ['beer'] = {
        label = 'Beer',
        weight = 0.5,
        description = 'Alcoholic beverage',
        usable = true,
        stackable = true
    },
    ['wine'] = {
        label = 'Wine',
        weight = 1.0,
        description = 'Fancy alcohol',
        usable = true,
        stackable = true
    },
    ['whiskey'] = {
        label = 'Whiskey',
        weight = 0.7,
        description = 'Strong alcohol',
        usable = true,
        stackable = true
    },
    ['tequila'] = {
        label = 'Tequila',
        weight = 0.7,
        description = 'Mexican alcohol',
        usable = true,
        stackable = true
    },
    ['vodka'] = {
        label = 'Vodka',
        weight = 0.7,
        description = 'Russian alcohol',
        usable = true,
        stackable = true
    },

    -- TOOLS & EQUIPMENT
    ['repairkit'] = {
        label = 'Repair Kit',
        weight = 2.0,
        description = 'Vehicle repair kit',
        usable = true,
        stackable = true
    },
    ['lockpick'] = {
        label = 'Lockpick',
        weight = 0.3,
        description = 'Basic lockpick',
        usable = true,
        stackable = true
    },
    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 0.5,
        description = 'Professional lockpick',
        usable = true,
        stackable = true
    },
    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 0.5,
        description = 'Restraining device',
        usable = true,
        stackable = true
    },
    ['rope'] = {
        label = 'Rope',
        weight = 1.0,
        description = 'Useful for tying',
        usable = true,
        stackable = true
    },
    ['phone'] = {
        label = 'Phone',
        weight = 0.3,
        description = 'Mobile device',
        usable = true,
        stackable = false
    },
    ['radio'] = {
        label = 'Radio',
        weight = 1.0,
        description = 'Communication device',
        usable = true,
        stackable = false
    },
    ['binoculars'] = {
        label = 'Binoculars',
        weight = 1.0,
        description = 'Long range viewing',
        usable = true,
        stackable = false
    },
    ['camera'] = {
        label = 'Camera',
        weight = 0.5,
        description = 'Digital camera',
        usable = true,
        stackable = false
    },
    ['drill'] = {
        label = 'Drill',
        weight = 3.0,
        description = 'Power tool',
        usable = true,
        stackable = false
    },
    ['oxygen_mask'] = {
        label = 'Oxygen Mask',
        weight = 1.5,
        description = 'Underwater breathing apparatus',
        usable = true,
        stackable = false
    },
    ['parachute'] = {
        label = 'Parachute',
        weight = 3.0,
        description = 'Safety device for high altitude',
        usable = true,
        stackable = false
    },
    ['toolbox'] = {
        label = 'Toolbox',
        weight = 4.0,
        description = 'Set of various tools',
        usable = true,
        stackable = false
    },
    ['crowbar'] = {
        label = 'Crowbar',
        weight = 2.5,
        description = 'Useful prying tool',
        usable = true,
        stackable = false
    },
    ['armor'] = {
        label = 'Body Armor',
        weight = 7.0,
        description = 'Protective equipment',
        usable = true,
        stackable = false
    },
    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 8.0,
        description = 'Complete diving equipment',
        usable = true,
        stackable = false
    },
    ['gps'] = {
        label = 'GPS Device',
        weight = 0.5,
        description = 'Navigation system',
        usable = true,
        stackable = false
    },
    ['zipties'] = {
        label = 'Zip Ties',
        weight = 0.1,
        description = 'Restraining device',
        usable = true,
        stackable = true
    },
    ['tablet'] = {
        label = 'Tablet',
        weight = 0.8,
        description = 'Digital device',
        usable = true,
        stackable = false
    },
    ['laptop'] = {
        label = 'Laptop',
        weight = 2.0,
        description = 'Portable computer',
        usable = true,
        stackable = false
    },
    ['hackingtool'] = {
        label = 'Hacking Device',
        weight = 1.0,
        description = 'Electronic hacking tool',
        usable = true,
        stackable = false
    },
    ['firstaid'] = {
        label = 'First Aid Kit',
        weight = 2.0,
        description = 'Medical supplies',
        usable = true,
        stackable = true
    },
    ['defibrillator'] = {
        label = 'Defibrillator',
        weight = 3.0,
        description = 'Medical emergency device',
        usable = true,
        stackable = false
    },
    ['bodybag'] = {
        label = 'Body Bag',
        weight = 2.0,
        description = 'Medical transport bag',
        usable = true,
        stackable = true
    },

    -- Vehicle Items
    ['vehicle_key'] = {
        label = 'Vehicle Key',
        weight = 0.1,
        description = 'Car key',
        usable = true,
        stackable = false
    },
    ['nitro'] = {
        label = 'Nitrous Oxide',
        weight = 5.0,
        description = 'Vehicle performance enhancer',
        usable = true,
        stackable = false
    },
    ['tuning_kit'] = {
        label = 'Tuning Kit',
        weight = 3.0,
        description = 'Vehicle modification tools',
        usable = true,
        stackable = false
    },
    ['cleaning_kit'] = {
        label = 'Cleaning Kit',
        weight = 1.5,
        description = 'Vehicle cleaning supplies',
        usable = true,
        stackable = true
    },
    ['wheel'] = {
        label = 'Spare Wheel',
        weight = 15.0,
        description = 'Vehicle spare tire',
        usable = true,
        stackable = false
    },
    ['engine_oil'] = {
        label = 'Engine Oil',
        weight = 1.0,
        description = 'Vehicle maintenance fluid',
        usable = true,
        stackable = true
    },
}